import 'package:flutter/material.dart';

class Background extends StatelessWidget {
  final Widget child;
  final double height;
  final List<Color> colors;

  const Background({
    Key? key,
    required this.child,
    required this.height,
    this.colors = const [Color(0xFF4CD964), Colors.white],
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        Hero(
          tag: 'background',
          child: Container(
            height: height,
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: colors,
              ),
            ),
          ),
        ),
        SafeArea(child: child),
      ],
    );
  }
}