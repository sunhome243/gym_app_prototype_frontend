import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class AnimatedInkWell extends StatefulWidget {
  final Widget child;
  final VoidCallback onTap;
  final VoidCallback? onLongPress;
  final Color? splashColor;
  final Color? highlightColor;
  final BorderRadius? borderRadius;
  final Duration animationDuration;

  const AnimatedInkWell({
    super.key,
    required this.child,
    required this.onTap,
    this.onLongPress,
    this.splashColor,
    this.highlightColor,
    this.borderRadius,
    this.animationDuration = const Duration(milliseconds: 200),
  });

  @override
  _AnimatedInkWellState createState() => _AnimatedInkWellState();
}

class _AnimatedInkWellState extends State<AnimatedInkWell> with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _scaleAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: widget.animationDuration,
    );
    _scaleAnimation = Tween<double>(begin: 1.0, end: 0.95).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _handleTapDown(TapDownDetails details) {
    _controller.forward();
  }

  void _handleTapUp(TapUpDetails details) {
    _controller.reverse().then((_) {
      widget.onTap();
    });
  }

  void _handleTapCancel() {
    _controller.reverse();
  }

  void _handleLongPress() async {
    await _controller.animateTo(0.90, duration: const Duration(milliseconds: 100));
    HapticFeedback.mediumImpact();
    widget.onLongPress?.call();
    _controller.reverse();
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTapDown: _handleTapDown,
      onTapUp: _handleTapUp,
      onTapCancel: _handleTapCancel,
      onLongPress: widget.onLongPress != null ? _handleLongPress : null,
      child: AnimatedBuilder(
        animation: _scaleAnimation,
        builder: (context, child) {
          return Transform.scale(
            scale: _scaleAnimation.value,
            child: Material(
              color: Colors.transparent,
              child: InkWell(
                splashColor: widget.splashColor ?? Theme.of(context).primaryColor.withOpacity(0.1),
                highlightColor: widget.highlightColor ?? Theme.of(context).primaryColor.withOpacity(0.05),
                borderRadius: widget.borderRadius,
                child: widget.child,
              ),
            ),
          );
        },
      ),
    );
  }
}