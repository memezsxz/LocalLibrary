import 'package:flutter/material.dart';
import 'package:flutter_html/flutter_html.dart';
import 'package:google_fonts/google_fonts.dart';

/// Single source of truth for the app's theme.
///
/// Everything color-related lives in this one file — raw palette tokens,
/// the app's own semantic [AppColors] (read via `context.colors` almost
/// everywhere in the app), and the Material [ColorScheme]s that stock
/// widgets (SegmentedButton, Slider, Scaffold, ...) pick up automatically.
/// For dark, [AppColors] and the [ColorScheme] are built from the same raw
/// tokens below, so there is exactly one place to change a color. Light is
/// currently pinned to the original legacy palette instead (see
/// [_WarmLight]), independent of the parked Catppuccin Latte tokens.
///
/// Palette: light is the original hand-authored brand palette (warm
/// cream/brown); dark is Catppuccin Mocha (https://catppuccin.com/palette/)
/// with the brand brown kept as primary instead of Catppuccin's Mauve.
///
/// Catppuccin Latte (the light counterpart) is parked below, commented out —
/// swap [AppColors.light] and [MaterialTheme._lightScheme] back to it if the
/// light theme should go full-Catppuccin again later.

// ─── raw tokens ─────────────────────────────────────────────────────────────

// class _Latte {
//   static const base = Color(0xFFEFF1F5);
//   static const mantle = Color(0xFFE6E9EF);
//   static const crust = Color(0xFFDCE0E8);
//   static const surface0 = Color(0xFFCCD0DA);
//   static const surface1 = Color(0xFFBCC0CC);
//   static const surface2 = Color(0xFFACB0BE);
//   static const overlay0 = Color(0xFF9CA0B0);
//   static const text = Color(0xFF4C4F69);
//   static const subtext0 = Color(0xFF6C6F85);
//   static const blue = Color(0xFF1E66F5);
//   static const red = Color(0xFFD20F39);
//   static const maroon = Color(0xFFE64553);
//   static const peach = Color(0xFFFE640B);
//   static const green = Color(0xFF40A02B);
// }

/// Original hand-authored light palette (warm cream/brown) — active while
/// [_Latte] above is parked.
class _WarmLight {
  static const background = Color(0xFFFFFFFF);
  static const surface = Color(0xFFFEF8F3);
  static const surfaceAlt = Color(0xFFFFF4EB);
  static const primaryExtraLight = Color(0xFFF2EDE5);
  static const secondary = Color(0xFFD8DEEA);
  static const textPrimary = Color(0xFF2D2D2D);
  static const gray = Color(0xFF8D8D8D);
  static const error = Colors.redAccent;

  // ColorScheme-only tones (no AppColors equivalent).
  static const onSurfaceVariant = Color(0xFF5B5650);
  static const outline = Color(0xFF8D8577);
  static const outlineVariant = Color(0xFFE3DACB);
  static const secondaryDeep = Color(0xFF5B6B84);
  static const onSecondaryContainer = Color(0xFF29344A);
  static const tertiary = Color(0xFF8A5021);
  static const tertiaryContainer = Color(0xFFFFDCC5);
  static const onTertiaryContainer = Color(0xFF6D390B);
  static const errorScheme = Color(0xFFBA1A1A);
  static const errorContainer = Color(0xFFFFDAD6);
  static const onErrorContainer = Color(0xFF93000A);
  static const onInverseSurface = Color(0xFFF5F0E8);
  static const surfaceContainerHighest = Color(0xFFE8E0D3);
}

class _Mocha {
  static const base = Color(0xFF1E1E2E);
  static const mantle = Color(0xFF181825);
  static const crust = Color(0xFF11111B);
  static const surface0 = Color(0xFF313244);
  static const surface1 = Color(0xFF45475A);
  static const surface2 = Color(0xFF585B70);
  static const overlay0 = Color(0xFF6C7086);
  static const text = Color(0xFFCDD6F4);
  static const subtext0 = Color(0xFFA6ADC8);
  static const blue = Color(0xFF89B4FA);
  static const red = Color(0xFFF38BA8);
  static const maroon = Color(0xFFEBA0AC);
  static const peach = Color(0xFFFAB387);
  static const green = Color(0xFFA6E3A1);
}

