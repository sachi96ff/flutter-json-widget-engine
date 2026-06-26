// lib/dynamic_ui/models/widget_node.dart

import 'widget_style.dart';

/// Represents a single widget node parsed from JSON.
///
/// Each node has a [type] (e.g. "Title", "Card", "Column"),
/// optional [properties], [style], [animation], [visibility],
/// and [children] for layout widgets.
class WidgetNode {
  final String type;
  final Map<String, dynamic> properties;
  final WidgetStyle? style;
  final String? animation;
  final VisibilityConfig? visibility;
  final AnalyticsConfig? analytics;
  final List<WidgetNode> children;

  const WidgetNode({
    required this.type,
    this.properties = const {},
    this.style,
    this.animation,
    this.visibility,
    this.analytics,
    this.children = const [],
  });

  factory WidgetNode.fromJson(Map<String, dynamic> json) {
    // Parse children from either "children" or "items" key
    List<WidgetNode> children = [];
    if (json['children'] is List) {
      children = (json['children'] as List)
          .whereType<Map<String, dynamic>>()
          .map((c) => WidgetNode.fromJson(c))
          .toList();
    }

    // Also parse items inside properties (for List, Grid, HorizontalList, etc.)
    final props = Map<String, dynamic>.from(json['properties'] ?? {});
    if (props['items'] is List) {
      final items = (props['items'] as List)
          .whereType<Map<String, dynamic>>()
          .map((item) {
        // If item has a "type" key, it's a widget node
        if (item.containsKey('type')) {
          return item; // Keep as raw JSON, parsed later by engine
        }
        return item;
      }).toList();
      props['items'] = items;
    }

    return WidgetNode(
      type: json['type'] as String? ?? 'SizedBox',
      properties: props,
      style: json['style'] != null
          ? WidgetStyle.fromJson(json['style'] as Map<String, dynamic>)
          : null,
      animation: json['animation'] as String?,
      visibility: json['visibility'] != null
          ? VisibilityConfig.fromJson(
              json['visibility'] as Map<String, dynamic>)
          : null,
      analytics: json['analytics'] != null
          ? AnalyticsConfig.fromJson(
              json['analytics'] as Map<String, dynamic>)
          : null,
      children: children,
    );
  }

  /// Convenience getter for on_click action
  ClickAction? get clickAction {
    final onClick = properties['on_click'];
    if (onClick is Map<String, dynamic>) {
      return ClickAction.fromJson(onClick);
    }
    return null;
  }

  /// Get a string property with optional default
  String? getString(String key, [String? defaultValue]) {
    final val = properties[key];
    if (val is String) return val;
    return defaultValue;
  }

  /// Get an int property with optional default
  int? getInt(String key, [int? defaultValue]) {
    final val = properties[key];
    if (val is int) return val;
    if (val is double) return val.toInt();
    if (val is String) return int.tryParse(val) ?? defaultValue;
    return defaultValue;
  }

  /// Get a double property with optional default
  double? getDouble(String key, [double? defaultValue]) {
    final val = properties[key];
    if (val is double) return val;
    if (val is int) return val.toDouble();
    if (val is String) return double.tryParse(val) ?? defaultValue;
    return defaultValue;
  }

  /// Get a bool property with optional default
  bool getBool(String key, [bool defaultValue = false]) {
    final val = properties[key];
    if (val is bool) return val;
    if (val is int) return val != 0;
    if (val is String) return val.toLowerCase() == 'true';
    return defaultValue;
  }
}

/// Represents a click action on a widget.
class ClickAction {
  final String action; // "navigate", "open_url", "navigate_named"
  final String? targetScreen;
  final String? jsonFile;
  final String? url;
  final String? route; // for navigate_named
  final Map<String, dynamic> params;

  const ClickAction({
    required this.action,
    this.targetScreen,
    this.jsonFile,
    this.url,
    this.route,
    this.params = const {},
  });

  factory ClickAction.fromJson(Map<String, dynamic> json) {
    return ClickAction(
      action: json['action'] as String? ?? '',
      targetScreen: json['target_screen'] as String?,
      jsonFile: json['json_file'] as String?,
      url: json['url'] as String?,
      route: json['route'] as String?,
      params: Map<String, dynamic>.from(json['params'] ?? {}),
    );
  }
}

/// Controls widget visibility.
class VisibilityConfig {
  final bool visible;

  const VisibilityConfig({
    this.visible = true,
  });

  factory VisibilityConfig.fromJson(Map<String, dynamic> json) {
    return VisibilityConfig(
      visible: json['visible'] != false, // Default to true unless explicitly false
    );
  }
}

/// Configuration for logging analytics events.
class AnalyticsConfig {
  final String eventName;
  final Map<String, dynamic> params;

  const AnalyticsConfig({
    required this.eventName,
    this.params = const {},
  });

  factory AnalyticsConfig.fromJson(Map<String, dynamic> json) {
    return AnalyticsConfig(
      eventName: json['event_name'] as String? ?? 'unknown_event',
      params: Map<String, dynamic>.from(json['params'] ?? json['properties'] ?? {}),
    );
  }
}
