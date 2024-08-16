import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class AnimatedInkWell extends StatefulWidget {
  final Widget child;
  final VoidCallback? onTap;
  final Function(Offset)? onLongPress;
  final Color? splashColor;
  final Color? highlightColor;
  final BorderRadius? borderRadius;
  final Duration tapDuration;
  final Duration longPressDuration;
  final bool enableFeedback;

  const AnimatedInkWell({
    super.key,
    required this.child,
    this.onTap,
    this.onLongPress,
    this.splashColor,
    this.highlightColor,
    this.borderRadius,
    this.tapDuration = const Duration(milliseconds: 1),
    this.longPressDuration = const Duration(milliseconds: 100),
    this.enableFeedback = true,
  });

  @override
  _AnimatedInkWellState createState() => _AnimatedInkWellState();
}

class _AnimatedInkWellState extends State<AnimatedInkWell> with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _scaleAnimation;
  bool _isLongPressed = false;
  Offset? _tapPosition;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: widget.longPressDuration,
    );
    _scaleAnimation = TweenSequence<double>([
      TweenSequenceItem(
        tween: Tween<double>(begin: 1.0, end: 0.9)
            .chain(CurveTween(curve: Curves.easeOutCubic)),
        weight: 30.0,
      ),
      TweenSequenceItem(
        tween: Tween<double>(begin: 0.90, end: 0.85)
            .chain(CurveTween(curve: Curves.easeInOutCubic)),
        weight: 70.0,
      ),
    ]).animate(_controller);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _handleTapDown(TapDownDetails details) {
    _tapPosition = details.globalPosition;
    _controller.animateTo(0.3, duration: widget.tapDuration);
    if (widget.enableFeedback) {
      HapticFeedback.selectionClick();
    }
  }

  void _handleTapUp(TapUpDetails details) {
    if (!_isLongPressed) {
      _controller.reverse();
      if (widget.onTap != null) {
        widget.onTap!();
      }
    }
    _resetState();
  }

  void _handleTapCancel() {
    _resetState();
  }

  void _handleLongPressStart(LongPressStartDetails details) {
    setState(() {
      _isLongPressed = true;
    });
    _controller.animateTo(1.0, duration: widget.longPressDuration - widget.tapDuration);
    if (widget.onLongPress != null) {
      widget.onLongPress!(details.globalPosition);
      if (widget.enableFeedback) {
        HapticFeedback.mediumImpact();
      }
    }
  }

  void _handleLongPressMoveUpdate(LongPressMoveUpdateDetails details) {
    if (_isLongPressed && widget.onLongPress != null) {
      widget.onLongPress!(details.globalPosition);
    }
  }

  void _handleLongPressEnd(LongPressEndDetails details) {
    if (_isLongPressed && widget.onLongPress != null) {
      widget.onLongPress!(details.globalPosition);
    }
    _resetState();
  }

  void _resetState() {
    setState(() {
      _isLongPressed = false;
    });
    _controller.reverse();
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTapDown: _handleTapDown,
      onTapUp: _handleTapUp,
      onTapCancel: _handleTapCancel,
      onLongPressStart: _handleLongPressStart,
      onLongPressMoveUpdate: _handleLongPressMoveUpdate,
      onLongPressEnd: _handleLongPressEnd,
      child: AnimatedBuilder(
        animation: _controller,
        builder: (context, child) {
          return Transform.scale(
            scale: _scaleAnimation.value,
            child: Stack(
              children: [
                Material(
                  color: Colors.transparent,
                  child: Ink(
                    decoration: BoxDecoration(
                      borderRadius: widget.borderRadius,
                    ),
                    child: InkWell(
                      splashColor: widget.splashColor ?? Theme.of(context).primaryColor.withOpacity(0.3),
                      highlightColor: widget.highlightColor ?? Theme.of(context).primaryColor.withOpacity(0.1),
                      borderRadius: widget.borderRadius,
                      child: widget.child,
                    ),
                  ),
                ),
                if (_tapPosition != null)
                  Positioned(
                    left: _tapPosition!.dx - 25,
                    top: _tapPosition!.dy - 25,
                    child: TweenAnimationBuilder<double>(
                      tween: Tween(begin: 0.0, end: 1.0),
                      duration: const Duration(milliseconds: 300),
                      builder: (context, value, child) {
                        return Opacity(
                          opacity: 1 - value,
                          child: Transform.scale(
                            scale: value,
                            child: Container(
                              width: 50,
                              height: 50,
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                color: Theme.of(context).primaryColor.withOpacity(0.3),
                              ),
                            ),
                          ),
                        );
                      },
                    ),
                  ),
              ],
            ),
          );
        },
      ),
    );
  }
}