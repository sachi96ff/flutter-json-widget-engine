// lib/dynamic_ui/engine/animation_wrapper.dart

import 'package:flutter/material.dart';

/// Wraps a child widget with an entry animation.
///
/// Supported animations: fade, slide, zoom, scale, bounce.
/// Each animation runs once when the widget first appears.
class AnimationWrapper extends StatefulWidget {
  final Widget child;
  final String? animationType;
  final Duration duration;
  final Duration delay;

  const AnimationWrapper({
    super.key,
    required this.child,
    this.animationType,
    this.duration = const Duration(milliseconds: 500),
    this.delay = Duration.zero,
  });

  @override
  State<AnimationWrapper> createState() => _AnimationWrapperState();
}

class _AnimationWrapperState extends State<AnimationWrapper>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;
  late final Animation<double> _fadeAnimation;
  late final Animation<Offset> _slideAnimation;
  late final Animation<double> _scaleAnimation;

  @override
  void initState() {
    super.initState();

    _controller = AnimationController(
      vsync: this,
      duration: widget.duration,
    );

    // Fade
    _fadeAnimation = CurvedAnimation(
      parent: _controller,
      curve: Curves.easeOut,
    );

    // Slide from bottom
    _slideAnimation = Tween<Offset>(
      begin: const Offset(0, 0.15),
      end: Offset.zero,
    ).animate(CurvedAnimation(
      parent: _controller,
      curve: Curves.easeOutCubic,
    ));

    // Scale / Zoom
    final scaleCurve = widget.animationType == 'bounce'
        ? Curves.elasticOut
        : Curves.easeOutBack;

    _scaleAnimation = Tween<double>(
      begin: widget.animationType == 'bounce' ? 0.5 : 0.8,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _controller,
      curve: scaleCurve,
    ));

    // Start with delay
    if (widget.delay > Duration.zero) {
      Future.delayed(widget.delay, () {
        if (mounted) _controller.forward();
      });
    } else {
      _controller.forward();
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final type = widget.animationType?.toLowerCase();

    if (type == null || type.isEmpty || type == 'none') {
      return widget.child;
    }

    switch (type) {
      case 'fade':
        return FadeTransition(
          opacity: _fadeAnimation,
          child: widget.child,
        );

      case 'slide':
        return FadeTransition(
          opacity: _fadeAnimation,
          child: SlideTransition(
            position: _slideAnimation,
            child: widget.child,
          ),
        );

      case 'zoom':
      case 'scale':
        return FadeTransition(
          opacity: _fadeAnimation,
          child: ScaleTransition(
            scale: _scaleAnimation,
            child: widget.child,
          ),
        );

      case 'bounce':
        return FadeTransition(
          opacity: _fadeAnimation,
          child: ScaleTransition(
            scale: _scaleAnimation,
            child: widget.child,
          ),
        );

      default:
        return FadeTransition(
          opacity: _fadeAnimation,
          child: widget.child,
        );
    }
  }
}
