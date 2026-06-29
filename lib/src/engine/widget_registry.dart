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

    // ─── New Advanced Widgets ─────────────────────────────────
    registerEngine('Stack', _buildStack);
    registerEngine('Wrap', _buildWrap);
    registerSimple('Chip', _buildChip);
    registerSimple('ProgressBar', _buildProgressBar);
    registerEngine('Badge', _buildBadge);
    registerSimple('Avatar', _buildAvatar);
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

  /// Stack widget — overlapping children.
  static Widget _buildStack(WidgetNode node, BuildContext context, JsonWidgetEngine engine) {
    final alignStr = node.getString('alignment', 'center') ?? 'center';
    final alignMap = <String, AlignmentGeometry>{
      'topLeft': Alignment.topLeft,
      'topCenter': Alignment.topCenter,
      'topRight': Alignment.topRight,
      'centerLeft': Alignment.centerLeft,
      'center': Alignment.center,
      'centerRight': Alignment.centerRight,
      'bottomLeft': Alignment.bottomLeft,
      'bottomCenter': Alignment.bottomCenter,
      'bottomRight': Alignment.bottomRight,
    };

    final children = node.children
        .map((child) => engine.buildWidget(child, context))
        .toList();

    return Stack(
      alignment: alignMap[alignStr] ?? Alignment.center,
      children: children.isEmpty
          ? [const SizedBox.shrink()]
          : children,
    );
  }

  /// Wrap widget — flow layout.
  static Widget _buildWrap(WidgetNode node, BuildContext context, JsonWidgetEngine engine) {
    final spacing = node.getDouble('spacing', 8) ?? 8;
    final runSpacing = node.getDouble('runSpacing', 8) ?? 8;
    final alignStr = node.getString('alignment', 'start') ?? 'start';
    final alignMap = <String, WrapAlignment>{
      'start': WrapAlignment.start,
      'center': WrapAlignment.center,
      'end': WrapAlignment.end,
      'spaceBetween': WrapAlignment.spaceBetween,
      'spaceAround': WrapAlignment.spaceAround,
    };

    final children = node.children
        .map((child) => engine.buildWidget(child, context))
        .toList();

    return Wrap(
      spacing: spacing,
      runSpacing: runSpacing,
      alignment: alignMap[alignStr] ?? WrapAlignment.start,
      children: children,
    );
  }

  /// Chip widget — small label/tag.
  static Widget _buildChip(WidgetNode node, BuildContext context) {
    final text = node.getString('text', 'Chip') ?? 'Chip';
    final variant = node.getString('variant', 'filled') ?? 'filled';
    final bgColor = _parseColor(node.style?.background ?? '#EEF2FF') ?? const Color(0xFFEEF2FF);
    final textColor = _parseColor(node.style?.textColor ?? '#4338CA') ?? const Color(0xFF4338CA);
    final radius = node.style?.radius ?? 20;

    if (variant == 'outlined') {
      return Chip(
        label: Text(text, style: TextStyle(color: textColor, fontSize: node.style?.fontSize ?? 12)),
        backgroundColor: Colors.transparent,
        shape: StadiumBorder(side: BorderSide(color: textColor, width: 1.5)),
        padding: const EdgeInsets.symmetric(horizontal: 4),
      );
    }

    return Chip(
      label: Text(text, style: TextStyle(color: textColor, fontSize: node.style?.fontSize ?? 12)),
      backgroundColor: bgColor,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(radius)),
      padding: const EdgeInsets.symmetric(horizontal: 4),
    );
  }

  /// ProgressBar widget — linear progress indicator.
  static Widget _buildProgressBar(WidgetNode node, BuildContext context) {
    final value = (node.getDouble('value', 0.65) ?? 0.65).clamp(0.0, 1.0);
    final label = node.getString('label', '') ?? '';
    final showLabel = node.getBool('show_label', true);
    final trackColor = _parseColor(node.properties['track_color']?.toString() ?? '') ?? const Color(0xFFE5E7EB);
    final barColor = _parseColor(node.properties['bar_color']?.toString() ?? '') ?? const Color(0xFF6366F1);
    final radius = node.style?.radius ?? 4;
    final height = node.style?.height ?? 8;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        if (showLabel && label.isNotEmpty)
          Padding(
            padding: const EdgeInsets.only(bottom: 6),
            child: Text(label, style: const TextStyle(fontSize: 12, color: Color(0xFF6B7280))),
          ),
        ClipRRect(
          borderRadius: BorderRadius.circular(radius),
          child: SizedBox(
            height: height,
            child: LinearProgressIndicator(
              value: value,
              backgroundColor: trackColor,
              valueColor: AlwaysStoppedAnimation<Color>(barColor),
            ),
          ),
        ),
      ],
    );
  }

  /// Badge widget — notification badge.
  static Widget _buildBadge(WidgetNode node, BuildContext context, JsonWidgetEngine engine) {
    final count = node.getInt('count', 0) ?? 0;
    final maxCount = node.getInt('max_count', 99) ?? 99;
    final showDot = node.getBool('show_dot');
    final badgeColor = _parseColor(node.properties['badge_color']?.toString() ?? '') ?? Colors.red;

    final children = node.children
        .map((child) => engine.buildWidget(child, context))
        .toList();

    final child = children.isNotEmpty
        ? children.first
        : const SizedBox(width: 24, height: 24);

    if (showDot) {
      return Badge(
        smallSize: 10,
        backgroundColor: badgeColor,
        child: child,
      );
    }

    if (count > 0) {
      final display = count > maxCount ? '$maxCount+' : '$count';
      return Badge(
        label: Text(display, style: const TextStyle(fontSize: 10, color: Colors.white)),
        backgroundColor: badgeColor,
        child: child,
      );
    }

    return child;
  }

  /// Avatar widget — circular user image.
  static Widget _buildAvatar(WidgetNode node, BuildContext context) {
    final imageUrl = node.getString('image_url', '') ?? '';
    final text = node.getString('text', 'U') ?? 'U';
    final size = node.getDouble('size', 48) ?? 48;
    final bgColor = _parseColor(node.style?.background ?? '#6366F1') ?? const Color(0xFF6366F1);

    if (imageUrl.isNotEmpty) {
      return CircleAvatar(
        radius: size / 2,
        backgroundColor: bgColor,
        backgroundImage: NetworkImage(imageUrl),
      );
    }

    return CircleAvatar(
      radius: size / 2,
      backgroundColor: bgColor,
      child: Text(
        text.substring(0, text.length > 2 ? 2 : text.length).toUpperCase(),
        style: TextStyle(
          color: Colors.white,
          fontSize: size * 0.4,
          fontWeight: FontWeight.w700,
        ),
      ),
    );
  }

  static Color? _parseColor(String hex) {
    return StyleParser.parseColor(hex);
  }
}
