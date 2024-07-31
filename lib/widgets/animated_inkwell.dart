import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class AnimatedInkWell extends StatefulWidget {
  final Widget child;
  final VoidCallback? onTap;
  final Function(Offset)? onLongPress;
  final Color? splashColor;
  final Color? highlightColor;
  final BorderRadius? borderRadius;
  final Duration animationDuration;
  final bool enableTapFeedback;

  const AnimatedInkWell({
    super.key,
    required this.child,
    this.onTap,
    this.onLongPress,
    this.splashColor,
    this.highlightColor,
    this.borderRadius,
    this.animationDuration = const Duration(milliseconds: 150),
    this.enableTapFeedback = false,
  });

  @override
  _AnimatedInkWellState createState() => _AnimatedInkWellState();
}

class _AnimatedInkWellState extends State<AnimatedInkWell> with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _scaleAnimation;
  late Animation<double> _opacityAnimation;
  bool _isPressed = false;
  bool _isLongPressed = false;

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
    _opacityAnimation = Tween<double>(begin: 1.0, end: 0.7).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _handleTapDown(TapDownDetails details) {
    _isPressed = true;
    _controller.forward();
    if (widget.enableTapFeedback) {
      HapticFeedback.lightImpact();
    }
  }

  void _handleTapUp(TapUpDetails details) {
    _isPressed = false;
    _controller.reverse();
    if (!_isLongPressed && widget.onTap != null) {
      widget.onTap!();
    }
    _isLongPressed = false;
  }

  void _handleTapCancel() {
    _isPressed = false;
    _controller.reverse();
    _isLongPressed = false;
  }

  void _handleLongPressStart(LongPressStartDetails details) {
    _isLongPressed = true;
    _isPressed = true;
    _controller.forward();
    if (widget.enableTapFeedback) {
      HapticFeedback.mediumImpact();
    }
    if (widget.onLongPress != null) {
      widget.onLongPress!(details.globalPosition);
    }
  }

  void _handleLongPressEnd(LongPressEndDetails details) {
    _isPressed = false;
    if (widget.onLongPress == null && widget.onTap != null) {
      widget.onTap!();
    }
    // Don't reset _isLongPressed here
  }

  @override
  Widget build(BuildContext context) {
    return Listener(
      onPointerUp: (_) {
        if (_isPressed) {
          _isPressed = false;
          _controller.reverse();
        }
      },
      child: GestureDetector(
        onTapDown: _handleTapDown,
        onTapUp: _handleTapUp,
        onTapCancel: _handleTapCancel,
        onLongPressStart: _handleLongPressStart,
        onLongPressEnd: _handleLongPressEnd,
        child: AnimatedBuilder(
          animation: _controller,
          builder: (context, child) {
            return Transform.scale(
              scale: _scaleAnimation.value,
              child: Opacity(
                opacity: _opacityAnimation.value,
                child: Material(
                  color: Colors.transparent,
                  child: Ink(
                    decoration: BoxDecoration(
                      borderRadius: widget.borderRadius,
                    ),
                    child: InkWell(
                      splashColor: widget.splashColor ?? Theme.of(context).primaryColor.withOpacity(0.1),
                      highlightColor: widget.highlightColor ?? Theme.of(context).primaryColor.withOpacity(0.05),
                      borderRadius: widget.borderRadius,
                      child: widget.child,
                    ),
                  ),
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}