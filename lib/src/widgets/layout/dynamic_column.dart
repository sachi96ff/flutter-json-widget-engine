// lib/dynamic_ui/widgets/layout/dynamic_column.dart

import 'package:flutter/material.dart';
import '../../engine/style_parser.dart';
import '../../engine/json_widget_engine.dart';
import '../../models/widget_node.dart';

/// Renders children vertically in a Column.
///
/// JSON example:
/// ```json
/// {
///   "type": "Column",
///   "properties": {
///     "mainAxisAlignment": "start",
///     "crossAxisAlignment": "stretch",
///     "spacing": 12
///   },
///   "children": [ ... ]
/// }
/// ```
class DynamicColumn {
  const DynamicColumn._();

  static Widget build(WidgetNode node, BuildContext context, JsonWidgetEngine engine) {
    final mainAxis = StyleParser.parseMainAxisAlignment(
      node.getString('mainAxisAlignment') ?? node.getString('main_axis_alignment'),
    );
    final crossAxis = StyleParser.parseCrossAxisAlignment(
      node.getString('crossAxisAlignment') ?? node.getString('cross_axis_alignment'),
    );
    final spacing = node.getDouble('spacing', 0);

    final children = <Widget>[];
    for (int i = 0; i < node.children.length; i++) {
      children.add(engine.buildWidget(node.children[i], context));
      if (spacing! > 0 && i < node.children.length - 1) {
        children.add(SizedBox(height: spacing));
      }
    }

    return Column(
      mainAxisAlignment: mainAxis,
      crossAxisAlignment: crossAxis,
      mainAxisSize: MainAxisSize.min,
      children: children,
    );
  }
}
