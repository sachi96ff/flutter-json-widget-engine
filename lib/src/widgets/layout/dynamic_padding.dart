// lib/dynamic_ui/widgets/layout/dynamic_padding.dart

import 'package:flutter/material.dart';
import '../../engine/json_widget_engine.dart';
import '../../models/widget_node.dart';

/// Wraps children with padding.
///
/// JSON example:
/// ```json
/// {
///   "type": "Padding",
///   "style": { "padding": 16 },
///   "children": [ ... ]
/// }
/// ```
/// Or with properties:
/// ```json
/// {
///   "type": "Padding",
///   "properties": { "padding": { "horizontal": 20, "vertical": 12 } },
///   "children": [ ... ]
/// }
/// ```
class DynamicPadding {
  const DynamicPadding._();

  static Widget build(WidgetNode node, BuildContext context, JsonWidgetEngine engine) {
    // Get padding from style or properties
    EdgeInsets padding = node.style?.padding ?? const EdgeInsets.all(0);

    // Also check properties for padding
    final propPadding = node.properties['padding'];
    if (propPadding != null) {
      if (propPadding is num) {
        padding = EdgeInsets.all(propPadding.toDouble());
      } else if (propPadding is Map<String, dynamic>) {
        if (propPadding.containsKey('vertical') || propPadding.containsKey('horizontal')) {
          padding = EdgeInsets.symmetric(
            vertical: (propPadding['vertical'] as num?)?.toDouble() ?? 0,
            horizontal: (propPadding['horizontal'] as num?)?.toDouble() ?? 0,
          );
        } else {
          padding = EdgeInsets.only(
            top: (propPadding['top'] as num?)?.toDouble() ?? 0,
            bottom: (propPadding['bottom'] as num?)?.toDouble() ?? 0,
            left: (propPadding['left'] as num?)?.toDouble() ?? 0,
            right: (propPadding['right'] as num?)?.toDouble() ?? 0,
          );
        }
      }
    }

    Widget? child;
    if (node.children.length == 1) {
      child = engine.buildWidget(node.children.first, context);
    } else if (node.children.length > 1) {
      child = Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: node.children.map((c) => engine.buildWidget(c, context)).toList(),
      );
    }

    return Padding(
      padding: padding,
      child: child ?? const SizedBox.shrink(),
    );
  }
}
