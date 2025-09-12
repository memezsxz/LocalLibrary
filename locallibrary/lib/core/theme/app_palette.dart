import 'package:flutter/material.dart';

class AppPalette {
  // Base
  static const Color background = Color.fromRGBO(255, 255, 255, 1);
  static const Color surface = Color.fromRGBO(254, 248, 243, 1); // lightMilky
  static const Color surfaceAlt = Color.fromRGBO(255, 244, 235, 1); // darkMilky

  // Primary / Accents
  static const Color primary = Color.fromRGBO(123, 62, 2, 1); // brown
  static const Color primaryLight = Color.fromRGBO(194, 176, 139, 1); // light
  static const Color primaryExtraLight = Color.fromRGBO(242 ,237 ,229, 1);
  static const Color secondary = Color.fromRGBO(216, 222, 234, 1); // lightBlue
  static const Color fiddle = Color.fromRGBO(242, 237, 229, 1); // lightBlue

  // Neutrals
  static const Color textPrimary = Color.fromRGBO(45, 45, 45, 1); // nearBlack
  static const Color textOnLight = Colors.white;
  static const Color neutral = Colors.grey;
  static const Color gray = Color.fromRGBO(141, 141, 141, 1);

  // States
  static const Color error = Colors.redAccent;
  static const Color transparent = Colors.transparent;

  // Shadows
  static const Color mainShadow = Color(0x40000000);
}
