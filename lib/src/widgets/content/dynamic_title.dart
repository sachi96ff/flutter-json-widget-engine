// lib/dynamic_ui/widgets/content/dynamic_title.dart

import 'package:flutter/material.dart';
import '../../engine/style_parser.dart';
import '../../engine/action_handler.dart';
import '../../models/widget_node.dart';

/// Renders a section title/heading.
///
/// JSON example:
/// ```json
/// {
///   "type": "Title",
///   "properties": { "text": "Continue Learning" },
///   "style": { "fontSize": 20, "fontWeight": "bold", "textColor": "#1A1A1A" }
/// }
/// ```
class DynamicTitle {
  const DynamicTitle._();

  static Widget build(WidgetNode node, BuildContext context) {
    final text = node.getString('text', '');
    final textStyle = StyleParser.buildTextStyle(
      node.style,
      context,
      defaultFontSize: 20,
      defaultWeight: 'bold',
    );
    final textAlign = StyleParser.parseTextAlign(
      node.style?.textAlign ?? node.style?.alignment,
    );

    final onTap = ActionHandler.buildCallback(context, action: node.clickAction, analytics: node.analytics);

    Widget titleWidget = Text(
      text ?? '',
      style: textStyle,
      textAlign: textAlign,
      maxLines: node.style?.maxLines,
      overflow: node.style?.maxLines != null
          ? TextOverflow.ellipsis
          : null,
    );

    if (onTap != null) {
      titleWidget = GestureDetector(
        onTap: onTap,
        child: titleWidget,
      );
    }

    return titleWidget;
  }
}
