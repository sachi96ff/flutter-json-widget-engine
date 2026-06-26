// lib/dynamic_ui/widgets/layout/dynamic_grid.dart

import 'package:flutter/material.dart';
import '../../engine/json_widget_engine.dart';
import '../../models/widget_node.dart';

/// Renders children in a grid layout.
///
/// Supports both `children` and `properties.items` (which are parsed as WidgetNodes).
///
/// JSON example:
/// ```json
/// {
///   "type": "Grid",
///   "properties": {
///     "columns": 2,
///     "spacing": 12,
///     "runSpacing": 12,
///     "items": [ ... ]
///   },
///   "children": [ ... ]
/// }
/// ```
class DynamicGrid {
  const DynamicGrid._();

  static Widget build(WidgetNode node, BuildContext context, JsonWidgetEngine engine) {
    final columns = node.getInt('columns', 2) ?? 2;
    final spacing = node.getDouble('spacing', 12) ?? 12;
    final runSpacing = node.getDouble('runSpacing', 12) ??
        node.getDouble('run_spacing', 12) ?? 12;
    final childAspectRatio = node.getDouble('aspectRatio') ??
        node.getDouble('aspect_ratio', 1.0) ?? 1.0;

    // Gather items: from children or properties.items
    List<WidgetNode> items = node.children;
    if (items.isEmpty && node.properties['items'] is List) {
      items = (node.properties['items'] as List)
          .whereType<Map<String, dynamic>>()
          .map((item) => WidgetNode.fromJson(item))
          .toList();
    }

    if (items.isEmpty) return const SizedBox.shrink();

    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: columns,
        crossAxisSpacing: spacing,
        mainAxisSpacing: runSpacing,
        childAspectRatio: childAspectRatio,
      ),
      itemCount: items.length,
      itemBuilder: (context, index) {
        return engine.buildWidget(items[index], context);
      },
    );
  }
}
