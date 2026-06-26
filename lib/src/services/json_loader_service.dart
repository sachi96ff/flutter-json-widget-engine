// lib/dynamic_ui/services/json_loader_service.dart

import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/dynamic_screen_config.dart';
import 'package:http/http.dart' as http;
/// Service for loading, caching, and serving dynamic UI JSON.
///
/// Loading priority:
/// 1. In-memory cache (if not expired)
/// 2. API endpoint (remote JSON)
/// 3. Local persistent cache (SharedPreferences)
/// 4. Local asset fallback (assets/json/*)
///
/// Features:
/// - In-memory TTL cache (default: 5 minutes)
/// - Persistent cache for offline fallback
/// - Version-based cache invalidation
/// - Local asset loading for development
class JsonLoaderService {
  static final JsonLoaderService _instance = JsonLoaderService._internal();
  factory JsonLoaderService() => _instance;
  JsonLoaderService._internal();

  /// Optional global base URL for non-fully-qualified JSON requests
  static String? defaultBaseUrl;
  
  /// Optional global headers (e.g. for Auth tokens)
  static Map<String, String>? defaultHeaders;

  // In-memory cache: key → (config, timestamp)
  final Map<String, _CacheEntry> _memoryCache = {};

  /// Default cache TTL: 5 minutes
  static const Duration _cacheTTL = Duration(minutes: 5);

  /// Prefix for SharedPreferences keys
  static const String _cachePrefix = 'dynamic_ui_cache_';
  static const String _cacheVersionPrefix = 'dynamic_ui_version_';

  /// Load a dynamic screen config by JSON file name.
  ///
  /// [jsonFile] can be:
  /// - A filename like "home_dynamic.json" (loaded from API or assets)
  /// - A full URL (loaded directly)
  ///
  /// [forceRefresh] bypasses all caches.
  Future<DynamicScreenConfig?> loadConfig(
    String jsonFile, {
    bool forceRefresh = false,
  }) async {
    try {
      // ─── 1. Memory cache ─────────────────────────────────
      if (!forceRefresh && !kDebugMode) {
        final cached = _memoryCache[jsonFile];
        if (cached != null && !cached.isExpired) {
          debugPrint('📦 DynamicUI: Memory cache hit for "$jsonFile"');
          return cached.config;
        }
      }

      // ─── 2. Try API first ─────────────────────────────────
      DynamicScreenConfig? config;
      try {
        config = await _loadFromApi(jsonFile);
        if (config != null) {
          debugPrint('🌐 DynamicUI: Loaded "$jsonFile" from API');
          _memoryCache[jsonFile] = _CacheEntry(config);
          await _saveToPersistentCache(jsonFile, config);
          return config;
        }
      } catch (e) {
        debugPrint('⚠️ DynamicUI: API load failed for "$jsonFile": $e');
      }

      // ─── 3. Persistent cache (offline fallback) ──────────
      if (!forceRefresh && !kDebugMode) {
        config = await _loadFromPersistentCache(jsonFile);
        if (config != null) {
          debugPrint('💾 DynamicUI: Persistent cache hit for "$jsonFile"');
          _memoryCache[jsonFile] = _CacheEntry(config);
          return config;
        }
      }

      // ─── 4. Local asset fallback ─────────────────────────
      config = await _loadFromAsset(jsonFile);
      if (config != null) {
        debugPrint('📁 DynamicUI: Loaded "$jsonFile" from local assets');
        _memoryCache[jsonFile] = _CacheEntry(config);
        return config;
      }

      debugPrint('❌ DynamicUI: Failed to load "$jsonFile" from any source');
      return null;
    } catch (e) {
      debugPrint('❌ DynamicUI: Error loading "$jsonFile": $e');
      return null;
    }
  }

  /// Load from API endpoint.
  Future<DynamicScreenConfig?> _loadFromApi(String jsonFile) async {
    final String url;
    if (jsonFile.startsWith('http://') || jsonFile.startsWith('https://')) {
      url = jsonFile;
    } else if (defaultBaseUrl != null) {
      url = '$defaultBaseUrl/$jsonFile';
    } else {
      throw Exception('jsonFile must be a full URL, or JsonLoaderService.defaultBaseUrl must be set');
    }
    
    final response = await http.get(Uri.parse(url), headers: defaultHeaders);

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body) as Map<String, dynamic>;
      if (data['success'] == true && data['data'] != null) {
        return DynamicScreenConfig.fromJson(data['data']);
      }
      return DynamicScreenConfig.fromJson(data);
    }

    return null;
  }

  /// Load from local assets (assets/json/filename).
  Future<DynamicScreenConfig?> _loadFromAsset(String jsonFile) async {
    try {
      // Ensure filename has .json extension
      final filename = jsonFile.endsWith('.json') ? jsonFile : '$jsonFile.json';
      final jsonString = await rootBundle.loadString('assets/json/$filename');
      final jsonMap = jsonDecode(jsonString) as Map<String, dynamic>;
      return DynamicScreenConfig.fromJson(jsonMap);
    } catch (e) {
      debugPrint('⚠️ DynamicUI: Asset not found: assets/json/$jsonFile');
      return null;
    }
  }

  /// Save to persistent cache (SharedPreferences).
  Future<void> _saveToPersistentCache(
      String jsonFile, DynamicScreenConfig config) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final jsonString = jsonEncode(config.toJson());
      await prefs.setString('$_cachePrefix$jsonFile', jsonString);
      await prefs.setString(
          '$_cacheVersionPrefix$jsonFile', config.version);
    } catch (e) {
      debugPrint('⚠️ DynamicUI: Failed to save cache for "$jsonFile": $e');
    }
  }

  /// Load from persistent cache.
  Future<DynamicScreenConfig?> _loadFromPersistentCache(
      String jsonFile) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final jsonString = prefs.getString('$_cachePrefix$jsonFile');
      if (jsonString == null) return null;

      final jsonMap = jsonDecode(jsonString) as Map<String, dynamic>;
      return DynamicScreenConfig.fromJson(jsonMap);
    } catch (e) {
      debugPrint('⚠️ DynamicUI: Failed to read cache for "$jsonFile": $e');
      return null;
    }
  }

  /// Clear all dynamic UI caches.
  Future<void> clearAllCaches() async {
    _memoryCache.clear();
    try {
      final prefs = await SharedPreferences.getInstance();
      final keys = prefs.getKeys();
      for (final key in keys) {
        if (key.startsWith(_cachePrefix) ||
            key.startsWith(_cacheVersionPrefix)) {
          await prefs.remove(key);
        }
      }
    } catch (e) {
      debugPrint('⚠️ DynamicUI: Failed to clear caches: $e');
    }
  }

  /// Clear cache for a specific JSON file.
  void clearCache(String jsonFile) {
    _memoryCache.remove(jsonFile);
  }
}

/// In-memory cache entry with TTL.
class _CacheEntry {
  final DynamicScreenConfig config;
  final DateTime timestamp;

  _CacheEntry(this.config) : timestamp = DateTime.now();

  bool get isExpired =>
      DateTime.now().difference(timestamp) > JsonLoaderService._cacheTTL;
}
