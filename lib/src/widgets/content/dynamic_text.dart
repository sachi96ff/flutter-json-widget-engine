// lib/dynamic_ui/widgets/content/dynamic_text.dart

import 'package:flutter/material.dart';
import '../../engine/style_parser.dart';
import '../../engine/action_handler.dart';
import '../../models/widget_node.dart';

/// Renders body text / paragraph.
///
/// JSON example:
/// ```json
/// {
///   "type": "Text",
///   "properties": { "text": "Practice daily to improve your scores.", "maxLines": 3 },
///   "style": { "fontSize": 14, "textColor": "#6B7280" }
/// }
/// ```
class DynamicText {
  const DynamicText._();

  static Widget build(WidgetNode node, BuildContext context) {
    final text = node.getString('text', '');
    final maxLines = node.getInt('maxLines') ?? node.style?.maxLines;
    final textStyle = StyleParser.buildTextStyle(
      node.style,
      context,
      defaultFontSize: 14,
      defaultWeight: 'normal',
    );
    final textAlign = StyleParser.parseTextAlign(
      node.style?.textAlign ?? node.style?.alignment,
    );

    final onTap = ActionHandler.buildCallback(context, action: node.clickAction, analytics: node.analytics);

    Widget textWidget = Text(
      text ?? '',
      style: textStyle,
      textAlign: textAlign,
      maxLines: maxLines,
      overflow: maxLines != null ? TextOverflow.ellipsis : null,
    );

    if (onTap != null) {
      textWidget = GestureDetector(
        onTap: onTap,
        child: textWidget,
      );
    }

    return textWidget;
  }
}
