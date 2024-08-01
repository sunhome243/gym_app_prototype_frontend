import 'package:flutter/material.dart';

class Background extends StatelessWidget {
  final double? width;
  final double? height;
  final List<Color> colors;
  final List<double> stops;
  final AlignmentGeometry begin;
  final AlignmentGeometry end;
  final String? heroTag;
  final double verticalRadius;
  final double horizontalRadius;
  final bool roundTopLeft;
  final bool roundTopRight;
  final bool roundBottomLeft;
  final bool roundBottomRight;
  final Alignment alignment;

  const Background({
    super.key,
    this.width,
    this.height,
    required this.colors,
    required this.stops,
    this.begin = Alignment.topCenter,
    this.end = Alignment.bottomCenter,
    this.heroTag,
    this.verticalRadius = 0.0,
    this.horizontalRadius = 0.0,
    this.roundTopLeft = false,
    this.roundTopRight = false,
    this.roundBottomLeft = false,
    this.roundBottomRight = false,
    this.alignment = Alignment.center,
  }) : assert(colors.length == stops.length);

  @override
  Widget build(BuildContext context) {
    Widget gradientContainer = Container(
      width: width,
      height: height,
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: begin,
          end: end,
          colors: colors,
          stops: stops,
        ),
        borderRadius: BorderRadius.only(
          topLeft: roundTopLeft
              ? Radius.elliptical(horizontalRadius, verticalRadius)
              : Radius.zero,
          topRight: roundTopRight
              ? Radius.elliptical(horizontalRadius, verticalRadius)
              : Radius.zero,
          bottomLeft: roundBottomLeft
              ? Radius.elliptical(horizontalRadius, verticalRadius)
              : Radius.zero,
          bottomRight: roundBottomRight
              ? Radius.elliptical(horizontalRadius, verticalRadius)
              : Radius.zero,
        ),
      ),
    );

    if (heroTag != null) {
      return Hero(
        tag: heroTag!,
        child: gradientContainer,
      );
    }

    return Align(
      alignment: alignment,
      child: gradientContainer,
    );
  }
}