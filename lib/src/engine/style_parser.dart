// lib/dynamic_ui/engine/style_parser.dart

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../models/widget_style.dart';

/// Converts [WidgetStyle] objects into Flutter styling primitives.
class StyleParser {
  const StyleParser._();

  // ─── Color Parsing ────────────────────────────────────────────

  /// Parse a hex color string like "#FF6B2B", "FF6B2B", 3-char hex like "#FFF",
  /// or named colors like "white", "black", "transparent", etc.
  static Color? parseColor(String? hex) {
    if (hex == null || hex.trim().isEmpty) return null;
    
    hex = hex.trim().toLowerCase();

    // Handle named colors
    switch (hex) {
      case 'white': return Colors.white;
      case 'black': return Colors.black;
      case 'transparent': return Colors.transparent;
      case 'red': return Colors.red;
      case 'green': return Colors.green;
      case 'blue': return Colors.blue;
      case 'yellow': return Colors.yellow;
      case 'orange': return Colors.orange;
      case 'purple': return Colors.purple;
      case 'grey':
      case 'gray': return Colors.grey;
    }

    hex = hex.replaceFirst('#', '');
    
    // Handle 3-character hex (e.g., FFF -> FFFFFF)
    if (hex.length == 3) {
      hex = '${hex[0]}${hex[0]}${hex[1]}${hex[1]}${hex[2]}${hex[2]}';
    }
    
    if (hex.length == 6) {
      // It's RRGGBB. Prepend FF for alpha (AARRGGBB)
      hex = 'ff$hex';
      final value = int.tryParse(hex, radix: 16);
      if (value != null) return Color(value);
    } else if (hex.length == 8) {
      // Editor sends RRGGBBAA, but Flutter expects AARRGGBB
      hex = '${hex.substring(6, 8)}${hex.substring(0, 6)}';
      final value = int.tryParse(hex, radix: 16);
      if (value != null) return Color(value);
    }
    return null;
  }

  // ─── BoxDecoration ────────────────────────────────────────────

