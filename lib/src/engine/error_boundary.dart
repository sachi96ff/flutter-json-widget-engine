// lib/dynamic_ui/engine/error_boundary.dart

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

/// Wraps dynamic widget rendering in a safe error boundary.
///
/// If the child widget throws during build, this shows a compact
/// error card instead of crashing the app. In debug mode it shows
/// the error details; in release it shows a generic message.
class ErrorBoundary extends StatelessWidget {
  final Widget child;
  final String widgetType;

  const ErrorBoundary({
    super.key,
    required this.child,
    required this.widgetType,
  });

  @override
  Widget build(BuildContext context) {
    // We can't catch build-time errors with a try/catch.
    // Instead, we rely on the Flutter error handler + ErrorWidget.builder.
    // For our use case, we wrap the builder call in the engine with try/catch.
    return child;
  }

  /// Build a widget safely — if builder throws, returns an error card.
  static Widget buildSafe({
    required String widgetType,
    required Widget Function() builder,
  }) {
    try {
      return builder();
    } catch (e, stack) {
      debugPrint('❌ DynamicUI: Error building "$widgetType": $e');
      debugPrint('Stack: $stack');
      return _ErrorCard(widgetType: widgetType, error: e.toString());
    }
  }
}

class _ErrorCard extends StatelessWidget {
  final String widgetType;
  final String error;

  const _ErrorCard({required this.widgetType, required this.error});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Container(
      margin: const EdgeInsets.symmetric(vertical: 4),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: isDark
            ? const Color(0xFF2D1B1B)
            : const Color(0xFFFEE2E2),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: isDark
              ? const Color(0xFF7F1D1D)
              : const Color(0xFFFECACA),
        ),
      ),
      child: Row(
        children: [
          Icon(
            Icons.warning_amber_rounded,
            color: isDark ? const Color(0xFFF87171) : const Color(0xFFDC2626),
            size: 18,
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  'Widget "$widgetType" failed',
                  style: GoogleFonts.inter(
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                    color: isDark
                        ? const Color(0xFFF87171)
                        : const Color(0xFFDC2626),
                  ),
                ),
                if (kDebugMode) ...[
                  const SizedBox(height: 2),
                  Text(
                    error,
                    style: GoogleFonts.inter(
                      fontSize: 10,
                      color: isDark
                          ? const Color(0xFFFCA5A5)
                          : const Color(0xFF991B1B),
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }
}
