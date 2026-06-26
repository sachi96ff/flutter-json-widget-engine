// lib/dynamic_ui/widgets/interactive/dynamic_button.dart

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../engine/style_parser.dart';
import '../../engine/action_handler.dart';
import '../../models/widget_node.dart';


/// Renders a button (filled, outlined, or text variant).
///
/// JSON example:
/// ```json
/// {
///   "type": "Button",
///   "properties": {
///     "text": "Start Practice",
///     "variant": "filled",
///     "icon": "play",
///     "on_click": { "action": "navigate_named", "route": "/practice" }
///   },
///   "style": { "radius": 12, "background": "#1A3BCC" }
/// }
/// ```
class DynamicButton {
  const DynamicButton._();

  static Widget build(WidgetNode node, BuildContext context) {
    final text = node.getString('text', 'Button');
    final variant = node.getString('variant', 'filled'); // filled, outlined, text
    final iconName = node.getString('icon');
    final disabled = node.getBool('disabled');
    final fullWidth = node.getBool('full_width', false);

    final style = node.style;
    final bgColor = StyleParser.parseColor(style?.background) ?? Theme.of(context).colorScheme.primary;
    final textColor = StyleParser.parseColor(style?.textColor);
    final borderColor = StyleParser.parseColor(style?.border);
    final radius = style?.radius ?? 12.0;
    final fontSize = style?.fontSize ?? 14.0;

    final onTap = disabled
        ? null
        : (ActionHandler.buildCallback(context, action: node.clickAction, analytics: node.analytics) ?? () {});

    // Build gradient if gradient colors provided
    Gradient? gradient;
    if (style?.gradientColors != null && style!.gradientColors!.length >= 2) {
      gradient = LinearGradient(
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
        colors: style.gradientColors!
            .map((c) => StyleParser.parseColor(c) ?? Colors.transparent)
            .toList(),
      );
    }

    // Icon widget
    Widget? iconWidget;
    if (iconName != null) {
      // Reuse icon mapping from DynamicIcon? For simplicity, use basic Material icons
      iconWidget = Icon(
        _resolveBasicIcon(iconName),
        size: 16,
        color: variant == 'filled'
            ? (textColor ?? Colors.white)
            : (textColor ?? bgColor),
      );
    }

    Widget button;

    switch (variant) {
      case 'outlined':
        button = _buildOutlined(
          text: text ?? 'Button',
          icon: iconWidget,
          bgColor: bgColor,
          textColor: textColor,
          borderColor: borderColor,
          radius: radius,
          fontSize: fontSize,
          onTap: onTap,
        );
        break;

      case 'text':
        button = _buildText(
          text: text ?? 'Button',
          icon: iconWidget,
          textColor: textColor ?? bgColor,
          fontSize: fontSize,
          onTap: onTap,
        );
        break;

      case 'filled':
      default:
        button = _buildFilled(
          text: text ?? 'Button',
          icon: iconWidget,
          bgColor: bgColor,
          textColor: textColor,
          radius: radius,
          fontSize: fontSize,
          gradient: gradient,
          onTap: onTap,
        );
        break;
    }

    if (fullWidth) {
      return SizedBox(
        width: double.infinity,
        child: button,
      );
    }

    // Wrap in Align to prevent it from stretching if the parent Column has CrossAxisAlignment.stretch
    return Align(
      alignment: Alignment.centerLeft,
      child: button,
    );
  }

  static Widget _buildFilled({
    required String text,
    Widget? icon,
    required Color bgColor,
    Color? textColor,
    required double radius,
    required double fontSize,
    Gradient? gradient,
    VoidCallback? onTap,
  }) {
    final fgColor = textColor ?? Colors.white;

    if (gradient != null) {
      return GestureDetector(
        onTap: onTap,
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
          decoration: BoxDecoration(
            gradient: gradient,
            borderRadius: BorderRadius.circular(radius),
            boxShadow: [
              BoxShadow(
                color: bgColor.withValues(alpha: 0.3),
                blurRadius: 8,
                offset: const Offset(0, 3),
              ),
            ],
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              if (icon != null) ...[icon, const SizedBox(width: 8)],
              Text(
                text,
                style: GoogleFonts.inter(
                  fontSize: fontSize,
                  fontWeight: FontWeight.w600,
                  color: fgColor,
                ),
              ),
            ],
          ),
        ),
      );
    }

    return ElevatedButton(
      onPressed: onTap,
      style: ElevatedButton.styleFrom(
        backgroundColor: bgColor,
        foregroundColor: fgColor,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(radius),
        ),
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
        elevation: 0,
        textStyle: GoogleFonts.inter(
          fontSize: fontSize,
          fontWeight: FontWeight.w600,
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          if (icon != null) ...[icon, const SizedBox(width: 8)],
          Text(text),
        ],
      ),
    );
  }

  static Widget _buildOutlined({
    required String text,
    Widget? icon,
    required Color bgColor,
    Color? textColor,
    Color? borderColor,
    required double radius,
    required double fontSize,
    VoidCallback? onTap,
  }) {
    final fgColor = textColor ?? bgColor;

    return OutlinedButton(
      onPressed: onTap,
      style: OutlinedButton.styleFrom(
        foregroundColor: fgColor,
        side: BorderSide(color: borderColor ?? bgColor, width: 1.5),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(radius),
        ),
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
        textStyle: GoogleFonts.inter(
          fontSize: fontSize,
          fontWeight: FontWeight.w600,
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          if (icon != null) ...[icon, const SizedBox(width: 8)],
          Text(text),
        ],
      ),
    );
  }

  static Widget _buildText({
    required String text,
    Widget? icon,
    required Color textColor,
    required double fontSize,
    VoidCallback? onTap,
  }) {
    return TextButton(
      onPressed: onTap,
      style: TextButton.styleFrom(
        foregroundColor: textColor,
        textStyle: GoogleFonts.inter(
          fontSize: fontSize,
          fontWeight: FontWeight.w600,
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (icon != null) ...[icon, const SizedBox(width: 8)],
          Text(text),
        ],
      ),
    );
  }

  static IconData _resolveBasicIcon(String name) {
    const map = <String, IconData>{
      'play': Icons.play_arrow_rounded,
      'arrow_right': Icons.arrow_forward_rounded,
      'check': Icons.check_rounded,
      'star': Icons.star_rounded,
      'add': Icons.add_rounded,
      'download': Icons.download_rounded,
      'share': Icons.share_rounded,
      'refresh': Icons.refresh_rounded,
      'lock': Icons.lock_rounded,
      'bookmark': Icons.bookmark_rounded,
      'heart': Icons.favorite_rounded,
      'send': Icons.send_rounded,
    };
    return map[name.toLowerCase()] ?? Icons.circle;
  }
}
