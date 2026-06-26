// lib/dynamic_ui/providers/dynamic_ui_provider.dart

import 'package:flutter/foundation.dart';
import '../models/dynamic_screen_config.dart';
import '../services/json_loader_service.dart';

/// State for a dynamic UI loading operation.
enum DynamicUiStatus { initial, loading, loaded, error }

/// Provider for managing dynamic UI state.
///
/// Loads, caches, and provides [DynamicScreenConfig] to widgets.
///
/// Usage:
/// ```dart
/// final provider = DynamicUiProvider();
/// await provider.loadConfig('home_dynamic.json');
/// // Access: provider.config, provider.status
/// ```
class DynamicUiProvider extends ChangeNotifier {
  final JsonLoaderService _loader = JsonLoaderService();

  DynamicUiStatus _status = DynamicUiStatus.initial;
  DynamicScreenConfig? _config;
  String? _errorMessage;
  String? _currentJsonFile;

  DynamicUiStatus get status => _status;
  DynamicScreenConfig? get config => _config;
  String? get errorMessage => _errorMessage;
  String? get currentJsonFile => _currentJsonFile;
  bool get isLoading => _status == DynamicUiStatus.loading;
  bool get hasData => _config != null;

  /// Load a dynamic UI configuration from a JSON file.
  ///
  /// [jsonFile] — the JSON file name (e.g., "home_dynamic.json")
  /// [forceRefresh] — bypass all caches
  Future<void> loadConfig(String jsonFile, {bool forceRefresh = false}) async {
    // Don't reload if already loaded the same file (unless forced)
    if (!forceRefresh &&
        _currentJsonFile == jsonFile &&
        _status == DynamicUiStatus.loaded &&
        _config != null) {
      return;
    }

    _status = DynamicUiStatus.loading;
    _currentJsonFile = jsonFile;
    _errorMessage = null;
    notifyListeners();

    try {
      final config = await _loader.loadConfig(
        jsonFile,
        forceRefresh: forceRefresh,
      );

      if (config != null) {
        _config = config;
        _status = DynamicUiStatus.loaded;
      } else {
        _errorMessage = 'Failed to load dynamic content';
        _status = DynamicUiStatus.error;
      }
    } catch (e) {
      debugPrint('❌ DynamicUiProvider: Error loading "$jsonFile": $e');
      _errorMessage = 'Something went wrong';
      _status = DynamicUiStatus.error;
    }

    notifyListeners();
  }

  /// Refresh the current config (force reload from API).
  Future<void> refresh() async {
    if (_currentJsonFile != null) {
      await loadConfig(_currentJsonFile!, forceRefresh: true);
    }
  }

  /// Clear all data and caches.
  Future<void> clearAll() async {
    _config = null;
    _status = DynamicUiStatus.initial;
    _currentJsonFile = null;
    _errorMessage = null;
    await _loader.clearAllCaches();
    notifyListeners();
  }
}
