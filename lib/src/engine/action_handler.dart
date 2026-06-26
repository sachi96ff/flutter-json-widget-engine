// lib/dynamic_ui/engine/action_handler.dart

import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import '../models/widget_node.dart';
import '../screens/dynamic_screen.dart';
import 'json_widget_engine.dart';

/// Handles on_click actions from dynamic widgets.
///
/// Supported actions:
/// - `navigate` → Opens DynamicScreen with a JSON file
/// - `navigate_named` → Pushes a named Flutter route
/// - `open_url` → Opens a URL in external browser
class ActionHandler {
  const ActionHandler._();

  /// Execute a click action and analytics. Returns a VoidCallback or null.
  static VoidCallback? buildCallback(
    BuildContext context, {
    ClickAction? action,
    AnalyticsConfig? analytics,
  }) {
    if (action == null && analytics == null) return null;

    return () {
      final engine = JsonWidgetEngineProvider.of(context);
      
      // 1. Log analytics if present
      if (engine != null && analytics != null) {
        engine.analyticsDelegate?.logEvent(
          analytics.eventName,
          analytics.params,
        );
      }

      if (action == null) return;

      
      // Let the native app handle the action first via the registry
      if (engine != null) {
        final handled = engine.actionRegistry.execute(
          action.action,
          context,
          action.params,
        );
        if (handled) return; // Stop if the host app handled it
      }

      // Default built-in actions
      switch (action.action) {
        case 'navigate':
          _handleNavigate(action, context);
          break;
        case 'navigate_named':
          _handleNavigateNamed(action, context);
          break;
        case 'open_url':
          _handleOpenUrl(action);
          break;
        default:
          debugPrint('⚠️ DynamicUI: Unknown or unhandled action "${action.action}"');
          break;
      }
    };
  }

  /// Navigate to DynamicScreen with a JSON file.
  static void _handleNavigate(ClickAction action, BuildContext context) {
    final jsonFile = action.jsonFile;
    if (jsonFile == null || jsonFile.isEmpty) {
      debugPrint('⚠️ DynamicUI: navigate action missing json_file');
      return;
    }

    final engine = JsonWidgetEngineProvider.of(context);

    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => DynamicScreen(
          jsonFile: jsonFile,
          title: action.params['title'],
          engine: engine,
        ),
      ),
    );
  }

  /// Navigate to an existing named route.
  static void _handleNavigateNamed(ClickAction action, BuildContext context) {
    final route = action.route;
    if (route == null || route.isEmpty) {
      debugPrint('⚠️ DynamicUI: navigate_named action missing route');
      return;
    }

    Navigator.of(context).pushNamed(
      route,
      arguments: action.params.isNotEmpty ? action.params : null,
    );
  }

  /// Open a URL in external browser.
  static Future<void> _handleOpenUrl(ClickAction action) async {
    final urlString = action.url;
    if (urlString == null || urlString.isEmpty) {
      debugPrint('⚠️ DynamicUI: open_url action missing url');
      return;
    }

    try {
      final uri = Uri.parse(urlString);
      // Removed canLaunchUrl check because it requires manifest queries on Android 11+ and iOS
      final launched = await launchUrl(uri, mode: LaunchMode.externalApplication);
      if (!launched) {
        debugPrint('⚠️ DynamicUI: Failed to launch URL: $urlString');
      }
    } catch (e) {
      debugPrint('❌ DynamicUI: Error launching URL: $e');
    }
  }
}
