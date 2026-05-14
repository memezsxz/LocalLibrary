import "package:flutter/material.dart";

class MaterialTheme {
  final TextTheme textTheme;

  const MaterialTheme(this.textTheme);

  static ColorScheme lightScheme() {
    return const ColorScheme(
      brightness: Brightness.light,
      primary: Color(0xff765a0b),
      surfaceTint: Color(0xff765a0b),
      onPrimary: Color(0xffffffff),
      primaryContainer: Color(0xffffdf98),
      onPrimaryContainer: Color(0xff5a4300),
      secondary: Color(0xff00696d),
      onSecondary: Color(0xffffffff),
      secondaryContainer: Color(0xff9cf1f5),
      onSecondaryContainer: Color(0xff004f52),
      tertiary: Color(0xff8a5021),
      onTertiary: Color(0xffffffff),
      tertiaryContainer: Color(0xffffdcc5),
      onTertiaryContainer: Color(0xff6d390b),
      error: Color(0xffba1a1a),
      onError: Color(0xffffffff),
      errorContainer: Color(0xffffdad6),
      onErrorContainer: Color(0xff93000a),
      surface: Color(0xfff5fafb),
      onSurface: Color(0xff171d1e),
      onSurfaceVariant: Color(0xff4d4639),
      outline: Color(0xff7e7667),
      outlineVariant: Color(0xffd0c5b4),
      shadow: Color(0xff000000),
      scrim: Color(0xff000000),
      inverseSurface: Color(0xff2b3133),
      inversePrimary: Color(0xffe7c26c),
      primaryFixed: Color(0xffffdf98),
      onPrimaryFixed: Color(0xff251a00),
      primaryFixedDim: Color(0xffe7c26c),
      onPrimaryFixedVariant: Color(0xff5a4300),
      secondaryFixed: Color(0xff9cf1f5),
      onSecondaryFixed: Color(0xff002021),
      secondaryFixedDim: Color(0xff80d4d8),
      onSecondaryFixedVariant: Color(0xff004f52),
      tertiaryFixed: Color(0xffffdcc5),
      onTertiaryFixed: Color(0xff301400),
      tertiaryFixedDim: Color(0xffffb783),
      onTertiaryFixedVariant: Color(0xff6d390b),
      surfaceDim: Color(0xffd5dbdc),
      surfaceBright: Color(0xfff5fafb),
      surfaceContainerLowest: Color(0xffffffff),
      surfaceContainerLow: Color(0xffeff5f6),
      surfaceContainer: Color(0xffe9eff0),
      surfaceContainerHigh: Color(0xffe3e9ea),
      surfaceContainerHighest: Color(0xffdee3e5),
    );
  }

  ThemeData light() {
    return theme(lightScheme());
  }

  static ColorScheme lightMediumContrastScheme() {
    return const ColorScheme(
      brightness: Brightness.light,
      primary: Color(0xff463300),
      surfaceTint: Color(0xff765a0b),
      onPrimary: Color(0xffffffff),
      primaryContainer: Color(0xff86691c),
      onPrimaryContainer: Color(0xffffffff),
      secondary: Color(0xff003d3f),
      onSecondary: Color(0xffffffff),
      secondaryContainer: Color(0xff16797d),
      onSecondaryContainer: Color(0xffffffff),
      tertiary: Color(0xff572a00),
      onTertiary: Color(0xffffffff),
      tertiaryContainer: Color(0xff9b5e2e),
      onTertiaryContainer: Color(0xffffffff),
      error: Color(0xff740006),
      onError: Color(0xffffffff),
      errorContainer: Color(0xffcf2c27),
      onErrorContainer: Color(0xffffffff),
      surface: Color(0xfff5fafb),
      onSurface: Color(0xff0c1213),
      onSurfaceVariant: Color(0xff3c3529),
      outline: Color(0xff595244),
      outlineVariant: Color(0xff746c5d),
      shadow: Color(0xff000000),
      scrim: Color(0xff000000),
      inverseSurface: Color(0xff2b3133),
      inversePrimary: Color(0xffe7c26c),
      primaryFixed: Color(0xff86691c),
      onPrimaryFixed: Color(0xffffffff),
      primaryFixedDim: Color(0xff6b5100),
      onPrimaryFixedVariant: Color(0xffffffff),
      secondaryFixed: Color(0xff16797d),
      onSecondaryFixed: Color(0xffffffff),
      secondaryFixedDim: Color(0xff005f62),
      onSecondaryFixedVariant: Color(0xffffffff),
      tertiaryFixed: Color(0xff9b5e2e),
      onTertiaryFixed: Color(0xffffffff),
      tertiaryFixedDim: Color(0xff7e4718),
      onTertiaryFixedVariant: Color(0xffffffff),
      surfaceDim: Color(0xffc2c7c9),
      surfaceBright: Color(0xfff5fafb),
      surfaceContainerLowest: Color(0xffffffff),
      surfaceContainerLow: Color(0xffeff5f6),
      surfaceContainer: Color(0xffe3e9ea),
      surfaceContainerHigh: Color(0xffd8dedf),
      surfaceContainerHighest: Color(0xffcdd3d4),
    );
  }

