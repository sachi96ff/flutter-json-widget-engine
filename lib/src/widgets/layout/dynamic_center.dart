// lib/dynamic_ui/widgets/layout/dynamic_center.dart

import 'package:flutter/material.dart';
import '../../engine/json_widget_engine.dart';
import '../../models/widget_node.dart';

/// Centers its child.
///
/// JSON example:
/// ```json
/// {
///   "type": "Center",
///   "children": [
///     { "type": "Text", "properties": { "text": "Centered text" } }
///   ]
/// }
/// ```
class DynamicCenter {
  const DynamicCenter._();

  static Widget build(WidgetNode node, BuildContext context, JsonWidgetEngine engine) {
    Widget? child;
    if (node.children.isNotEmpty) {
      child = engine.buildWidget(node.children.first, context);
    }

    return Center(child: child ?? const SizedBox.shrink());
  }
}
