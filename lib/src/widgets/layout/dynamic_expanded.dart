// lib/dynamic_ui/widgets/layout/dynamic_expanded.dart

import 'package:flutter/material.dart';
import '../../engine/json_widget_engine.dart';
import '../../models/widget_node.dart';

/// Wraps a child in an Expanded widget (for use inside Row/Column).
///
/// JSON example:
/// ```json
/// {
///   "type": "Expanded",
///   "properties": { "flex": 2 },
///   "children": [ ... ]
/// }
/// ```
class DynamicExpanded {
  const DynamicExpanded._();

  static Widget build(WidgetNode node, BuildContext context, JsonWidgetEngine engine) {
    final flex = node.getInt('flex', 1);

    Widget? child;
    if (node.children.isNotEmpty) {
      child = engine.buildWidget(node.children.first, context);
    }

    return Expanded(
      flex: flex ?? 1,
      child: child ?? const SizedBox.shrink(),
    );
  }
}