  ThemeData lightMediumContrast() {
    return theme(lightMediumContrastScheme());
  }

  static ColorScheme lightHighContrastScheme() {
    return const ColorScheme(
      brightness: Brightness.light,
      primary: Color(0xff392a00),
      surfaceTint: Color(0xff765a0b),
      onPrimary: Color(0xffffffff),
      primaryContainer: Color(0xff5d4600),
      onPrimaryContainer: Color(0xffffffff),
      secondary: Color(0xff003234),
      onSecondary: Color(0xffffffff),
      secondaryContainer: Color(0xff005255),
      onSecondaryContainer: Color(0xffffffff),
      tertiary: Color(0xff492200),
      onTertiary: Color(0xffffffff),
      tertiaryContainer: Color(0xff703c0d),
      onTertiaryContainer: Color(0xffffffff),
      error: Color(0xff600004),
      onError: Color(0xffffffff),
      errorContainer: Color(0xff98000a),
      onErrorContainer: Color(0xffffffff),
      surface: Color(0xfff5fafb),
      onSurface: Color(0xff000000),
      onSurfaceVariant: Color(0xff000000),
      outline: Color(0xff312b1f),
      outlineVariant: Color(0xff4f483b),
      shadow: Color(0xff000000),
      scrim: Color(0xff000000),
      inverseSurface: Color(0xff2b3133),
      inversePrimary: Color(0xffe7c26c),
      primaryFixed: Color(0xff5d4600),
      onPrimaryFixed: Color(0xffffffff),
      primaryFixedDim: Color(0xff413000),
      onPrimaryFixedVariant: Color(0xffffffff),
      secondaryFixed: Color(0xff005255),
      onSecondaryFixed: Color(0xffffffff),
      secondaryFixedDim: Color(0xff00393b),
      onSecondaryFixedVariant: Color(0xffffffff),
      tertiaryFixed: Color(0xff703c0d),
      onTertiaryFixed: Color(0xffffffff),
      tertiaryFixedDim: Color(0xff522700),
      onTertiaryFixedVariant: Color(0xffffffff),
      surfaceDim: Color(0xffb4babb),
      surfaceBright: Color(0xfff5fafb),
      surfaceContainerLowest: Color(0xffffffff),
      surfaceContainerLow: Color(0xffecf2f3),
      surfaceContainer: Color(0xffdee3e5),
      surfaceContainerHigh: Color(0xffcfd5d6),
      surfaceContainerHighest: Color(0xffc2c7c9),
    );
  }

  ThemeData lightHighContrast() {
    return theme(lightHighContrastScheme());
  }

