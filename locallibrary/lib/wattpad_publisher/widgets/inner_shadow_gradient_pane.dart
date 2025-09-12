import 'package:flutter/material.dart';
import 'package:flutter_inner_shadow/flutter_inner_shadow.dart';

class InnerShadowGradientPane extends StatelessWidget {
  const InnerShadowGradientPane({
    super.key,
    required this.child,
    this.outerPadding = const EdgeInsets.all(15),
    this.innerPadding = const EdgeInsets.all(20),
    this.innerRadius = const BorderRadius.all(Radius.circular(20)),
    this.gradient = const LinearGradient(
      colors: [Color(0xffFEF8F3), Color(0xffFFF4EB)],
      begin: Alignment.topCenter,
      end: Alignment.bottomCenter,
    ),
    this.shadowColor = const Color(0x1A000000),
    this.shadowBlur = 30,
    this.shadowOffset = const Offset(-8, 4),
  });

  final Widget child;
  final EdgeInsets outerPadding;
  final EdgeInsets innerPadding;
  final BorderRadius innerRadius;
  final Gradient gradient;
  final Color shadowColor;
  final double shadowBlur;
  final Offset shadowOffset;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: outerPadding,
      child: ClipRRect(
        borderRadius: innerRadius,
        child: InnerShadow(
          shadows: [
            Shadow(
              color: shadowColor,
              blurRadius: shadowBlur,
              offset: shadowOffset,
            ),
          ],
          child: Container(
            width: double.infinity,
            height: double.infinity,
            padding: innerPadding,
            decoration: BoxDecoration(gradient: gradient),
            child: child,
          ),
        ),
      ),
    );
  }
}
