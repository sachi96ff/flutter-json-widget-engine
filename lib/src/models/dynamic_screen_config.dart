// lib/dynamic_ui/models/dynamic_screen_config.dart

import 'package:flutter/material.dart';
import 'widget_node.dart';
import 'widget_style.dart';

/// Top-level JSON configuration for a dynamic screen or area.
///
/// Example JSON:
/// ```json
/// {
///   "screen_id": "home_dynamic_area",
///   "version": "1.0.0",
///   "title": "Home",
///   "scrollable": true,
///   "height": "auto",
///   "background": "#F5F5F5",
///   "widgets": [ ... ]
/// }
/// ```
class DynamicScreenConfig {
  final String screenId;
  final String version;
  final String? title;
  final bool showHeader;
  final String? headerTitleColor;
  final String? headerTitleAlignment;
  final String? headerBackIcon;
  final String? headerBgColor;
  final bool scrollable;
  final dynamic height; // "auto" or number
  final String? background;
  final String? backgroundImage;
  final List<String>? gradientColors;
  final EdgeInsets? padding;
  final EdgeInsets? margin;
  final List<WidgetNode> widgets;
  final Map<String, dynamic>? rawJson;

  const DynamicScreenConfig({
    required this.screenId,
    this.version = '1.0.0',
    this.title,
    this.showHeader = true,
    this.headerTitleColor,
    this.headerTitleAlignment,
    this.headerBackIcon,
    this.headerBgColor,
    this.scrollable = true,
    this.height = 'auto',
    this.background,
    this.backgroundImage,
    this.gradientColors,
    this.padding,
    this.margin,
    this.widgets = const [],
    this.rawJson,
  });

  factory DynamicScreenConfig.fromJson(Map<String, dynamic> json) {
    final widgetsList = <WidgetNode>[];
    if (json['widgets'] is List) {
      for (final w in json['widgets'] as List) {
        if (w is Map<String, dynamic>) {
          widgetsList.add(WidgetNode.fromJson(w));
        }
      }
    }

    return DynamicScreenConfig(
      screenId: json['screen_id'] as String? ?? 'unknown',
      version: json['version'] as String? ?? '1.0.0',
      title: json['title'] as String?,
      showHeader: json['show_header'] as bool? ?? true,
      headerTitleColor: json['header_title_color'] as String?,
      headerTitleAlignment: json['header_title_alignment'] as String?,
      headerBackIcon: json['header_back_icon'] as String?,
      headerBgColor: json['header_bg_color'] as String?,
      scrollable: json['scrollable'] as bool? ?? true,
      height: json['height'] ?? 'auto',
      background: json['background'] as String?,
      backgroundImage: (json['background_image'] ?? json['backgroundImage']) as String?,
      gradientColors: (json['gradient_colors'] as List?)?.map((e) => e.toString()).toList(),
      padding: WidgetStyle.parseEdgeInsets(json['padding']),
      margin: WidgetStyle.parseEdgeInsets(json['margin']),
      widgets: widgetsList,
      rawJson: json,
    );
  }

  Map<String, dynamic> toJson() {
    if (rawJson != null) return rawJson!;
    return {
      'screen_id': screenId,
      'version': version,
      'title': title,
      'show_header': showHeader,
      if (headerTitleColor != null) 'header_title_color': headerTitleColor,
      if (headerTitleAlignment != null) 'header_title_alignment': headerTitleAlignment,
      if (headerBackIcon != null) 'header_back_icon': headerBackIcon,
      if (headerBgColor != null) 'header_bg_color': headerBgColor,
      'scrollable': scrollable,
      'height': height,
      'background': background,
      'background_image': backgroundImage,
      if (gradientColors != null) 'gradient_colors': gradientColors,
      'widgets': [],
    };
  }
}
