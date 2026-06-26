// lib/dynamic_ui/widgets/layout/dynamic_sized_box.dart

import 'package:flutter/material.dart';
import '../../engine/style_parser.dart';
import '../../engine/json_widget_engine.dart';
import '../../models/widget_node.dart';

/// Renders a SizedBox with fixed width/height.
///
/// JSON examples:
/// ```json
/// { "type": "SizedBox", "style": { "height": 24 } }
/// { "type": "SizedBox", "properties": { "width": 12 } }
/// { "type": "Spacer", "style": { "height": 16 } }
/// ```
class DynamicSizedBox {
  const DynamicSizedBox._();

  static Widget build(WidgetNode node, BuildContext context, JsonWidgetEngine engine) {
    final width = StyleParser.resolveWidth(node.style, context) ??
        node.getDouble('width');
    final height = StyleParser.resolveHeight(node.style, context) ??
        node.getDouble('height');

    Widget? child;
    if (node.children.length == 1) {
      child = engine.buildWidget(node.children.first, context);
    }

    return SizedBox(
      width: width,
      height: height,
      child: child,
    );
  }
}
