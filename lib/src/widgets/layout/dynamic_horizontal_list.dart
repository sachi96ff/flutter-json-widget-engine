// lib/dynamic_ui/widgets/layout/dynamic_horizontal_list.dart

import 'package:flutter/material.dart';
import '../../engine/style_parser.dart';
import '../../engine/json_widget_engine.dart';
import '../../models/widget_node.dart';

/// Renders children in a horizontally scrolling list.
///
/// JSON example:
/// ```json
/// {
///   "type": "HorizontalList",
///   "properties": {
///     "item_width": 220,
///     "spacing": 12,
///     "items": [ ... ]
///   },
///   "style": { "height": 180 }
/// }
/// ```
class DynamicHorizontalList {
  const DynamicHorizontalList._();

  static Widget build(WidgetNode node, BuildContext context, JsonWidgetEngine engine) {
    final itemWidth = node.getDouble('item_width') ?? node.getDouble('itemWidth');
    final spacing = node.getDouble('spacing', 12) ?? 12;
    final height = StyleParser.resolveHeight(node.style, context);

    // Gather items from children or properties.items
    List<WidgetNode> items = node.children;
    if (items.isEmpty && node.properties['items'] is List) {
      items = (node.properties['items'] as List)
          .whereType<Map<String, dynamic>>()
          .map((item) => WidgetNode.fromJson(item))
          .toList();
    }

    if (items.isEmpty) return const SizedBox.shrink();

    Widget list = ListView.separated(
      scrollDirection: Axis.horizontal,
      itemCount: items.length,
      shrinkWrap: height == null,
      padding: node.style?.padding ?? EdgeInsets.zero,
      separatorBuilder: (context, index) => SizedBox(width: spacing),
      itemBuilder: (context, index) {
        Widget child = engine.buildWidget(items[index], context);
        if (itemWidth != null) {
          child = SizedBox(width: itemWidth, child: child);
        }
        return child;
      },
    );

    // Height is required for horizontal list, but use intrinsic if not set
    if (height != null) {
      return SizedBox(height: height, child: list);
    }
    // When no height specified, try to use intrinsic height
    return SizedBox(height: 180, child: list);
  }
}
