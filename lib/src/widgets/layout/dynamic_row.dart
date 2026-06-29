// lib/dynamic_ui/widgets/layout/dynamic_row.dart

import 'package:flutter/material.dart';
import '../../engine/style_parser.dart';
import '../../engine/json_widget_engine.dart';
import '../../models/widget_node.dart';

/// Renders children horizontally in a Row.
///
/// JSON example:
/// ```json
/// {
///   "type": "Row",
///   "properties": {
///     "mainAxisAlignment": "spaceBetween",
///     "crossAxisAlignment": "center",
///     "spacing": 12
///   },
///   "children": [ ... ]
/// }
/// ```
class DynamicRow {
  const DynamicRow._();

  static Widget build(WidgetNode node, BuildContext context, JsonWidgetEngine engine) {
    final mainAxis = StyleParser.parseMainAxisAlignment(
      node.getString('mainAxisAlignment') ?? node.getString('main_axis_alignment'),
    );
    final crossAxis = StyleParser.parseCrossAxisAlignment(
      node.getString('crossAxisAlignment') ?? node.getString('cross_axis_alignment'),
    );
    final spacing = node.getDouble('spacing', 0);
    final padding = node.style?.padding;
    final margin = node.style?.margin;

    final children = <Widget>[];
    for (int i = 0; i < node.children.length; i++) {
      children.add(engine.buildWidget(node.children[i], context));
      if (spacing! > 0 && i < node.children.length - 1) {
        children.add(SizedBox(width: spacing));
      }
    }

    Widget row = Row(
      mainAxisAlignment: mainAxis,
      crossAxisAlignment: crossAxis,
      mainAxisSize: MainAxisSize.max,
      children: children,
    );

    // Apply padding if set
    if (padding != null) {
      row = Padding(padding: padding, child: row);
    }

    // Apply margin if set
    if (margin != null) {
      row = Padding(padding: margin, child: row);
    }

    return row;
  }
}