  /// Build a [BoxDecoration] from a [WidgetStyle].
  static BoxDecoration? buildDecoration(WidgetStyle? style, BuildContext context) {
    if (style == null) return null;

    final bgColor = parseColor(style.background);
    final borderColor = parseColor(style.border);

    // Gradient
    Gradient? gradient;
    if (style.gradientColors != null && style.gradientColors!.length >= 2) {
      gradient = LinearGradient(
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
        colors: style.gradientColors!
            .map((c) => parseColor(c) ?? Colors.transparent)
            .toList(),
      );
    }

    final hasBorder = borderColor != null;
    final hasRadius = style.radius != null;
    final hasShadow = style.shadow;

    if (bgColor == null &&
        gradient == null &&
        !hasBorder &&
        !hasRadius &&
        !hasShadow) {
      return null;
    }

    return BoxDecoration(
      color: gradient == null ? bgColor : null,
      gradient: gradient,
      borderRadius: hasRadius ? BorderRadius.circular(style.radius!) : null,
      border: hasBorder
          ? Border.all(
              color: borderColor,
              width: style.borderWidth ?? 1,
            )
          : null,
      boxShadow: hasShadow
          ? [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.08),
                blurRadius: 12,
                offset: const Offset(0, 4),
              ),
            ]
          : null,
    );
  }

  // ─── TextStyle ────────────────────────────────────────────────

  /// Build a [TextStyle] from a [WidgetStyle], using Inter/PlusJakartaSans.
  static TextStyle buildTextStyle(WidgetStyle? style, BuildContext context,
      {double defaultFontSize = 14, String defaultWeight = 'normal'}) {
    final color = parseColor(style?.textColor) ??
        Theme.of(context).textTheme.bodyMedium?.color;
    final fontSize = style?.fontSize ?? defaultFontSize;
    final weight = _parseFontWeight(style?.fontWeight ?? defaultWeight);
    final letterSpacing = style?.letterSpacing;
    final lineHeight = style?.lineHeight;

    // Use PlusJakartaSans for bold/heavy headings, Inter for everything else
    if (weight.value >= FontWeight.w700.value) {
      return GoogleFonts.plusJakartaSans(
        fontSize: fontSize,
        fontWeight: weight,
        color: color,
        letterSpacing: letterSpacing,
        height: lineHeight,
      );
    }

    return GoogleFonts.inter(
      fontSize: fontSize,
      fontWeight: weight,
      color: color,
      letterSpacing: letterSpacing,
      height: lineHeight,
    );
  }

  static FontWeight _parseFontWeight(String weight) {
    switch (weight.toLowerCase()) {
      case 'thin':
      case '100':
        return FontWeight.w100;
      case 'extralight':
      case '200':
        return FontWeight.w200;
      case 'light':
      case '300':
        return FontWeight.w300;
      case 'normal':
      case 'regular':
      case '400':
        return FontWeight.w400;
      case 'medium':
      case '500':
        return FontWeight.w500;
      case 'semibold':
      case 'semi_bold':
      case '600':
        return FontWeight.w600;
      case 'bold':
      case '700':
        return FontWeight.w700;
      case 'extrabold':
      case 'extra_bold':
      case '800':
        return FontWeight.w800;
      case 'black':
      case '900':
        return FontWeight.w900;
      default:
        return FontWeight.w400;
    }
  }

  // ─── TextAlign ────────────────────────────────────────────────

  static TextAlign parseTextAlign(String? align) {
    switch (align?.toLowerCase()) {
      case 'center':
        return TextAlign.center;
      case 'right':
      case 'end':
        return TextAlign.right;
      case 'justify':
        return TextAlign.justify;
      case 'left':
      case 'start':
      default:
        return TextAlign.left;
    }
  }

  // ─── Alignment ────────────────────────────────────────────────

  static Alignment parseAlignment(String? align) {
    switch (align?.toLowerCase()) {
      case 'topleft':
      case 'top_left':
        return Alignment.topLeft;
      case 'topcenter':
      case 'top_center':
      case 'top':
        return Alignment.topCenter;
      case 'topright':
      case 'top_right':
        return Alignment.topRight;
      case 'centerleft':
      case 'center_left':
      case 'left':
        return Alignment.centerLeft;
      case 'centerright':
      case 'center_right':
      case 'right':
        return Alignment.centerRight;
      case 'bottomleft':
      case 'bottom_left':
        return Alignment.bottomLeft;
      case 'bottomcenter':
      case 'bottom_center':
      case 'bottom':
        return Alignment.bottomCenter;
      case 'bottomright':
      case 'bottom_right':
        return Alignment.bottomRight;
      case 'center':
      default:
        return Alignment.center;
    }
  }

  // ─── MainAxisAlignment ────────────────────────────────────────

  static MainAxisAlignment parseMainAxisAlignment(String? align) {
    switch (align?.toLowerCase()) {
      case 'center':
        return MainAxisAlignment.center;
      case 'end':
        return MainAxisAlignment.end;
      case 'spacebetween':
      case 'space_between':
        return MainAxisAlignment.spaceBetween;
      case 'spacearound':
      case 'space_around':
        return MainAxisAlignment.spaceAround;
      case 'spaceevenly':
      case 'space_evenly':
        return MainAxisAlignment.spaceEvenly;
      case 'start':
      default:
        return MainAxisAlignment.start;
    }
  }

  // ─── CrossAxisAlignment ───────────────────────────────────────

  static CrossAxisAlignment parseCrossAxisAlignment(String? align) {
    switch (align?.toLowerCase()) {
      case 'center':
        return CrossAxisAlignment.center;
      case 'end':
        return CrossAxisAlignment.end;
      case 'stretch':
        return CrossAxisAlignment.stretch;
      case 'start':
      default:
        return CrossAxisAlignment.start;
    }
  }

  // ─── Width / Height ───────────────────────────────────────────

  /// Resolve width from style. Returns null for "auto" or unset.
  static double? resolveWidth(WidgetStyle? style, BuildContext context) {
    return _resolveDimension(style?.width, context, useHeight: false);
  }

  /// Resolve height from style. Returns null for "auto" or unset.
  static double? resolveHeight(WidgetStyle? style, BuildContext context) {
    return _resolveDimension(style?.height, context, useHeight: true);
  }

  static double? _resolveDimension(dynamic value, BuildContext context,
      {bool useHeight = false}) {
    if (value == null || value == 'auto') return null;

    if (value is num) return value.toDouble();

    if (value is String) {
      if (value.endsWith('%')) {
        final percent = double.tryParse(value.replaceAll('%', ''));
        if (percent != null) {
          final size = MediaQuery.of(context).size;
          final reference = useHeight ? size.height : size.width;
          return reference * (percent / 100);
        }
      }
      return double.tryParse(value);
    }

    return null;
  }

  // ─── BoxFit ───────────────────────────────────────────────────

  static BoxFit parseBoxFit(String? fit) {
    switch (fit?.toLowerCase()) {
      case 'cover':
        return BoxFit.cover;
      case 'contain':
        return BoxFit.contain;
      case 'fill':
        return BoxFit.fill;
      case 'fitwidth':
      case 'fit_width':
        return BoxFit.fitWidth;
      case 'fitheight':
      case 'fit_height':
        return BoxFit.fitHeight;
      case 'none':
        return BoxFit.none;
      case 'scaledown':
      case 'scale_down':
        return BoxFit.scaleDown;
      default:
        return BoxFit.cover;
    }
  }
}
