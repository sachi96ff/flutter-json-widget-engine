// lib/dynamic_ui/screens/dynamic_screen.dart

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:shimmer/shimmer.dart';
import '../engine/json_widget_engine.dart';
import '../models/dynamic_screen_config.dart';
import '../services/json_loader_service.dart';
import '../engine/style_parser.dart';
import '../widgets/content/dynamic_icon.dart';
import '../engine/action_handler.dart';
import '../models/widget_node.dart';


/// Universal screen that renders its entire UI from a JSON file.
///
/// Route arguments:
/// ```dart
/// Navigator.pushNamed(context, '/dynamic', arguments: {
///   'json_file': 'exam_details.json',
///   'title': 'Exam Details', // optional
/// });
/// ```
class DynamicScreen extends StatefulWidget {
  final String? jsonFile;
  final String? title;
  final JsonWidgetEngine? engine;
  final Widget? loadingWidget;
  final Widget Function(BuildContext context, String error, VoidCallback onRetry)? errorBuilder;

  const DynamicScreen({
    super.key,
    this.jsonFile,
    this.title,
    this.engine,
    this.loadingWidget,
    this.errorBuilder,
  });

  @override
  State<DynamicScreen> createState() => _DynamicScreenState();
}

class _DynamicScreenState extends State<DynamicScreen> {
  final JsonLoaderService _loader = JsonLoaderService();
  late final JsonWidgetEngine _engine;

  DynamicScreenConfig? _config;
  bool _isLoading = true;
  String? _error;
  String? _jsonFile;
  String? _title;

  @override
  void initState() {
    super.initState();
    _engine = widget.engine ?? JsonWidgetEngine();
    _jsonFile = widget.jsonFile;
    _title = widget.title;
    // If jsonFile was provided via the constructor, start loading immediately
    if (_jsonFile != null) {
      _loadJson();
    }
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    // If jsonFile was NOT provided via constructor, try to get it from route arguments
    if (_jsonFile == null) {
      _parseArguments();
      _loadJson();
    }
  }

  void _parseArguments() {
    final args =
        ModalRoute.of(context)?.settings.arguments as Map<String, dynamic>?;
    _jsonFile ??= args?['json_file'] as String?;
    _title ??= args?['title'] as String?;
  }

  Future<void> _loadJson() async {
    if (_jsonFile == null || _jsonFile!.isEmpty) {
      setState(() {
        _error = 'No JSON file specified';
        _isLoading = false;
      });
      return;
    }

    setState(() {
      _isLoading = true;
      _error = null;
    });

    try {
      final config = await _loader.loadConfig(_jsonFile!);

      if (mounted) {
        setState(() {
          _config = config;
          _isLoading = false;
          if (config == null) {
            _error = 'Failed to load content';
          } else {
            // Use JSON title if not provided via arguments
            _title ??= config.title;
            // Log screen view
            _engine.analyticsDelegate?.logScreenView(_jsonFile!);
          }
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _error = 'Something went wrong';
          _isLoading = false;
        });
      }
    }
  }

