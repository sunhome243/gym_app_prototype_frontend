import 'package:flutter/material.dart';

class AnimatedInkWell extends StatefulWidget {
  final Widget child;
  final VoidCallback onTap;
  final Color splashColor;
  final Color highlightColor;

  const AnimatedInkWell({
    Key? key,
    required this.child,
    required this.onTap,
    this.splashColor = Colors.blue,
    this.highlightColor = Colors.blueAccent,
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
      duration: const Duration(milliseconds: 150),
      vsync: this,
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

  @override
  Widget build(BuildContext context) {
    return ScaleTransition(
      scale: _scaleAnimation,
      child: InkWell(
        onTap: () {
          _controller.forward().then((_) {
            _controller.reverse();
          });
          widget.onTap();
        },
        splashColor: widget.splashColor.withOpacity(0.3),
        highlightColor: widget.highlightColor.withOpacity(0.1),
        customBorder: _getCustomBorder(context),
        child: widget.child,
      ),
    );
  }

  ShapeBorder _getCustomBorder(BuildContext context) {
    final BorderRadius? borderRadius = _getBorderRadius(context);
    return RoundedRectangleBorder(
      borderRadius: borderRadius ?? BorderRadius.zero,
    );
  }

  BorderRadius? _getBorderRadius(BuildContext context) {
    final BoxDecoration? decoration = context.findAncestorWidgetOfExactType<Container>()?.decoration as BoxDecoration?;
    return decoration?.borderRadius as BorderRadius?;
  }
}