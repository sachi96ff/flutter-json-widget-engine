// lib/dynamic_ui/widgets/layout/dynamic_container.dart

import 'package:flutter/material.dart';
import '../../engine/style_parser.dart';
import '../../engine/action_handler.dart';
import '../../engine/json_widget_engine.dart';
import '../../models/widget_node.dart';

/// Renders a styled container that wraps its children.
///
/// This is the most versatile layout widget — it applies the full
/// style system (background, border, radius, shadow, padding, margin,
/// width, height) around a single child or column of children.
///
/// JSON example:
/// ```json
/// {
///   "type": "Container",
///   "style": {
///     "background": "#FFFFFF",
///     "radius": 16,
///     "padding": 16,
///     "margin": { "bottom": 12 },
///     "shadow": true,
///     "width": "100%"
///   },
///   "children": [ ... ]
/// }
/// ```
class DynamicContainer {
  const DynamicContainer._();

  static Widget build(WidgetNode node, BuildContext context, JsonWidgetEngine engine) {
    final style = node.style;
    final decoration = StyleParser.buildDecoration(style, context);
    final padding = style?.padding;
    final margin = style?.margin;
    final width = StyleParser.resolveWidth(style, context);
    final height = StyleParser.resolveHeight(style, context);
    final alignment = style?.alignment != null
        ? StyleParser.parseAlignment(style!.alignment)
        : null;
    final opacity = style?.opacity;

    // Click handler
    final onTap = ActionHandler.buildCallback(context, action: node.clickAction, analytics: node.analytics);

    // Child content
    Widget? child;
    if (node.children.isNotEmpty) {
      final alignStr = node.getString('alignment') ?? 'start';
      CrossAxisAlignment crossAlign;
      switch (alignStr) {
        case 'center': crossAlign = CrossAxisAlignment.center; break;
        case 'end': crossAlign = CrossAxisAlignment.end; break;
        default: crossAlign = CrossAxisAlignment.start; break;
      }

      child = Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: crossAlign,
        children: node.children
            .map((c) => engine.buildWidget(c, context))
            .toList(),
      );
    }

    Widget container = Container(
      width: width,
      height: height,
      padding: padding,
      margin: margin,
      alignment: alignment,
      decoration: decoration,
      child: child,
    );

    // Opacity
    if (opacity != null && opacity < 1.0) {
      container = Opacity(opacity: opacity, child: container);
    }

    // Clickable
    if (onTap != null) {
      container = GestureDetector(onTap: onTap, child: container);
    }

    return container;
  }
}
