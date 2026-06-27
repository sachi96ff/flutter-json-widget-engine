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
  final String? minHeight;
  final String? background;
  final String? backgroundImage;
  final String? backgroundFit;      // 'cover' | 'contain' | 'fill' | 'none'
  final String? backgroundRepeat;   // 'no-repeat' | 'repeat' | 'repeat-x' | 'repeat-y'
  final String? backgroundPosition; // 'center' | 'top' | 'bottom' etc.
  final String? backgroundAttachment; // 'fixed' | 'scroll'
  final bool safeArea;
  final String? statusBarStyle;     // 'light' | 'dark' | 'auto'
  final String? transition;         // 'slide' | 'fade' | 'scale' | 'none'
  final bool pullToRefresh;
  final Map<String, dynamic>? fab;
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
    this.minHeight,
    this.background,
    this.backgroundImage,
    this.backgroundFit,
    this.backgroundRepeat,
    this.backgroundPosition,
    this.backgroundAttachment,
    this.safeArea = true,
    this.statusBarStyle,
    this.transition,
    this.pullToRefresh = true,
    this.fab,
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
      minHeight: json['min_height']?.toString(),
      background: json['background'] as String?,
      backgroundImage: (json['background_image'] ?? json['backgroundImage']) as String?,
      backgroundFit: (json['background_fit'] ?? json['backgroundFit']) as String?,
      backgroundRepeat: (json['background_repeat'] ?? json['backgroundRepeat']) as String?,
      backgroundPosition: (json['background_position'] ?? json['backgroundPosition']) as String?,
      backgroundAttachment: (json['background_attachment'] ?? json['backgroundAttachment']) as String?,
      safeArea: json['safe_area'] as bool? ?? true,
      statusBarStyle: json['status_bar_style'] as String?,
      transition: json['transition'] as String?,
      pullToRefresh: json['pull_to_refresh'] as bool? ?? true,
      fab: json['fab'] is Map<String, dynamic> ? json['fab'] as Map<String, dynamic> : null,
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
      if (minHeight != null) 'min_height': minHeight,
      'background': background,
      'background_image': backgroundImage,
      if (backgroundFit != null) 'background_fit': backgroundFit,
      if (backgroundRepeat != null) 'background_repeat': backgroundRepeat,
      if (backgroundPosition != null) 'background_position': backgroundPosition,
      if (backgroundAttachment != null) 'background_attachment': backgroundAttachment,
      'safe_area': safeArea,
      if (statusBarStyle != null) 'status_bar_style': statusBarStyle,
      if (transition != null) 'transition': transition,
      'pull_to_refresh': pullToRefresh,
      if (fab != null) 'fab': fab,
      if (gradientColors != null) 'gradient_colors': gradientColors,
      'widgets': [],
    };
  }
}
