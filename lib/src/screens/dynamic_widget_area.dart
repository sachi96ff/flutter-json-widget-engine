import 'package:flutter/material.dart';
import 'package:shimmer/shimmer.dart';
import '../engine/json_widget_engine.dart';
import '../models/dynamic_screen_config.dart';
import '../services/json_loader_service.dart';

/// A widget that renders its content from a JSON file.
/// Designed to be embedded inside existing screens (e.g. inside a Column or ListView).
class DynamicWidgetArea extends StatefulWidget {
  /// The JSON file name or full URL to load
  final String jsonFile;
  /// Optional widget to show while loading
  final Widget? loadingWidget;
  /// Optional builder for custom error states
  final Widget Function(BuildContext context, String error, VoidCallback onRetry)? errorBuilder;

  const DynamicWidgetArea({
    super.key, 
    required this.jsonFile,
    this.loadingWidget,
    this.errorBuilder,
  });

  @override
  State<DynamicWidgetArea> createState() => _DynamicWidgetAreaState();
}

class _DynamicWidgetAreaState extends State<DynamicWidgetArea> {
  final JsonLoaderService _loader = JsonLoaderService();
  final JsonWidgetEngine _engine = JsonWidgetEngine();

  DynamicScreenConfig? _config;
  bool _isLoading = true;
  String? _error;

  @override
  void initState() {
    super.initState();
    _loadJson();
  }

  @override
  void didUpdateWidget(covariant DynamicWidgetArea oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.jsonFile != widget.jsonFile) {
      _loadJson();
    }
  }

  Future<void> _loadJson() async {
    setState(() {
      _isLoading = true;
      _error = null;
    });

    try {
      final config = await _loader.loadConfig(widget.jsonFile);

      if (mounted) {
        setState(() {
          _config = config;
          _isLoading = false;
          if (config == null) {
            _error = 'Failed to load content';
          } else {
            _engine.analyticsDelegate?.logScreenView(widget.jsonFile);
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

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    if (_isLoading) {
      return widget.loadingWidget ?? _buildShimmer(isDark);
    }

    if (_error != null || _config == null) {
      if (widget.errorBuilder != null) {
        return widget.errorBuilder!(context, _error ?? 'Unknown error', _loadJson);
      }
      return _buildError(isDark);
    }

    // Since this is embedded in an area, we use buildArea instead of buildScreen
    // to avoid scroll conflicts if placed inside a parent scroll view.
    return _engine.buildArea(_config!, context);
  }

  Widget _buildShimmer(bool isDark) {
    final baseColor = isDark ? const Color(0xFF1A2040) : const Color(0xFFE4EAF8);
    final highlightColor =
        isDark ? const Color(0xFF253060) : const Color(0xFFF0F4FF);

    return Shimmer.fromColors(
      baseColor: baseColor,
      highlightColor: highlightColor,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: double.infinity,
              height: 100,
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildError(bool isDark) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              Icons.warning_amber_rounded,
              color: Theme.of(context).colorScheme.error,
            ),
            const SizedBox(height: 8),
            Text(
              _error ?? 'Error',
              style: TextStyle(
                color: Theme.of(context).colorScheme.error,
              ),
            ),
            TextButton(
              onPressed: _loadJson,
              child: const Text('Retry'),
            ),
          ],
        ),
      ),
    );
  }
}
