// lib/dynamic_ui/models/widget_style.dart

import 'package:flutter/material.dart';

/// Parsed style object from JSON.
///
/// Supports all style properties: background, radius, padding, margin,
/// border, shadow, width, height, textColor, fontSize, fontWeight, alignment.
class WidgetStyle {
  final String? background;
  final double? radius;
  final EdgeInsets? padding;
  final EdgeInsets? margin;
  final String? border;
  final double? borderWidth;
  final bool shadow;
  final dynamic width; // String ("100%", "auto") or num
  final dynamic height; // String ("auto") or num
  final String? textColor;
  final double? fontSize;
  final String? fontWeight;
  final String? alignment;
  final String? gradient;
  final List<String>? gradientColors;
  final double? opacity;
  final double? elevation;
  final String? overflow;
  final int? maxLines;
  final double? letterSpacing;
  final double? lineHeight;
  final String? textAlign;
  final String? backgroundImage;
  final String? backgroundFit;

  const WidgetStyle({
    this.background,
    this.radius,
    this.padding,
    this.margin,
    this.border,
    this.borderWidth,
    this.shadow = false,
    this.width,
    this.height,
    this.textColor,
    this.fontSize,
    this.fontWeight,
    this.alignment,
    this.gradient,
    this.gradientColors,
    this.opacity,
    this.elevation,
    this.overflow,
    this.maxLines,
    this.letterSpacing,
    this.lineHeight,
    this.textAlign,
    this.backgroundImage,
    this.backgroundFit,
  });

  factory WidgetStyle.fromJson(Map<String, dynamic> json) {
    return WidgetStyle(
      background: json['background'] as String?,
      radius: _toDouble(json['radius']),
      padding: parseEdgeInsets(json['padding']),
      margin: parseEdgeInsets(json['margin']),
      border: json['border'] as String?,
      borderWidth: _toDouble(json['borderWidth'] ?? json['border_width']),
      shadow: json['shadow'] == true,
      width: json['width'],
      height: json['height'],
      textColor: (json['textColor'] ?? json['text_color']) as String?,
      fontSize: _toDouble(json['fontSize'] ?? json['font_size']),
      fontWeight: (json['fontWeight'] ?? json['font_weight']) as String?,
      alignment: json['alignment'] as String?,
      gradient: json['gradient'] as String?,
      gradientColors: json['gradientColors'] is List
          ? (json['gradientColors'] as List).cast<String>()
          : null,
      opacity: _toDouble(json['opacity']),
      elevation: _toDouble(json['elevation']),
      overflow: json['overflow'] as String?,
      maxLines: json['maxLines'] is int
          ? json['maxLines'] as int
          : null,
      letterSpacing: _toDouble(json['letterSpacing'] ?? json['letter_spacing']),
      lineHeight: _toDouble(json['lineHeight'] ?? json['line_height']),
      textAlign: (json['textAlign'] ?? json['text_align']) as String?,
      backgroundImage: (json['backgroundImage'] ?? json['background_image']) as String?,
      backgroundFit: (json['backgroundFit'] ?? json['background_fit']) as String?,
    );
  }

  /// Parse EdgeInsets from JSON — supports:
  /// - number: uniform padding
  /// - object: { top, bottom, left, right }
  /// - object: { vertical, horizontal }
  static EdgeInsets? parseEdgeInsets(dynamic value) {
    if (value == null) return null;

    if (value is num) {
      return EdgeInsets.all(value.toDouble());
    }

    if (value is Map<String, dynamic>) {
      // Check for vertical/horizontal shorthand
      if (value.containsKey('vertical') || value.containsKey('horizontal')) {
        return EdgeInsets.symmetric(
          vertical: _toDouble(value['vertical']) ?? 0,
          horizontal: _toDouble(value['horizontal']) ?? 0,
        );
      }

      return EdgeInsets.only(
        top: _toDouble(value['top']) ?? 0,
        bottom: _toDouble(value['bottom']) ?? 0,
        left: _toDouble(value['left']) ?? 0,
        right: _toDouble(value['right']) ?? 0,
      );
    }

    return null;
  }

  static double? _toDouble(dynamic value) {
    if (value == null) return null;
    if (value is double) return value;
    if (value is int) return value.toDouble();
    if (value is String) return double.tryParse(value);
    return null;
  }
}
