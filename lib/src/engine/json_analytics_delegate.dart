// lib/src/engine/json_analytics_delegate.dart

/// A delegate to handle analytics events from the JSON UI.
abstract class JsonAnalyticsDelegate {
  /// Called when an interactive widget with an "analytics" block is clicked.
  void logEvent(String eventName, Map<String, dynamic> parameters);

  /// Called when a JSON screen or widget area is successfully loaded.
  void logScreenView(String screenName);
}