  static ColorScheme darkScheme() {
    return const ColorScheme(
      brightness: Brightness.dark,
      primary: Color(0xffe7c26c),
      surfaceTint: Color(0xffe7c26c),
      onPrimary: Color(0xff3e2e00),
      primaryContainer: Color(0xff5a4300),
      onPrimaryContainer: Color(0xffffdf98),
      secondary: Color(0xff80d4d8),
      onSecondary: Color(0xff003739),
      secondaryContainer: Color(0xff004f52),
      onSecondaryContainer: Color(0xff9cf1f5),
      tertiary: Color(0xffffb783),
      onTertiary: Color(0xff4f2500),
      tertiaryContainer: Color(0xff6d390b),
      onTertiaryContainer: Color(0xffffdcc5),
      error: Color(0xffffb4ab),
      onError: Color(0xff690005),
      errorContainer: Color(0xff93000a),
      onErrorContainer: Color(0xffffdad6),
      surface: Color(0xff0e1415),
      onSurface: Color(0xffdee3e5),
      onSurfaceVariant: Color(0xffd0c5b4),
      outline: Color(0xff999080),
      outlineVariant: Color(0xff4d4639),
      shadow: Color(0xff000000),
      scrim: Color(0xff000000),
      inverseSurface: Color(0xffdee3e5),
      inversePrimary: Color(0xff765a0b),
      primaryFixed: Color(0xffffdf98),
      onPrimaryFixed: Color(0xff251a00),
      primaryFixedDim: Color(0xffe7c26c),
      onPrimaryFixedVariant: Color(0xff5a4300),
      secondaryFixed: Color(0xff9cf1f5),
      onSecondaryFixed: Color(0xff002021),
      secondaryFixedDim: Color(0xff80d4d8),
      onSecondaryFixedVariant: Color(0xff004f52),
      tertiaryFixed: Color(0xffffdcc5),
      onTertiaryFixed: Color(0xff301400),
      tertiaryFixedDim: Color(0xffffb783),
      onTertiaryFixedVariant: Color(0xff6d390b),
      surfaceDim: Color(0xff0e1415),
      surfaceBright: Color(0xff343a3b),
      surfaceContainerLowest: Color(0xff090f10),
      surfaceContainerLow: Color(0xff171d1e),
      surfaceContainer: Color(0xff1b2122),
      surfaceContainerHigh: Color(0xff252b2c),
      surfaceContainerHighest: Color(0xff303637),
    );
  }

  ThemeData dark() {
    return theme(darkScheme());
  }

  static ColorScheme darkMediumContrastScheme() {
    return const ColorScheme(
      brightness: Brightness.dark,
      primary: Color(0xfffed87f),
      surfaceTint: Color(0xffe7c26c),
      onPrimary: Color(0xff312400),
      primaryContainer: Color(0xffad8d3d),
      onPrimaryContainer: Color(0xff000000),
      secondary: Color(0xff96eaee),
      onSecondary: Color(0xff002b2d),
      secondaryContainer: Color(0xff479da1),
      onSecondaryContainer: Color(0xff000000),
      tertiary: Color(0xffffd4b7),
      onTertiary: Color(0xff3f1c00),
      tertiaryContainer: Color(0xffc5814e),
      onTertiaryContainer: Color(0xff000000),
      error: Color(0xffffd2cc),
      onError: Color(0xff540003),
      errorContainer: Color(0xffff5449),
      onErrorContainer: Color(0xff000000),
      surface: Color(0xff0e1415),
      onSurface: Color(0xffffffff),
      onSurfaceVariant: Color(0xffe6dbc9),
      outline: Color(0xffbbb1a0),
      outlineVariant: Color(0xff988f7f),
      shadow: Color(0xff000000),
      scrim: Color(0xff000000),
      inverseSurface: Color(0xffdee3e5),
      inversePrimary: Color(0xff5b4500),
      primaryFixed: Color(0xffffdf98),
      onPrimaryFixed: Color(0xff181000),
      primaryFixedDim: Color(0xffe7c26c),
      onPrimaryFixedVariant: Color(0xff463300),
      secondaryFixed: Color(0xff9cf1f5),
      onSecondaryFixed: Color(0xff001415),
      secondaryFixedDim: Color(0xff80d4d8),
      onSecondaryFixedVariant: Color(0xff003d3f),
      tertiaryFixed: Color(0xffffdcc5),
      onTertiaryFixed: Color(0xff200c00),
      tertiaryFixedDim: Color(0xffffb783),
      onTertiaryFixedVariant: Color(0xff572a00),
      surfaceDim: Color(0xff0e1415),
      surfaceBright: Color(0xff3f4647),
      surfaceContainerLowest: Color(0xff040809),
      surfaceContainerLow: Color(0xff191f20),
      surfaceContainer: Color(0xff23292a),
      surfaceContainerHigh: Color(0xff2d3435),
      surfaceContainerHighest: Color(0xff393f40),
    );
  }