  Future<void> _refresh() async {
    if (_jsonFile == null) return;
    _loader.clearCache(_jsonFile!);
    await _loadJson();
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    Color bg = Theme.of(context).colorScheme.surface;
    if (_config?.background != null) {
      final parsedBg = StyleParser.parseColor(_config!.background);
      if (parsedBg != null) {
        bg = parsedBg;
      }
    }

    // Resolve status bar style from config
    SystemUiOverlayStyle statusBarStyle;
    final configBarStyle = _config?.statusBarStyle;
    if (configBarStyle == 'light') {
      statusBarStyle = SystemUiOverlayStyle.light;
    } else if (configBarStyle == 'dark') {
      statusBarStyle = SystemUiOverlayStyle.dark;
    } else {
      statusBarStyle = isDark ? SystemUiOverlayStyle.light : SystemUiOverlayStyle.dark;
    }

    final scaffold = Scaffold(
      backgroundColor: Colors.transparent,
      appBar: (_config == null || _config!.showHeader)
          ? AppBar(
              backgroundColor: StyleParser.parseColor(_config?.headerBgColor) ?? bg,
              elevation: 0,
              scrolledUnderElevation: 0,
              leading: IconButton(
                onPressed: () => Navigator.of(context).pop(),
                icon: Icon(
                  _config?.headerBackIcon != null 
                      ? DynamicIcon.resolveIcon(_config!.headerBackIcon!)
                      : Icons.arrow_back_ios_rounded,
                  size: 20,
                  color: StyleParser.parseColor(_config?.headerTitleColor) ?? Theme.of(context).colorScheme.onSurface,
                ),
              ),
              title: _title != null
                  ? Text(
                      _title!,
                      style: GoogleFonts.plusJakartaSans(
                        fontSize: 18,
                        fontWeight: FontWeight.w700,
                        color: StyleParser.parseColor(_config?.headerTitleColor) ?? Theme.of(context).colorScheme.onSurface,
                      ),
                    )
                  : null,
              centerTitle: _config?.headerTitleAlignment == null || _config?.headerTitleAlignment == 'center',
            )
          : null,
      body: _buildBody(context, isDark),
      // FAB support
      floatingActionButton: _buildFab(context),
    );

    // Build background decoration
    DecorationImage? bgImage;
    if (_config?.backgroundImage != null && _config!.backgroundImage!.isNotEmpty) {
      // Parse fit
      BoxFit fit = BoxFit.cover;
      switch (_config?.backgroundFit) {
        case 'contain': fit = BoxFit.contain; break;
        case 'fill': fit = BoxFit.fill; break;
        case 'none': fit = BoxFit.none; break;
        default: fit = BoxFit.cover;
      }

      // Parse position
      Alignment alignment = Alignment.center;
      switch (_config?.backgroundPosition) {
        case 'top': alignment = Alignment.topCenter; break;
        case 'bottom': alignment = Alignment.bottomCenter; break;
        case 'left': alignment = Alignment.centerLeft; break;
        case 'right': alignment = Alignment.centerRight; break;
        case 'top left': alignment = Alignment.topLeft; break;
        case 'top right': alignment = Alignment.topRight; break;
        case 'bottom left': alignment = Alignment.bottomLeft; break;
        case 'bottom right': alignment = Alignment.bottomRight; break;
        default: alignment = Alignment.center;
      }

      // Parse repeat
      ImageRepeat repeat = ImageRepeat.noRepeat;
      switch (_config?.backgroundRepeat) {
        case 'repeat': repeat = ImageRepeat.repeat; break;
        case 'repeat-x': repeat = ImageRepeat.repeatX; break;
        case 'repeat-y': repeat = ImageRepeat.repeatY; break;
        default: repeat = ImageRepeat.noRepeat;
      }

      bgImage = DecorationImage(
        image: NetworkImage(_config!.backgroundImage!),
        fit: fit,
        alignment: alignment,
        repeat: repeat,
      );
    }

    LinearGradient? bgGradient;
    if (_config?.gradientColors != null && _config!.gradientColors!.length >= 2) {
      final colors = _config!.gradientColors!
          .map((c) => StyleParser.parseColor(c))
          .where((c) => c != null)
          .map((c) => c!)
          .toList();
      if (colors.length >= 2) {
        bgGradient = LinearGradient(
          colors: colors,
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        );
      }
    }

    // Safe area handling
    final useSafeArea = _config?.safeArea ?? true;

    Widget body = Container(
      decoration: BoxDecoration(
        color: bg,
        image: bgImage,
        gradient: bgGradient,
      ),
      child: useSafeArea
          ? SafeAreaView(child: scaffold)
          : scaffold,
    );

    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: statusBarStyle,
      child: body,
    );
  }

  Widget? _buildFab(BuildContext context) {
    if (_config?.fab == null || _config!.fab!['icon'] == null) return null;
    final fabIcon = _config!.fab!['icon'] as String?;
    final fabBg = StyleParser.parseColor(_config!.fab!['background'] as String?) ?? Theme.of(context).colorScheme.primary;
    
    return FloatingActionButton(
      backgroundColor: fabBg,
      onPressed: () {
        // Handle FAB action via engine action handler
        if (_config!.fab!['on_click'] != null) {
          final action = ClickAction.fromJson(_config!.fab!['on_click'] as Map<String, dynamic>);
          final callback = ActionHandler.buildCallback(context, action: action);
          if (callback != null) {
            callback();
          }
        }
      },
      child: Icon(
        fabIcon != null ? DynamicIcon.resolveIcon(fabIcon) : Icons.add,
        color: Colors.white,
      ),
    );
  }

  Widget _buildBody(BuildContext context, bool isDark) {
    // Loading state
    if (_isLoading) {
      return widget.loadingWidget ?? _LoadingShimmer(isDark: isDark);
    }

    // Error state
    if (_error != null || _config == null) {
      if (widget.errorBuilder != null) {
        return widget.errorBuilder!(context, _error ?? 'Unknown error', _loadJson);
      }
      return _ErrorState(
        error: _error ?? 'Unknown error',
        onRetry: _loadJson,
        isDark: isDark,
      );
    }

    // Success — render from JSON
    final usePullToRefresh = _config?.pullToRefresh ?? true;
    
    if (usePullToRefresh) {
      return RefreshIndicator(
        onRefresh: _refresh,
        color: Theme.of(context).colorScheme.primary,
        child: _engine.buildScreen(_config!, context),
      );
    }
    
    return _engine.buildScreen(_config!, context);
  }
}

