// lib/dynamic_ui/widgets/content/dynamic_image.dart

import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import '../../engine/style_parser.dart';
import '../../models/widget_node.dart';

/// Renders an image from network URL or local asset.
///
/// JSON example:
/// ```json
/// {
///   "type": "Image",
///   "properties": {
///     "url": "https://example.com/image.png",
///     "fit": "cover",
///     "placeholder": "assets/images/placeholder.png"
///   },
///   "style": { "width": "100%", "height": 200, "radius": 16 }
/// }
/// ```
class DynamicImage {
  const DynamicImage._();

  static Widget build(WidgetNode node, BuildContext context) {
    final url = node.getString('url') ?? node.getString('image_url');
    final asset = node.getString('asset');
    final fit = StyleParser.parseBoxFit(node.getString('fit', 'cover'));
    final width = StyleParser.resolveWidth(node.style, context);
    final height = StyleParser.resolveHeight(node.style, context);
    final radius = node.style?.radius ?? 0;

    Widget image;

    if (url != null && url.isNotEmpty) {
      // Network image with caching
      image = CachedNetworkImage(
        imageUrl: url,
        width: width,
        height: height,
        fit: fit,
        placeholder: (context, url) => Container(
          width: width,
          height: height ?? 100,
          decoration: BoxDecoration(
            color: Theme.of(context).brightness == Brightness.dark
                ? const Color(0xFF1A2040)
                : const Color(0xFFE4EAF8),
            borderRadius: BorderRadius.circular(radius),
          ),
          child: const Center(
            child: SizedBox(
              width: 24,
              height: 24,
              child: CircularProgressIndicator(strokeWidth: 2),
            ),
          ),
        ),
        errorWidget: (context, url, error) => Container(
          width: width,
          height: height ?? 100,
          decoration: BoxDecoration(
            color: Theme.of(context).brightness == Brightness.dark
                ? const Color(0xFF1A2040)
                : const Color(0xFFE4EAF8),
            borderRadius: BorderRadius.circular(radius),
          ),
          child: const Center(
            child: Icon(Icons.broken_image_outlined, size: 24),
          ),
        ),
      );
    } else if (asset != null && asset.isNotEmpty) {
      // Local asset
      image = Image.asset(
        asset,
        width: width,
        height: height,
        fit: fit,
        errorBuilder: (context, error, stackTrace) => Container(
          width: width,
          height: height ?? 100,
          color: Colors.grey.withValues(alpha: 0.1),
          child: const Center(
            child: Icon(Icons.image_not_supported_outlined, size: 24),
          ),
        ),
      );
    } else {
      // No image source
      return SizedBox(
        width: width,
        height: height ?? 100,
      );
    }

    // Apply border radius
    if (radius > 0) {
      image = ClipRRect(
        borderRadius: BorderRadius.circular(radius),
        child: image,
      );
    }

    return image;
  }
}
