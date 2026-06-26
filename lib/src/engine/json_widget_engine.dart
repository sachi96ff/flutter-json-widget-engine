// lib/dynamic_ui/engine/json_widget_engine.dart

import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import '../models/widget_node.dart';
import '../models/dynamic_screen_config.dart';
import 'widget_registry.dart';
import 'style_parser.dart';
import 'animation_wrapper.dart';
import 'error_boundary.dart';
import 'json_analytics_delegate.dart';

// Delegate removed as visibility is now a simple boolean

typedef NativeActionCallback = void Function(BuildContext context, Map<String, dynamic> params);

/// Registry for custom native click actions.
class NativeActionRegistry {
  final Map<String, NativeActionCallback> _actions = {};

  /// Register a native action by ID.
  void register(String id, NativeActionCallback callback) {
    _actions[id] = callback;
  }

  /// Execute an action if registered. Returns true if handled.
  bool execute(String id, BuildContext context, Map<String, dynamic> params) {
    if (_actions.containsKey(id)) {
      _actions[id]!(context, params);
      return true;
    }
    return false;
  }
}

/// Inherited widget to provide the engine down the tree.
class JsonWidgetEngineProvider extends InheritedWidget {
  final JsonWidgetEngine engine;

  const JsonWidgetEngineProvider({
    super.key,
    required this.engine,
    required super.child,
  });

  static JsonWidgetEngine? of(BuildContext context) {
    return context.dependOnInheritedWidgetOfExactType<JsonWidgetEngineProvider>()?.engine;
  }

  @override
  bool updateShouldNotify(JsonWidgetEngineProvider oldWidget) => engine != oldWidget.engine;
}

/// The main JSON-to-Widget rendering engine.
///
/// Usage:
/// ```dart
/// final engine = JsonWidgetEngine();
/// final config = DynamicScreenConfig.fromJson(jsonMap);
/// final widget = engine.buildScreen(config, context);
/// ```
///
/// To add custom widget types:
/// ```dart
/// engine.registry.registerSimple('MyWidget', (node, ctx) => MyWidget());
/// ```
class JsonWidgetEngine {
  /// The widget registry mapping type strings to builders.
  final WidgetRegistry registry;

  /// Track animation delay index for staggered animations.
  int _animationIndex = 0;

  /// Registry for custom native actions.
  final NativeActionRegistry actionRegistry;

  /// Optional delegate to handle analytics events.
  final JsonAnalyticsDelegate? analyticsDelegate;

  JsonWidgetEngine({
    WidgetRegistry? registry,
    NativeActionRegistry? actionRegistry,
    this.analyticsDelegate,
  })  : registry = registry ?? WidgetRegistry(),
        actionRegistry = actionRegistry ?? NativeActionRegistry();

