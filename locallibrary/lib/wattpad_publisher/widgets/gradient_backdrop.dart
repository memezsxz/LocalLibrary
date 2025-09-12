import 'package:flutter/material.dart';

class GradientBackdrop extends StatelessWidget {
  const GradientBackdrop({
    super.key,
    required this.child,
    this.colors = const [Colors.white, Color(0xFFEAF2FF)],
    this.begin = Alignment.topLeft,
    this.end = Alignment.bottomRight,
  });

  final Widget child;
  final List<Color> colors;
  final AlignmentGeometry begin;
  final AlignmentGeometry end;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(colors: colors, begin: begin, end: end),
      ),
      child: child,
    );
  }
}
