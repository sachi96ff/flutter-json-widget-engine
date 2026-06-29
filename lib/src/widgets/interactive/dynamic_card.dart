// lib/dynamic_ui/widgets/interactive/dynamic_card.dart

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:cached_network_image/cached_network_image.dart';
import '../../engine/style_parser.dart';
import '../../engine/action_handler.dart';
import '../../models/widget_node.dart';
import '../../engine/json_widget_engine.dart';


/// Renders a styled card widget.
///
/// If `children` are provided, renders them inside the card.
/// Otherwise, renders using `title`, `subtitle`, `body`, `image_url` properties.
///
/// JSON example:
/// ```json
/// {
///   "type": "Card",
///   "properties": {
///     "title": "SSC CGL 2024",
///     "subtitle": "120 questions · 60 min",
///     "image_url": "https://...",
///     "icon": "book",
///     "on_click": { "action": "navigate", "json_file": "exam.json" }
///   },
///   "style": { "radius": 16, "shadow": true, "padding": 16 }
/// }
/// ```
class DynamicCard {
  const DynamicCard._();

  static Widget build(WidgetNode node, BuildContext context, JsonWidgetEngine engine) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final style = node.style;

    // Defaults matching existing app style
    final bgColor = StyleParser.parseColor(style?.background) ??
        (isDark ? Theme.of(context).colorScheme.surfaceContainerHighest : Theme.of(context).colorScheme.surface);
    final borderColor = StyleParser.parseColor(style?.border) ??
        Theme.of(context).colorScheme.outlineVariant;
    final radius = style?.radius ?? 16.0;
    final padding = style?.padding ?? const EdgeInsets.all(16);
    final margin = style?.margin;
    final hasShadow = style?.shadow ?? false;
    final width = StyleParser.resolveWidth(style, context);
    final height = StyleParser.resolveHeight(style, context);
    final backgroundImage = style?.backgroundImage;
    final backgroundFit = style?.backgroundFit;

    // Build click action
    final onTap = ActionHandler.buildCallback(context, action: node.clickAction, analytics: node.analytics);

    Widget cardContent;

    // If has children, render them (custom card layout)
    if (node.children.isNotEmpty) {
      final alignStr = node.getString('alignment') ?? 'start';
      CrossAxisAlignment crossAlign;
      MainAxisAlignment mainAlign;
      switch (alignStr) {
        case 'center':
          crossAlign = CrossAxisAlignment.center;
          mainAlign = MainAxisAlignment.center;
          break;
        case 'end':
          crossAlign = CrossAxisAlignment.end;
          mainAlign = MainAxisAlignment.start;
          break;
        default:
          crossAlign = CrossAxisAlignment.start;
          mainAlign = MainAxisAlignment.start;
          break;
      }

      cardContent = Column(
        crossAxisAlignment: crossAlign,
        mainAxisAlignment: mainAlign,
        mainAxisSize: MainAxisSize.min,
        children: node.children.map((child) => engine.buildWidget(child, context)).toList(),
      );
    } else {
      // Default card layout from properties
      cardContent = _buildDefaultContent(node, context, isDark);
    }

    // Build decoration with optional background image
    DecorationImage? decorationImage;
    if (backgroundImage != null && backgroundImage.isNotEmpty) {
      BoxFit fit;
      switch (backgroundFit) {
        case 'contain': fit = BoxFit.contain; break;
        case 'fill': fit = BoxFit.fill; break;
        default: fit = BoxFit.cover; break;
      }
      decorationImage = DecorationImage(
        image: NetworkImage(backgroundImage),
        fit: fit,
      );
    }

    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: width,
        height: height,
        padding: padding,
        margin: margin,
        clipBehavior: Clip.antiAlias,
        decoration: BoxDecoration(
          color: decorationImage != null ? null : bgColor,
          borderRadius: BorderRadius.circular(radius),
          border: Border.all(color: borderColor),
          image: decorationImage,
          boxShadow: hasShadow
              ? [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.06),
                    blurRadius: 12,
                    offset: const Offset(0, 4),
                  ),
                ]
              : null,
        ),
        child: cardContent,
      ),
    );
  }

  static Widget _buildDefaultContent(
      WidgetNode node, BuildContext context, bool isDark) {
    final title = node.getString('title');
    final subtitle = node.getString('subtitle');
    final body = node.getString('body');
    final imageUrl = node.getString('image_url');
    final emoji = node.getString('emoji');

    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Left: emoji or image
        if (emoji != null) ...[
          Container(
            width: 48,
            height: 48,
            decoration: BoxDecoration(
              color: const Color(0xFF1A3BCC).withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(14),
            ),
            child: Center(
              child: Text(emoji, style: const TextStyle(fontSize: 22)),
            ),
          ),
          const SizedBox(width: 14),
        ] else if (imageUrl != null) ...[
          ClipRRect(
            borderRadius: BorderRadius.circular(12),
            child: CachedNetworkImage(
              imageUrl: imageUrl,
              width: 48,
              height: 48,
              fit: BoxFit.cover,
              errorWidget: (context, url, error) => Container(
                width: 48,
                height: 48,
                color: Colors.grey.withValues(alpha: 0.1),
                child: const Icon(Icons.image, size: 20),
              ),
            ),
          ),
          const SizedBox(width: 14),
        ],

        // Right: text content
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              if (title != null)
                Text(
                  title,
                  style: GoogleFonts.plusJakartaSans(
                    fontSize: 15,
                    fontWeight: FontWeight.w700,
                    color: isDark ? Colors.white : Colors.black87,
                  ),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
              if (subtitle != null) ...[
                const SizedBox(height: 4),
                Text(
                  subtitle,
                  style: GoogleFonts.inter(
                    fontSize: 13,
                    color: isDark ? Colors.white70 : Colors.black54,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
              if (body != null) ...[
                const SizedBox(height: 6),
                Text(
                  body,
                  style: GoogleFonts.inter(
                    fontSize: 13,
                    color: isDark ? Colors.white : Colors.black87,
                    height: 1.5,
                  ),
                  maxLines: 3,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ],
          ),
        ),
      ],
    );
  }
}
