// lib/dynamic_ui/widgets/interactive/dynamic_icon_button.dart

import 'package:flutter/material.dart';
import 'package:lucide_icons/lucide_icons.dart';
import '../../engine/style_parser.dart';
import '../../engine/action_handler.dart';
import '../../models/widget_node.dart';

/// Renders a circular icon button.
///
/// JSON example:
/// ```json
/// {
///   "type": "IconButton",
///   "properties": {
///     "icon": "play",
///     "size": 20,
///     "on_click": { "action": "navigate_named", "route": "/practice" }
///   },
///   "style": {
///     "background": "#1A3BCC",
///     "textColor": "#FFFFFF",
///     "radius": 16
///   }
/// }
/// ```
class DynamicIconButton {
  const DynamicIconButton._();

  static Widget build(WidgetNode node, BuildContext context) {
    final iconName = node.getString('icon', 'circle');
    final size = node.getDouble('size', 20);
    final containerSize = node.getDouble('container_size', 40);
    final style = node.style;

    final bgColor = StyleParser.parseColor(style?.background);
    final iconColor = StyleParser.parseColor(style?.textColor) ??
        Theme.of(context).iconTheme.color;
    final radius = style?.radius ?? 16.0;

    final onTap = ActionHandler.buildCallback(context, action: node.clickAction, analytics: node.analytics);

    // Resolve icon — reuse DynamicIcon's mapper or fallback
    final iconData = _resolveIcon(iconName ?? 'circle');

    return Align(
      alignment: Alignment.centerLeft,
      child: GestureDetector(
        onTap: onTap,
        child: Container(
          width: containerSize,
          height: containerSize,
          decoration: BoxDecoration(
            color: bgColor ?? Colors.transparent,
            borderRadius: BorderRadius.circular(radius),
          ),
          child: Center(
            child: Icon(
              iconData,
              size: size,
              color: iconColor,
            ),
          ),
        ),
      ),
    );
  }

  static IconData _resolveIcon(String name) {
    const map = <String, IconData>{
      'play': LucideIcons.play,
      'arrow_right': LucideIcons.arrowRight,
      'chevron_right': LucideIcons.chevronRight,
      'check': LucideIcons.check,
      'star': LucideIcons.star,
      'heart': LucideIcons.heart,
      'bookmark': LucideIcons.bookmark,
      'share': LucideIcons.share2,
      'more': LucideIcons.moreHorizontal,
      'close': LucideIcons.x,
      'search': LucideIcons.search,
      'filter': LucideIcons.filter,
      'settings': LucideIcons.settings,
      'edit': LucideIcons.edit,
      'delete': LucideIcons.trash,
      'refresh': LucideIcons.refreshCw,
      'lock': LucideIcons.lock,
      'bell': LucideIcons.bell,
      'copy': LucideIcons.copy,
      'download': LucideIcons.download,
      'external_link': LucideIcons.externalLink,
    };
    return map[name.toLowerCase()] ?? LucideIcons.circle;
  }
}
