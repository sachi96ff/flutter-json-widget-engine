// lib/dynamic_ui/engine/widget_registry.dart

import 'package:flutter/material.dart';
import '../models/widget_node.dart';
import 'json_widget_engine.dart';
import 'style_parser.dart';

// Content widgets
import '../widgets/content/dynamic_title.dart';
import '../widgets/content/dynamic_subtitle.dart';
import '../widgets/content/dynamic_text.dart';
import '../widgets/content/dynamic_image.dart';
import '../widgets/content/dynamic_banner.dart';
import '../widgets/content/dynamic_icon.dart';

// Interactive widgets
import '../widgets/interactive/dynamic_button.dart';
import '../widgets/interactive/dynamic_icon_button.dart';
import '../widgets/interactive/dynamic_card.dart';

// Layout widgets
import '../widgets/layout/dynamic_column.dart';
import '../widgets/layout/dynamic_row.dart';
import '../widgets/layout/dynamic_container.dart';
import '../widgets/layout/dynamic_padding.dart';
import '../widgets/layout/dynamic_sized_box.dart';
import '../widgets/layout/dynamic_expanded.dart';
import '../widgets/layout/dynamic_center.dart';
import '../widgets/layout/dynamic_grid.dart';
import '../widgets/layout/dynamic_list.dart';
import '../widgets/layout/dynamic_horizontal_list.dart';

/// Callback type for building a widget from a node.
///
/// - [simpleBuilder]: Widgets that don't need the engine (leaf widgets).
/// - [engineBuilder]: Widgets that need the engine to render children.
typedef SimpleWidgetBuilder = Widget Function(WidgetNode node, BuildContext context);
typedef EngineWidgetBuilder = Widget Function(WidgetNode node, BuildContext context, JsonWidgetEngine engine);

/// Registry that maps widget type strings to their builder functions.
///
/// Usage:
/// ```dart
/// final registry = WidgetRegistry();
/// // Custom widget:
/// registry.registerSimple('MyWidget', (node, ctx) => MyWidget(...));
/// ```
class WidgetRegistry {
  final Map<String, SimpleWidgetBuilder> _simpleBuilders = {};
  final Map<String, EngineWidgetBuilder> _engineBuilders = {};

  WidgetRegistry() {
    _registerDefaults();
  }

  /// Register a leaf widget builder (no children).
  void registerSimple(String type, SimpleWidgetBuilder builder) {
    _simpleBuilders[type.toLowerCase()] = builder;
  }

  /// Register a layout/container widget builder (has children, needs engine).
  void registerEngine(String type, EngineWidgetBuilder builder) {
    _engineBuilders[type.toLowerCase()] = builder;
  }

  /// Check if a widget type is registered.
  bool hasBuilder(String type) {
    final key = type.toLowerCase();
    return _simpleBuilders.containsKey(key) || _engineBuilders.containsKey(key);
  }

  /// Build a widget from a node. Returns null if type is not registered.
  Widget? build(WidgetNode node, BuildContext context, JsonWidgetEngine engine) {
    final key = node.type.toLowerCase();

    // Try engine builders first (layout widgets)
    final engineBuilder = _engineBuilders[key];
    if (engineBuilder != null) {
      return engineBuilder(node, context, engine);
    }

    // Then simple builders (leaf widgets)
    final simpleBuilder = _simpleBuilders[key];
    if (simpleBuilder != null) {
      return simpleBuilder(node, context);
    }

    return null;
  }

  /// Register all default widget types.
  void _registerDefaults() {
    // ─── Content Widgets (leaf — no children) ─────────────────
    registerSimple('Title', DynamicTitle.build);
    registerSimple('Subtitle', DynamicSubtitle.build);
    registerSimple('Text', DynamicText.build);
    registerSimple('Image', DynamicImage.build);
    registerSimple('Banner', DynamicBanner.build);
    registerSimple('Icon', DynamicIcon.build);

    // ─── Interactive Widgets ─────────────────────────────────
    registerSimple('Button', DynamicButton.build);
    registerSimple('IconButton', DynamicIconButton.build);

    // Card needs engine for children
    registerEngine('Card', DynamicCard.build);
    registerEngine('DynamicCard', DynamicCard.build);

    // ─── Layout Widgets (need engine for children) ────────────
    registerEngine('Column', DynamicColumn.build);
    registerEngine('Row', DynamicRow.build);
    registerEngine('Container', DynamicContainer.build);
    registerEngine('Padding', DynamicPadding.build);
    registerEngine('SizedBox', DynamicSizedBox.build);
    registerEngine('Spacer', DynamicSizedBox.build); // Alias
    registerEngine('Expanded', DynamicExpanded.build);
    registerEngine('Center', DynamicCenter.build);
    registerEngine('Grid', DynamicGrid.build);
    registerEngine('List', DynamicList.build);
    registerEngine('HorizontalList', DynamicHorizontalList.build);

    // ─── Aliases for convenience ─────────────────────────────
    registerSimple('Heading', DynamicTitle.build);
    registerSimple('H1', DynamicTitle.build);
    registerSimple('H2', DynamicSubtitle.build);
    registerSimple('Paragraph', DynamicText.build);
    registerSimple('NetworkImage', DynamicImage.build);
    registerSimple('Divider', _buildDivider);
  }

  /// Built-in divider widget.
  static Widget _buildDivider(WidgetNode node, BuildContext context) {
    final color = node.style?.border != null
        ? _parseColor(node.style!.border!)
        : null;
    final thickness = node.getDouble('thickness', 1) ?? 1;
    final indent = node.getDouble('indent', 0) ?? 0;

    return Divider(
      height: node.getDouble('height', 1),
      thickness: thickness,
      indent: indent,
      endIndent: indent,
      color: color,
    );
  }

  static Color? _parseColor(String hex) {
    return StyleParser.parseColor(hex);
  }
}