  ThemeData darkMediumContrast() {
    return theme(darkMediumContrastScheme());
  }

  static ColorScheme darkHighContrastScheme() {
    return const ColorScheme(
      brightness: Brightness.dark,
      primary: Color(0xffffeecf),
      surfaceTint: Color(0xffe7c26c),
      onPrimary: Color(0xff000000),
      primaryContainer: Color(0xffe2be69),
      onPrimaryContainer: Color(0xff110a00),
      secondary: Color(0xffb9fcff),
      onSecondary: Color(0xff000000),
      secondaryContainer: Color(0xff7cd0d4),
      onSecondaryContainer: Color(0xff000e0f),
      tertiary: Color(0xffffece2),
      onTertiary: Color(0xff000000),
      tertiaryContainer: Color(0xfffeb27a),
      onTertiaryContainer: Color(0xff170700),
      error: Color(0xffffece9),
      onError: Color(0xff000000),
      errorContainer: Color(0xffffaea4),
      onErrorContainer: Color(0xff220001),
      surface: Color(0xff0e1415),
      onSurface: Color(0xffffffff),
      onSurfaceVariant: Color(0xffffffff),
      outline: Color(0xfffaefdc),
      outlineVariant: Color(0xffccc1b0),
      shadow: Color(0xff000000),
      scrim: Color(0xff000000),
      inverseSurface: Color(0xffdee3e5),
      inversePrimary: Color(0xff5b4500),
      primaryFixed: Color(0xffffdf98),
      onPrimaryFixed: Color(0xff000000),
      primaryFixedDim: Color(0xffe7c26c),
      onPrimaryFixedVariant: Color(0xff181000),
      secondaryFixed: Color(0xff9cf1f5),
      onSecondaryFixed: Color(0xff000000),
      secondaryFixedDim: Color(0xff80d4d8),
      onSecondaryFixedVariant: Color(0xff001415),
      tertiaryFixed: Color(0xffffdcc5),
      onTertiaryFixed: Color(0xff000000),
      tertiaryFixedDim: Color(0xffffb783),
      onTertiaryFixedVariant: Color(0xff200c00),
      surfaceDim: Color(0xff0e1415),
      surfaceBright: Color(0xff4b5152),
      surfaceContainerLowest: Color(0xff000000),
      surfaceContainerLow: Color(0xff1b2122),
      surfaceContainer: Color(0xff2b3133),
      surfaceContainerHigh: Color(0xff363c3e),
      surfaceContainerHighest: Color(0xff424849),
    );
  }

  ThemeData darkHighContrast() {
    return theme(darkHighContrastScheme());
  }

  ThemeData theme(ColorScheme colorScheme) => ThemeData(
    useMaterial3: true,
    brightness: colorScheme.brightness,
    colorScheme: colorScheme,
    textTheme: textTheme.apply(
      bodyColor: colorScheme.onSurface,
      displayColor: colorScheme.onSurface,
    ),
    scaffoldBackgroundColor: colorScheme.background,
    canvasColor: colorScheme.surface,
  );

  List<ExtendedColor> get extendedColors => [];
}

class ExtendedColor {
  final Color seed, value;
  final ColorFamily light;
  final ColorFamily lightHighContrast;
  final ColorFamily lightMediumContrast;
  final ColorFamily dark;
  final ColorFamily darkHighContrast;
  final ColorFamily darkMediumContrast;

  const ExtendedColor({
    required this.seed,
    required this.value,
    required this.light,
    required this.lightHighContrast,
    required this.lightMediumContrast,
    required this.dark,
    required this.darkHighContrast,
    required this.darkMediumContrast,
  });
}

class ColorFamily {
  const ColorFamily({
    required this.color,
    required this.onColor,
    required this.colorContainer,
    required this.onColorContainer,
  });

  final Color color;
  final Color onColor;
  final Color colorContainer;
  final Color onColorContainer;
}
