import 'package:flutter/material.dart';

class AnimatedInkWell extends StatelessWidget {
  final Widget child;
  final VoidCallback onTap;
  final Color? splashColor;
  final BorderRadius? borderRadius;

  const AnimatedInkWell({
    Key? key,
    required this.child,
    required this.onTap,
    this.splashColor,
    this.borderRadius,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      splashColor: splashColor ?? Theme.of(context).primaryColor.withOpacity(0.1),
      borderRadius: borderRadius,
      child: child,
    );
  }
}