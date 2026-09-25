import 'package:flutter/material.dart';

class AppPalette {
  // Base
  static const Color background = Color.fromRGBO(255, 255, 255, 1);
  static const Color surface = Color.fromRGBO(254, 248, 243, 1); // lightMilky
  static const Color surfaceAlt = Color.fromRGBO(255, 244, 235, 1); // darkMilky

  // Primary / Accents
  static const Color primary = Color.fromRGBO(123, 62, 2, 1); // brown
  static const Color primaryLight = Color.fromRGBO(194, 176, 139, 1); // light
  static const Color primaryExtraLight = Color.fromRGBO(242, 237, 229, 1);
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

/// Theme-aware counterpart to [AppPalette]. Same named colors, but resolved
/// per-brightness via [ThemeData.extensions] so widgets that read them
/// through [AppColorsX] (`context.colors.x`) automatically follow the
/// light/dark theme instead of always rendering [AppPalette]'s light values.
@immutable
class AppColors extends ThemeExtension<AppColors> {
  final Color background;
  final Color surface;
  final Color surfaceAlt;
  final Color primary;
  final Color primaryLight;
  final Color primaryExtraLight;
  final Color secondary;
  final Color textPrimary;
  final Color textOnLight;
  final Color gray;
  final Color error;
  final Color success;
  final Color onSuccess;

  const AppColors({
    required this.background,
    required this.surface,
    required this.surfaceAlt,
    required this.primary,
    required this.primaryLight,
    required this.primaryExtraLight,
    required this.secondary,
    required this.textPrimary,
    required this.textOnLight,
    required this.gray,
    required this.error,
    required this.success,
    required this.onSuccess,
  });

  static const light = AppColors(
    background: AppPalette.background,
    surface: AppPalette.surface,
    surfaceAlt: AppPalette.surfaceAlt,
    primary: AppPalette.primary,
    primaryLight: AppPalette.primaryLight,
    primaryExtraLight: AppPalette.primaryExtraLight,
    secondary: AppPalette.secondary,
    textPrimary: AppPalette.textPrimary,
    textOnLight: AppPalette.textOnLight,
    gray: AppPalette.gray,
    error: AppPalette.error,
    success: Color(0xFF2E7D32),
    onSuccess: Colors.white,
  );

  static const dark = AppColors(
    background: Color(0xFF1B1712),
    surface: Color(0xFF211C16),
    surfaceAlt: Color(0xFF272119),
    primary: Color(0xFFE3B673),
    primaryLight: Color(0xFF8F8371),
    // A clear step above surfaceAlt (not just +1 tonal notch) so dividers,
    // chip/badge backgrounds, and card borders stay legible on dark surfaces.
    primaryExtraLight: Color(0xFF362E22),
    secondary: Color(0xFF39485F),
    textPrimary: Color(0xFFEDE6DC),
    textOnLight: Color(0xFF3D2405),
    gray: Color(0xFFCBBFAE),
    error: Color(0xFFFFB4AB),
    success: Color(0xFF8FD99F),
    onSuccess: Color(0xFF0B3A11),
  );

  @override
  AppColors copyWith({
    Color? background,
    Color? surface,
    Color? surfaceAlt,
    Color? primary,
    Color? primaryLight,
    Color? primaryExtraLight,
    Color? secondary,
    Color? textPrimary,
    Color? textOnLight,
    Color? gray,
    Color? error,
    Color? success,
    Color? onSuccess,
  }) =>
      AppColors(
        background: background ?? this.background,
        surface: surface ?? this.surface,
        surfaceAlt: surfaceAlt ?? this.surfaceAlt,
        primary: primary ?? this.primary,
        primaryLight: primaryLight ?? this.primaryLight,
        primaryExtraLight: primaryExtraLight ?? this.primaryExtraLight,
        secondary: secondary ?? this.secondary,
        textPrimary: textPrimary ?? this.textPrimary,
        textOnLight: textOnLight ?? this.textOnLight,
        gray: gray ?? this.gray,
        error: error ?? this.error,
        success: success ?? this.success,
        onSuccess: onSuccess ?? this.onSuccess,
      );

  @override
  AppColors lerp(ThemeExtension<AppColors>? other, double t) {
    if (other is! AppColors) return this;
    return AppColors(
      background: Color.lerp(background, other.background, t)!,
      surface: Color.lerp(surface, other.surface, t)!,
      surfaceAlt: Color.lerp(surfaceAlt, other.surfaceAlt, t)!,
      primary: Color.lerp(primary, other.primary, t)!,
      primaryLight: Color.lerp(primaryLight, other.primaryLight, t)!,
      primaryExtraLight: Color.lerp(
        primaryExtraLight,
        other.primaryExtraLight,
        t,
      )!,
      secondary: Color.lerp(secondary, other.secondary, t)!,
      textPrimary: Color.lerp(textPrimary, other.textPrimary, t)!,
      textOnLight: Color.lerp(textOnLight, other.textOnLight, t)!,
      gray: Color.lerp(gray, other.gray, t)!,
      error: Color.lerp(error, other.error, t)!,
      success: Color.lerp(success, other.success, t)!,
      onSuccess: Color.lerp(onSuccess, other.onSuccess, t)!,
    );
  }
}

extension AppColorsX on BuildContext {
  AppColors get colors =>
      Theme.of(this).extension<AppColors>() ?? AppColors.light;
}