/// The app's own brand brown, kept as primary instead of Catppuccin's Mauve.
/// Not part of Catppuccin — tuned to pair with its Latte/Mocha neutrals.
class _BrandBrown {
  static const light = Color(0xFF7B3E02);
  static const lightTan = Color(0xFFC2B08B);
  static const lightContainer = Color(0xFFEEDFC6);
  static const lightOnContainer = Color(0xFF4A2601);
  static const dark = Color(0xFFE3B673);
  static const darkOutline = Color(0xFF8F8371);
  static const darkContainer = Color(0xFF5C3B10);
  static const darkOnContainer = Color(0xFFF7E1BB);
  static const darkOnPrimary = Color(0xFF3D2405);
}

// ─── app colors (semantic, theme-aware) ────────────────────────────────────

/// Semantic color set resolved per-brightness via [ThemeData.extensions].
/// Read it through [AppColorsX] (`context.colors.x`) so widgets follow the
/// light/dark theme automatically.
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
    background: _WarmLight.background,
    surface: _WarmLight.surface,
    surfaceAlt: _WarmLight.surfaceAlt,
    primary: _BrandBrown.light,
    primaryLight: _BrandBrown.lightTan,
    primaryExtraLight: _WarmLight.primaryExtraLight,
    secondary: _WarmLight.secondary,
    textPrimary: _WarmLight.textPrimary,
    textOnLight: _WarmLight.background,
    gray: _WarmLight.gray,
    error: _WarmLight.error,
    success: Color(0xFF2E7D32),
    onSuccess: Colors.white,
  );

  static const dark = AppColors(
    background: _Mocha.base,
    surface: _Mocha.surface0,
    surfaceAlt: _Mocha.surface1,
    primary: _BrandBrown.dark,
    primaryLight: _BrandBrown.darkOutline,
    primaryExtraLight: _Mocha.surface2,
    secondary: _Mocha.blue,
    textPrimary: _Mocha.text,
    textOnLight: _BrandBrown.darkOnPrimary,
    gray: _Mocha.subtext0,
    error: _Mocha.red,
    success: _Mocha.green,
    onSuccess: _Mocha.crust,
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

// ─── material theme (ColorScheme / ThemeData) ──────────────────────────────

/// Deliberately NOT generated from a single seed color (e.g. Material Theme
/// Builder's `ColorScheme.fromSeed`) — that approach derives every neutral
/// and surface tone algorithmically from the seed's hue, so nudging the
/// primary color retints backgrounds/surfaces along with it.
///
/// [_darkScheme] reads fields shared with [AppColors.dark] directly from it
/// so the two can never diverge. [_lightScheme] is independent — the
/// original hand-authored light palette, parked separately from
/// [AppColors.light] rather than derived from it, since the light theme is
/// pinned to this exact legacy scheme for now (see [_WarmLight]).
class MaterialTheme {
  final TextTheme textTheme;

  const MaterialTheme(this.textTheme);

  static const _lightScheme = ColorScheme(
    brightness: Brightness.light,
    primary: _BrandBrown.light,
    onPrimary: Colors.white,
    primaryContainer: _BrandBrown.lightContainer,
    onPrimaryContainer: _BrandBrown.lightOnContainer,
    secondary: _WarmLight.secondaryDeep,
    onSecondary: Colors.white,
    secondaryContainer: _WarmLight.secondary,
    onSecondaryContainer: _WarmLight.onSecondaryContainer,
    tertiary: _WarmLight.tertiary,
    onTertiary: Colors.white,
    tertiaryContainer: _WarmLight.tertiaryContainer,
    onTertiaryContainer: _WarmLight.onTertiaryContainer,
    error: _WarmLight.errorScheme,
    onError: Colors.white,
    errorContainer: _WarmLight.errorContainer,
    onErrorContainer: _WarmLight.onErrorContainer,
    surface: _WarmLight.background,
    onSurface: _WarmLight.textPrimary,
    onSurfaceVariant: _WarmLight.onSurfaceVariant,
    outline: _WarmLight.outline,
    outlineVariant: _WarmLight.outlineVariant,
    shadow: Color(0xFF000000),
    scrim: Color(0xFF000000),
    inverseSurface: _WarmLight.textPrimary,
    onInverseSurface: _WarmLight.onInverseSurface,
    inversePrimary: _BrandBrown.dark,
    surfaceContainerLowest: _WarmLight.background,
    surfaceContainerLow: _WarmLight.surface,
    surfaceContainer: _WarmLight.surfaceAlt,
    surfaceContainerHigh: _WarmLight.primaryExtraLight,
    surfaceContainerHighest: _WarmLight.surfaceContainerHighest,
  );

  static ColorScheme get _darkScheme =>
      ColorScheme(
        brightness: Brightness.dark,
        primary: AppColors.dark.primary,
        onPrimary: AppColors.dark.textOnLight,
        primaryContainer: _BrandBrown.darkContainer,
        onPrimaryContainer: _BrandBrown.darkOnContainer,
        secondary: AppColors.dark.secondary,
        onSecondary: AppColors.dark.textOnLight,
        secondaryContainer: AppColors.dark.surface,
        onSecondaryContainer: AppColors.dark.textPrimary,
        tertiary: _Mocha.peach,
        onTertiary: AppColors.dark.textOnLight,
        tertiaryContainer: AppColors.dark.surfaceAlt,
        onTertiaryContainer: AppColors.dark.textPrimary,
        error: AppColors.dark.error,
        onError: AppColors.dark.textOnLight,
        errorContainer: _Mocha.maroon,
        onErrorContainer: AppColors.dark.textOnLight,
        surface: AppColors.dark.background,
        onSurface: AppColors.dark.textPrimary,
        onSurfaceVariant: AppColors.dark.gray,
        outline: _Mocha.overlay0,
        outlineVariant: AppColors.dark.primaryExtraLight,
        shadow: Color(0xFF000000),
        scrim: Color(0xFF000000),
        inverseSurface: AppColors.dark.textPrimary,
        onInverseSurface: AppColors.dark.background,
        inversePrimary: _BrandBrown.light,
        surfaceContainerLowest: _Mocha.crust,
        surfaceContainerLow: _Mocha.mantle,
        surfaceContainer: AppColors.dark.background,
        surfaceContainerHigh: AppColors.dark.surface,
        surfaceContainerHighest: AppColors.dark.surfaceAlt,
      );

  ThemeData light() => theme(_lightScheme);

  ThemeData dark() => theme(_darkScheme);

  ThemeData theme(ColorScheme colorScheme) =>
      ThemeData(
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

// ─── html paragraph style ───────────────────────────────────────────────────

class AppTheme {
  // The one place in the app where long-form reading actually happens —
  // moved to a literary serif (mockup's Source Serif 4) rather than the
  // app's default UI font used everywhere else.
  static Style paragraphsStyle(BuildContext context) {
    final serif = GoogleFonts.sourceSerif4();
    final isDesktop = MediaQuery
        .of(context)
        .size
        .width >= 900;
    return Style(
      margin: Margins.zero,
      padding: HtmlPaddings.zero,
      lineHeight: LineHeight.number(1.75),
      fontSize: FontSize(isDesktop ? 16.5 : 15.5),
      fontFamily: serif.fontFamily,
      fontFamilyFallback: serif.fontFamilyFallback,
      color: context.colors.textPrimary,
      textDecorationColor: context.colors.textPrimary,
    );
  }
}
