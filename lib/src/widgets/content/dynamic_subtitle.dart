// lib/dynamic_ui/widgets/content/dynamic_subtitle.dart

import 'package:flutter/material.dart';
import '../../engine/style_parser.dart';
import '../../engine/action_handler.dart';
import '../../models/widget_node.dart';

/// Renders a subtitle / sub-heading.
///
/// JSON example:
/// ```json
/// {
///   "type": "Subtitle",
///   "properties": { "text": "Recommended for you" },
///   "style": { "fontSize": 16, "fontWeight": "semibold", "textColor": "#6B7280" }
/// }
/// ```
class DynamicSubtitle {
  const DynamicSubtitle._();

  static Widget build(WidgetNode node, BuildContext context) {
    final text = node.getString('text', '');
    final textStyle = StyleParser.buildTextStyle(
      node.style,
      context,
      defaultFontSize: 16,
      defaultWeight: 'semibold',
    );
    final textAlign = StyleParser.parseTextAlign(
      node.style?.textAlign ?? node.style?.alignment,
    );

    final onTap = ActionHandler.buildCallback(context, action: node.clickAction, analytics: node.analytics);

    Widget subtitleWidget = Text(
      text ?? '',
      style: textStyle,
      textAlign: textAlign,
      maxLines: node.style?.maxLines,
      overflow: node.style?.maxLines != null
          ? TextOverflow.ellipsis
          : null,
    );

    if (onTap != null) {
      subtitleWidget = GestureDetector(
        onTap: onTap,
        child: subtitleWidget,
      );
    }

    return subtitleWidget;
  }
}
