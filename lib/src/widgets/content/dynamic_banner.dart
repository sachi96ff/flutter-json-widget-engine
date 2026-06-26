// lib/dynamic_ui/widgets/content/dynamic_banner.dart

import 'dart:async';
import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../engine/style_parser.dart';
import '../../engine/action_handler.dart';
import '../../models/widget_node.dart';

/// Renders a hero banner or image carousel.
///
/// JSON example:
/// ```json
/// {
///   "type": "Banner",
///   "properties": {
///     "auto_scroll": true,
///     "interval": 4,
///     "items": [
///       {
///         "image_url": "https://...",
///         "title": "New Mock Tests Available!",
///         "subtitle": "Attempt now",
///         "on_click": { "action": "navigate", "json_file": "mock_tests.json" }
///       }
///     ]
///   },
///   "style": { "height": 180, "radius": 16 }
/// }
/// ```
class DynamicBanner {
  const DynamicBanner._();

  static Widget build(WidgetNode node, BuildContext context) {
    final items = node.properties['items'];
    if (items == null || items is! List || items.isEmpty) {
      return const SizedBox.shrink();
    }

    final height = StyleParser.resolveHeight(node.style, context) ?? 180;
    final radius = node.style?.radius ?? 16.0;
    final autoScroll = node.getBool('auto_scroll', true);
    final interval = node.getInt('interval', 4);

    if (items.length == 1) {
      return _BannerItem(
        item: items[0] as Map<String, dynamic>,
        height: height,
        radius: radius,
      );
    }

    return _BannerCarousel(
      items: items.cast<Map<String, dynamic>>(),
      height: height,
      radius: radius,
      autoScroll: autoScroll,
      interval: interval ?? 4,
    );
  }
}

class _BannerCarousel extends StatefulWidget {
  final List<Map<String, dynamic>> items;
  final double height;
  final double radius;
  final bool autoScroll;
  final int interval;

  const _BannerCarousel({
    required this.items,
    required this.height,
    required this.radius,
    required this.autoScroll,
    required this.interval,
  });

  @override
  State<_BannerCarousel> createState() => _BannerCarouselState();
}

class _BannerCarouselState extends State<_BannerCarousel> {
  late final PageController _pageController;
  int _currentPage = 0;
  Timer? _timer;

  @override
  void initState() {
    super.initState();
    _pageController = PageController();
    if (widget.autoScroll && widget.items.length > 1) {
      _timer = Timer.periodic(
        Duration(seconds: widget.interval),
        (_) {
          if (!mounted) return;
          final next = (_currentPage + 1) % widget.items.length;
          _pageController.animateToPage(
            next,
            duration: const Duration(milliseconds: 400),
            curve: Curves.easeInOut,
          );
        },
      );
    }
  }

  @override
  void dispose() {
    _timer?.cancel();
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        SizedBox(
          height: widget.height,
          child: PageView.builder(
            controller: _pageController,
            itemCount: widget.items.length,
            onPageChanged: (i) => setState(() => _currentPage = i),
            itemBuilder: (_, i) => Padding(
              padding: const EdgeInsets.symmetric(horizontal: 2),
              child: _BannerItem(
                item: widget.items[i],
                height: widget.height,
                radius: widget.radius,
              ),
            ),
          ),
        ),
        if (widget.items.length > 1) ...[
          const SizedBox(height: 10),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: List.generate(widget.items.length, (i) {
              final isActive = i == _currentPage;
              return AnimatedContainer(
                duration: const Duration(milliseconds: 250),
                margin: const EdgeInsets.symmetric(horizontal: 3),
                width: isActive ? 20 : 8,
                height: 8,
                decoration: BoxDecoration(
                  color: isActive
                      ? const Color(0xFF1A3BCC)
                      : const Color(0xFF1A3BCC).withValues(alpha: 0.2),
                  borderRadius: BorderRadius.circular(4),
                ),
              );
            }),
          ),
        ],
      ],
    );
  }
}

class _BannerItem extends StatelessWidget {
  final Map<String, dynamic> item;
  final double height;
  final double radius;

  const _BannerItem({
    required this.item,
    required this.height,
    required this.radius,
  });

  @override
  Widget build(BuildContext context) {
    final imageUrl = (item['image_url'] ?? item['background_image']) as String?;
    final title = item['title'] as String?;
    final subtitle = item['subtitle'] as String?;
    final bgColorStr = item['background'] as String?;
    final bgColor = StyleParser.parseColor(bgColorStr);
    final gradientColors = item['gradient_colors'];
    final showOverlay = item['show_overlay'] as bool? ?? true;
    
    final isTransparent = bgColor == Colors.transparent || bgColorStr?.toLowerCase() == 'transparent';

    // Build click action
    VoidCallback? onTap;
    if (item['on_click'] is Map<String, dynamic>) {
      final action = ClickAction.fromJson(item['on_click'] as Map<String, dynamic>);
      onTap = ActionHandler.buildCallback(context, action: action, analytics: item["analytics"] != null ? AnalyticsConfig.fromJson(item["analytics"]) : null);
    }

    // Gradient
    Gradient? gradient;
    if (gradientColors is List && gradientColors.length >= 2) {
      gradient = LinearGradient(
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
        colors: gradientColors
            .map((c) => StyleParser.parseColor(c as String) ?? Colors.transparent)
            .toList(),
      );
    }

    return GestureDetector(
      onTap: onTap,
      child: Container(
        height: height,
        clipBehavior: Clip.antiAlias,
        decoration: BoxDecoration(
          color: bgColor ?? const Color(0xFF1A3BCC),
          gradient: gradient,
          borderRadius: BorderRadius.circular(radius),
          boxShadow: isTransparent
              ? null
              : [
                  BoxShadow(
                    color: const Color(0xFF1A3BCC).withValues(alpha: 0.15),
                    blurRadius: 16,
                    offset: const Offset(0, 6),
                  ),
                ],
        ),
        child: Stack(
          fit: StackFit.expand,
          children: [
            // Background image
            if (imageUrl != null && imageUrl.isNotEmpty)
              CachedNetworkImage(
                imageUrl: imageUrl,
                fit: BoxFit.cover,
                errorWidget: (context, url, error) => const SizedBox.shrink(),
              ),

            // Gradient overlay for text readability (can be disabled via show_overlay: false)
            if (showOverlay && (title != null || subtitle != null))
              Container(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [
                      Colors.transparent,
                      Colors.black.withValues(alpha: 0.6),
                    ],
                    stops: const [0.3, 1.0],
                  ),
                ),
              ),

            // Text content
            if (title != null || subtitle != null)
              Positioned(
                bottom: 16,
                left: 16,
                right: 16,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    if (title != null)
                      Text(
                        title,
                        style: GoogleFonts.plusJakartaSans(
                          fontSize: 18,
                          fontWeight: FontWeight.w700,
                          color: Colors.white,
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
                          color: Colors.white.withValues(alpha: 0.85),
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  ],
                ),
              ),
          ],
        ),
      ),
    );
  }
}
