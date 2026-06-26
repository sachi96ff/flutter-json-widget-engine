/// A powerful JSON-to-Flutter-UI rendering engine.
///
/// Build entire Flutter screens dynamically from JSON configuration.
/// Perfect for server-driven UI, no-code app builders, and dynamic
/// content delivery.
///
/// ## Quick Start
///
/// ```dart
/// import 'package:json_dynamic_home/json_dynamic_home.dart';
///
/// // 1. Load JSON from any URL
/// final loader = JsonLoaderService();
/// final config = await loader.loadFromUrl('https://example.com/screen.json');
///
/// // 2. Build Flutter widgets
/// final engine = JsonWidgetEngine();
/// final widget = engine.buildScreen(config!, context);
/// ```
library json_dynamic_home;

// ─── Models ──────────────────────────────────────────────────
export 'src/models/widget_node.dart';
export 'src/models/widget_style.dart';
export 'src/models/dynamic_screen_config.dart';

// ─── Engine ──────────────────────────────────────────────────
export 'src/engine/json_widget_engine.dart';
export 'src/engine/widget_registry.dart';
export 'src/engine/style_parser.dart';
export 'src/engine/action_handler.dart';
export 'src/engine/animation_wrapper.dart';
export 'src/engine/error_boundary.dart';
export 'src/engine/json_analytics_delegate.dart';

// ─── Services ────────────────────────────────────────────────
export 'src/services/json_loader_service.dart';

// ─── Ready-to-use Screens ────────────────────────────────────
export 'src/screens/dynamic_screen.dart';
export 'src/screens/dynamic_widget_area.dart';

// ─── State Providers ─────────────────────────────────────────
export 'src/providers/dynamic_ui_provider.dart';
