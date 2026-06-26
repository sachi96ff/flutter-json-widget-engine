// lib/dynamic_ui/widgets/content/dynamic_icon.dart

import 'package:flutter/material.dart';
import 'package:lucide_icons/lucide_icons.dart';
import '../../engine/style_parser.dart';
import '../../models/widget_node.dart';

/// Renders an icon widget.
///
/// JSON example:
/// ```json
/// {
///   "type": "Icon",
///   "properties": { "icon": "star", "size": 24 },
///   "style": { "textColor": "#F59E0B" }
/// }
/// ```
class DynamicIcon {
  const DynamicIcon._();

  static Widget build(WidgetNode node, BuildContext context) {
    final iconName = node.getString('icon', 'circle');
    final size = node.getDouble('size', 24);
    final color = StyleParser.parseColor(node.style?.textColor) ??
        Theme.of(context).iconTheme.color;

    final iconData = resolveIcon(iconName ?? 'circle');

    return Icon(
      iconData,
      size: size,
      color: color,
    );
  }

  /// Map common icon names to Lucide/Material icons.
  static IconData resolveIcon(String name) {
    // Lucide icons mapping (most common)
    final lucideMap = <String, IconData>{
      'home': LucideIcons.home,
      'search': LucideIcons.search,
      'bell': LucideIcons.bell,
      'star': LucideIcons.star,
      'heart': LucideIcons.heart,
      'bookmark': LucideIcons.bookmark,
      'play': LucideIcons.play,
      'pause': LucideIcons.pause,
      'check': LucideIcons.check,
      'check_circle': LucideIcons.checkCircle,
      'x': LucideIcons.x,
      'plus': LucideIcons.plus,
      'minus': LucideIcons.minus,
      'arrow_right': LucideIcons.arrowRight,
      'arrow_left': LucideIcons.arrowLeft,
      'chevron_right': LucideIcons.chevronRight,
      'chevron_left': LucideIcons.chevronLeft,
      'chevron_down': LucideIcons.chevronDown,
      'chevron_up': LucideIcons.chevronUp,
      'clock': LucideIcons.clock,
      'calendar': LucideIcons.calendar,
      'user': LucideIcons.user,
      'users': LucideIcons.users,
      'settings': LucideIcons.settings,
      'share': LucideIcons.share2,
      'download': LucideIcons.download,
      'upload': LucideIcons.upload,
      'edit': LucideIcons.edit,
      'trash': LucideIcons.trash,
      'copy': LucideIcons.copy,
      'lock': LucideIcons.lock,
      'unlock': LucideIcons.unlock,
      'eye': LucideIcons.eye,
      'eye_off': LucideIcons.eyeOff,
      'info': LucideIcons.info,
      'alert': LucideIcons.alertTriangle,
      'warning': LucideIcons.alertTriangle,
      'target': LucideIcons.target,
      'trophy': LucideIcons.trophy,
      'medal': LucideIcons.medal,
      'crown': LucideIcons.crown,
      'flame': LucideIcons.flame,
      'zap': LucideIcons.zap,
      'lightning': LucideIcons.zap,
      'book': LucideIcons.bookOpen,
      'book_open': LucideIcons.bookOpen,
      'trending_up': LucideIcons.trendingUp,
      'trending_down': LucideIcons.trendingDown,
      'bar_chart': LucideIcons.barChart2,
      'pie_chart': LucideIcons.pieChart,
      'refresh': LucideIcons.refreshCw,
      'filter': LucideIcons.filter,
      'tag': LucideIcons.tag,
      'link': LucideIcons.link,
      'external_link': LucideIcons.externalLink,
      'globe': LucideIcons.globe,
      'map': LucideIcons.map,
      'image': LucideIcons.image,
      'camera': LucideIcons.camera,
      'file': LucideIcons.file,
      'folder': LucideIcons.folder,
      'inbox': LucideIcons.inbox,
      'send': LucideIcons.send,
      'message': LucideIcons.messageSquare,
      'phone': LucideIcons.phone,
      'mail': LucideIcons.mail,
      'wifi': LucideIcons.wifi,
      'battery': LucideIcons.battery,
      'volume': LucideIcons.volume2,
      'music': LucideIcons.music,
      'video': LucideIcons.video,
      'mic': LucideIcons.mic,
      'award': LucideIcons.award,
      'gift': LucideIcons.gift,
      'code': LucideIcons.code,
      'terminal': LucideIcons.terminal,
      'cpu': LucideIcons.cpu,
      'database': LucideIcons.database,
      'server': LucideIcons.server,
      'cloud': LucideIcons.cloud,
      'sun': LucideIcons.sun,
      'moon': LucideIcons.moon,
      'circle': LucideIcons.circle,
      'square': LucideIcons.square,
      'triangle': LucideIcons.triangle,
      'hexagon': LucideIcons.hexagon,
      'layout_grid': LucideIcons.layoutGrid,
      'list': LucideIcons.list,
      'grid': LucideIcons.grid,
      'menu': LucideIcons.menu,
      'more_horizontal': LucideIcons.moreHorizontal,
      'more_vertical': LucideIcons.moreVertical,
    };

    return lucideMap[name.toLowerCase()] ?? LucideIcons.circle;
  }
}