// Helper widget to handle safe area conditionally
class SafeAreaView extends StatelessWidget {
  final Widget child;
  const SafeAreaView({super.key, required this.child});
  
  @override
  Widget build(BuildContext context) {
    return SafeArea(child: child);
  }
}

// ─── Loading Shimmer ──────────────────────────────────────────────

class _LoadingShimmer extends StatelessWidget {
  final bool isDark;

  const _LoadingShimmer({required this.isDark});

  @override
  Widget build(BuildContext context) {
    final baseColor = isDark ? const Color(0xFF1A2040) : const Color(0xFFE4EAF8);
    final highlightColor =
        isDark ? const Color(0xFF253060) : const Color(0xFFF0F4FF);

    return Shimmer.fromColors(
      baseColor: baseColor,
      highlightColor: highlightColor,
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Title shimmer
            Container(
              width: 200,
              height: 24,
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(8),
              ),
            ),
            const SizedBox(height: 16),

            // Card shimmers
            for (int i = 0; i < 3; i++) ...[
              Container(
                width: double.infinity,
                height: 100,
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(16),
                ),
              ),
              const SizedBox(height: 12),
            ],

            // Grid shimmer
            const SizedBox(height: 8),
            Row(
              children: [
                Expanded(
                  child: Container(
                    height: 120,
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(16),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Container(
                    height: 120,
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(16),
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

// ─── Error State ──────────────────────────────────────────────────

class _ErrorState extends StatelessWidget {
  final String error;
  final VoidCallback onRetry;
  final bool isDark;

  const _ErrorState({
    required this.error,
    required this.onRetry,
    required this.isDark,
  });

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(40),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.cloud_off_rounded,
              size: 64,
              color: Theme.of(context).colorScheme.onSurfaceVariant,
            ),
            const SizedBox(height: 16),
            Text(
              error,
              style: GoogleFonts.inter(
                fontSize: 16,
                fontWeight: FontWeight.w500,
                color: Theme.of(context).colorScheme.onSurfaceVariant,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 24),
            ElevatedButton.icon(
              onPressed: onRetry,
              icon: const Icon(Icons.refresh_rounded, size: 18),
              label: Text(
                'Retry',
                style: GoogleFonts.inter(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                ),
              ),
              style: ElevatedButton.styleFrom(
                backgroundColor: Theme.of(context).colorScheme.primary,
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                padding: const EdgeInsets.symmetric(
                  horizontal: 24,
                  vertical: 12,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
