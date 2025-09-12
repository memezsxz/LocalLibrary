import 'package:flutter/material.dart';

class RoundedContentOuter extends StatelessWidget {
  const RoundedContentOuter({
    super.key,
    required this.child,
    this.radius = const BorderRadius.only(
      topRight: Radius.circular(25),
      bottomRight: Radius.circular(25),
    ),
    this.clipBehavior = Clip.none, // mirrors your Stack clipBehavior usage
  });

  final Widget child;
  final BorderRadius radius;
  final Clip clipBehavior;

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: radius,
      child: Stack(clipBehavior: clipBehavior, children: [child]),
    );
  }
}
