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

  const AnimatedInkWell({
    Key? key,
    required this.child,
    this.onTap,
    this.onLongPress,
    this.splashColor,
    this.highlightColor,
    this.borderRadius,
    this.animationDuration = const Duration(milliseconds: 200),
  }) : super(key: key);

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
    _controller.reverse();
  }

  void _handleTapCancel() {
    _controller.reverse();
  }

  void _handleLongPressStart(LongPressStartDetails details) {
    _controller.forward();
    HapticFeedback.mediumImpact();
    if (widget.onLongPress != null) {
      widget.onLongPress!(details.globalPosition);
    }
  }

  void _handleLongPressEnd(LongPressEndDetails details) {
    _controller.reverse();
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTapDown: _handleTapDown,
      onTapUp: _handleTapUp,
      onTapCancel: _handleTapCancel,
      onLongPressStart: _handleLongPressStart,
      onLongPressEnd: _handleLongPressEnd,
      onTap: widget.onTap,
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