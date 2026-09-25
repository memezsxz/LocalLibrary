import 'package:flutter/material.dart';

import 'app_palette.dart';

/// Hand-authored color schemes for the app.
///
/// Deliberately NOT generated from a single seed color (e.g. Material Theme
/// Builder's `ColorScheme.fromSeed`) — that approach derives every neutral
/// and surface tone algorithmically from the seed's hue, so nudging the
/// primary color retints backgrounds/surfaces along with it. Every color
/// below is fixed instead, so they can be tuned independently.
class MaterialTheme {
  final TextTheme textTheme;

  const MaterialTheme(this.textTheme);

  static const _lightScheme = ColorScheme(
    brightness: Brightness.light,
    primary: Color(0xFF7B3E02),
    onPrimary: Color(0xFFFFFFFF),
    primaryContainer: Color(0xFFEEDFC6),
    onPrimaryContainer: Color(0xFF4A2601),
    secondary: Color(0xFF5B6B84),
    onSecondary: Color(0xFFFFFFFF),
    secondaryContainer: Color(0xFFD8DEEA),
    onSecondaryContainer: Color(0xFF29344A),
    tertiary: Color(0xFF8A5021),
    onTertiary: Color(0xFFFFFFFF),
    tertiaryContainer: Color(0xFFFFDCC5),
    onTertiaryContainer: Color(0xFF6D390B),
    error: Color(0xFFBA1A1A),
    onError: Color(0xFFFFFFFF),
    errorContainer: Color(0xFFFFDAD6),
    onErrorContainer: Color(0xFF93000A),
    surface: Color(0xFFFFFFFF),
    onSurface: Color(0xFF2D2D2D),
    onSurfaceVariant: Color(0xFF5B5650),
    outline: Color(0xFF8D8577),
    outlineVariant: Color(0xFFE3DACB),
    shadow: Color(0xFF000000),
    scrim: Color(0xFF000000),
    inverseSurface: Color(0xFF2D2D2D),
    onInverseSurface: Color(0xFFF5F0E8),
    inversePrimary: Color(0xFFE7C26C),
    surfaceContainerLowest: Color(0xFFFFFFFF),
    surfaceContainerLow: Color(0xFFFEF8F3),
    surfaceContainer: Color(0xFFFFF4EB),
    surfaceContainerHigh: Color(0xFFF2EDE5),
    surfaceContainerHighest: Color(0xFFE8E0D3),
  );

  static const _darkScheme = ColorScheme(
    brightness: Brightness.dark,
    primary: Color(0xFFE3B673),
    onPrimary: Color(0xFF3D2405),
    primaryContainer: Color(0xFF5C3B10),
    onPrimaryContainer: Color(0xFFF7E1BB),
    secondary: Color(0xFFB8C4D9),
    onSecondary: Color(0xFF223247),
    secondaryContainer: Color(0xFF39485F),
    onSecondaryContainer: Color(0xFFDCE3F0),
    tertiary: Color(0xFFFFB37A),
    onTertiary: Color(0xFF4A2500),
    tertiaryContainer: Color(0xFF6B3D12),
    onTertiaryContainer: Color(0xFFFFDCC0),
    error: Color(0xFFFFB4AB),
    onError: Color(0xFF690005),
    errorContainer: Color(0xFF93000A),
    onErrorContainer: Color(0xFFFFDAD6),
    surface: Color(0xFF1B1712),
    onSurface: Color(0xFFEDE6DC),
    onSurfaceVariant: Color(0xFFCBBFAE),
    outline: Color(0xFF8F8371),
    outlineVariant: Color(0xFF4A4436),
    shadow: Color(0xFF000000),
    scrim: Color(0xFF000000),
    inverseSurface: Color(0xFFEDE6DC),
    onInverseSurface: Color(0xFF1B1712),
    inversePrimary: Color(0xFF7B3E02),
    surfaceContainerLowest: Color(0xFF120F0B),
    surfaceContainerLow: Color(0xFF211C16),
    surfaceContainer: Color(0xFF272119),
    surfaceContainerHigh: Color(0xFF2E271D),
    surfaceContainerHighest: Color(0xFF362E22),
  );

  ThemeData light() => theme(_lightScheme);

  ThemeData dark() => theme(_darkScheme);

  ThemeData theme(ColorScheme colorScheme) => ThemeData(
    useMaterial3: true,
    brightness: colorScheme.brightness,
    colorScheme: colorScheme,
    scaffoldBackgroundColor: colorScheme.surface,
    canvasColor: colorScheme.surface,
    textTheme: textTheme.apply(
      bodyColor: colorScheme.onSurface,
      displayColor: colorScheme.onSurface,
    ),
    extensions: [
      colorScheme.brightness == Brightness.dark
          ? AppColors.dark
          : AppColors.light,
    ],
  );
}