  /// Build the full screen content from a [DynamicScreenConfig].
  ///
  /// Returns a scrollable or non-scrollable widget tree based on config.
  Widget buildScreen(DynamicScreenConfig config, BuildContext context) {
    _animationIndex = 0; // Reset for each screen build

    final children = config.widgets
        .map((node) => buildWidget(node, context))
        .toList();

    Widget content;

    if (config.scrollable) {
      content = SingleChildScrollView(
        physics: const AlwaysScrollableScrollPhysics(),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          mainAxisSize: MainAxisSize.min,
          children: children,
        ),
      );
    } else {
      content = Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        mainAxisSize: MainAxisSize.min,
        children: children,
      );
    }

    // Apply screen-level padding
    if (config.padding != null) {
      content = Padding(padding: config.padding!, child: content);
    }

    // Apply screen-level background
    content = _applyScreenBackground(content, config);

    // Apply screen-level margin
    if (config.margin != null) {
      content = Padding(padding: config.margin!, child: content);
    }

    return JsonWidgetEngineProvider(
      engine: this,
      child: content,
    );
  }

  /// Build the dynamic area (non-scrollable, for embedding in home screen).
  ///
  /// Returns a Column of widgets without its own scroll behavior.
  Widget buildArea(DynamicScreenConfig config, BuildContext context) {
    _animationIndex = 0;

    final children = config.widgets
        .map((node) => buildWidget(node, context))
        .toList();

    Widget content = Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      mainAxisSize: MainAxisSize.min,
      children: children,
    );

    // Apply screen-level padding
    if (config.padding != null) {
      content = Padding(padding: config.padding!, child: content);
    }

    // Apply screen-level background
    content = _applyScreenBackground(content, config);

    // Apply screen-level margin
    if (config.margin != null) {
      content = Padding(padding: config.margin!, child: content);
    }

    return JsonWidgetEngineProvider(
      engine: this,
      child: content,
    );
  }

  /// Apply background color and/or background image to screen content.
  Widget _applyScreenBackground(Widget content, DynamicScreenConfig config) {
    final bgColor = StyleParser.parseColor(config.background);
    final bgImage = config.backgroundImage;

    if (bgImage != null && bgImage.isNotEmpty) {
      // Use a Stack to ensure the image takes 100% width and maintains its aspect ratio
      return Stack(
        children: [
          if (bgColor != null)
            Positioned.fill(
              child: ColoredBox(color: bgColor),
            ),
          SizedBox(
            width: double.infinity,
            child: CachedNetworkImage(
              imageUrl: bgImage,
              fit: BoxFit.fitWidth,
              alignment: Alignment.topCenter,
            ),
          ),
          SizedBox(
            width: double.infinity,
            child: content,
          ),
        ],
      );
    } else if (bgColor != null) {
      return ColoredBox(color: bgColor, child: content);
    }

    return content;
  }

  /// Build a single widget from a [WidgetNode].
  ///
  /// This is the recursive core of the engine:
  /// 1. Check visibility (premium gating)
  /// 2. Build the widget via registry
  /// 3. Apply styling container (if style has layout properties)
  /// 4. Wrap with animation
  /// 5. Wrap with error boundary
  Widget buildWidget(WidgetNode node, BuildContext context) {
    return ErrorBoundary.buildSafe(
      widgetType: node.type,
      builder: () => _buildWidgetInternal(node, context),
    );
  }

  Widget _buildWidgetInternal(WidgetNode node, BuildContext context) {
    // ─── 1. Visibility check ─────────────────────────────────
    if (node.visibility != null && !node.visibility!.visible) {
      return const SizedBox.shrink();
    }

    // ─── 2. Build via registry ───────────────────────────────
    Widget? widget = registry.build(node, context, this);

    if (widget == null) {
      // Unknown widget type — log and show placeholder in debug
      debugPrint('⚠️ DynamicUI: Unknown widget type "${node.type}"');
      return const SizedBox.shrink();
    }

    // ─── 3. Apply style container (margin, width/height at this level) ─
    // Note: padding, background, border, radius are typically handled
    // by the widget itself (Container, Card) or applied here for
    // content widgets that don't have their own container.
    widget = _applyStyleWrapper(widget, node, context);

    // ─── 4. Animation ────────────────────────────────────────
    if (node.animation != null && node.animation!.isNotEmpty) {
      widget = AnimationWrapper(
        animationType: node.animation,
        delay: Duration(milliseconds: 50 * _animationIndex),
        child: widget,
      );
      _animationIndex++;
    }

    return widget;
  }

  /// Apply margin and dimension wrapper around a widget if needed.
  Widget _applyStyleWrapper(Widget widget, WidgetNode node, BuildContext context) {
    final style = node.style;
    if (style == null) return widget;

    final margin = style.margin;
    final width = StyleParser.resolveWidth(style, context);
    final height = StyleParser.resolveHeight(style, context);

    // Only wrap if there's something to apply that the widget
    // itself doesn't handle (content widgets like Title, Text, etc.)
    final isLayoutWidget = _isLayoutType(node.type);

    if (!isLayoutWidget) {
      // For content widgets, apply margin/dimensions
      if (margin != null || width != null || height != null) {
        widget = Container(
          margin: margin,
          width: width,
          height: height,
          child: widget,
        );
      }
    } else if (margin != null) {
      // For layout widgets, only apply margin (they handle their own dimensions)
      widget = Padding(
        padding: margin,
        child: widget,
      );
    }

    return widget;
  }

  /// Check if a widget type is a layout/container type that handles its own sizing.
  bool _isLayoutType(String type) {
    const layoutTypes = {
      'container', 'card', 'column', 'row', 'grid', 'list',
      'horizontallist', 'padding', 'center', 'sizedbox', 'spacer',
      'expanded', 'banner',
    };
    return layoutTypes.contains(type.toLowerCase());
  }
}
