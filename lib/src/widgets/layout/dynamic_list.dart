// lib/dynamic_ui/widgets/layout/dynamic_list.dart

import 'package:flutter/material.dart';
import '../../engine/json_widget_engine.dart';
import '../../models/widget_node.dart';

/// Renders children in a vertical list with optional separators.
///
/// Unlike Column, List uses ListView.builder for better performance
/// with many items and supports separators.
///
/// JSON example:
/// ```json
/// {
///   "type": "List",
///   "properties": {
///     "separator": true,
///     "spacing": 8,
///     "items": [ ... ]
///   },
///   "children": [ ... ]
/// }
/// ```
class DynamicList {
  const DynamicList._();

  static Widget build(WidgetNode node, BuildContext context, JsonWidgetEngine engine) {
    final separator = node.getBool('separator', false);
    final spacing = node.getDouble('spacing', 0) ?? 0;

    // Gather items
    List<WidgetNode> items = node.children;
    if (items.isEmpty && node.properties['items'] is List) {
      items = (node.properties['items'] as List)
          .whereType<Map<String, dynamic>>()
          .map((item) => WidgetNode.fromJson(item))
          .toList();
    }

    if (items.isEmpty) return const SizedBox.shrink();

    return ListView.separated(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: items.length,
      separatorBuilder: (context, index) {
        if (separator) {
          return Column(
            children: [
              if (spacing > 0) SizedBox(height: spacing / 2),
              const Divider(height: 1),
              if (spacing > 0) SizedBox(height: spacing / 2),
            ],
          );
        }
        return SizedBox(height: spacing);
      },
      itemBuilder: (context, index) {
        return engine.buildWidget(items[index], context);
      },
    );
  }
}
