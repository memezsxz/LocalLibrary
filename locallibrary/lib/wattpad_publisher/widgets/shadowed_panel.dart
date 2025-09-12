import 'package:flutter/material.dart';

class ShadowedPanel extends StatelessWidget {
  const ShadowedPanel({
    super.key,
    required this.child,
    required this.margin,
    this.background = Colors.white,
    this.radius = const BorderRadius.all(Radius.circular(25)),
    this.shadow = const [
      BoxShadow(
        color: Color(0x1A000000), // match your AppPalette.mainShadow alpha
        offset: Offset(-1, 6),
        blurRadius: 34.6,
        spreadRadius: -5,
      ),
    ],
  });

  final Widget child;
  final EdgeInsets margin;
  final Color background;
  final BorderRadius radius;
  final List<BoxShadow> shadow;

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: margin,
      width: double.infinity,
      height: double.infinity,
      decoration: BoxDecoration(
        color: background,
        borderRadius: radius,
        boxShadow: shadow,
      ),
      child: child,
    );
  }
}
