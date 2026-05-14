import 'package:flutter/material.dart';

class TopOnlyClip extends CustomClipper<Rect> {
  final double expandSides;
  final double expandBottom;

  const TopOnlyClip({this.expandSides = 24, this.expandBottom = 24});

  @override
  Rect getClip(Size size) => Rect.fromLTRB(
    -expandSides,
    0,
    size.width + expandSides,
    size.height + expandBottom,
  );

  @override
  bool shouldReclip(TopOnlyClip old) =>
      expandSides != old.expandSides || expandBottom != old.expandBottom;
}

class _BottomOnlyClip extends CustomClipper<Rect> {
  final double expand;

  const _BottomOnlyClip({this.expand = 20});

  @override
  Rect getClip(Size size) =>
      Rect.fromLTRB(-expand, -expand, size.width + expand, size.height);

  @override
  bool shouldReclip(covariant _BottomOnlyClip old) => old.expand != expand;
}
