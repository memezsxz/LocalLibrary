part of 'reading_settings_cubit.dart';

@immutable
class ReadingSettingsState {
  final double brightness;
  final ReadingTheme theme;
  final ReadingOrientation orientation;
  final String font;
  final ReadingSpacing spacing;
  final ReadingIndent indent;
  final ReadingMode mode;
  final bool inlineComments;
  final bool statusBar;
  final bool volumeNav;
  final bool arrowNav;

  const ReadingSettingsState({
    this.brightness = 0.8,
    this.theme = ReadingTheme.light,
    this.orientation = ReadingOrientation.auto,
    this.font = 'Default',
    this.spacing = ReadingSpacing.normal,
    this.indent = ReadingIndent.none,
    this.mode = ReadingMode.scrolling,
    this.inlineComments = true,
    this.statusBar = false,
    this.volumeNav = true,
    this.arrowNav = true,
  });

  ReadingSettingsState copyWith({
    double? brightness,
    ReadingTheme? theme,
    ReadingOrientation? orientation,
    String? font,
    ReadingSpacing? spacing,
    ReadingIndent? indent,
    ReadingMode? mode,
    bool? inlineComments,
    bool? statusBar,
    bool? volumeNav,
    bool? arrowNav,
  }) => ReadingSettingsState(
    brightness: brightness ?? this.brightness,
    theme: theme ?? this.theme,
    orientation: orientation ?? this.orientation,
    font: font ?? this.font,
    spacing: spacing ?? this.spacing,
    indent: indent ?? this.indent,
    mode: mode ?? this.mode,
    inlineComments: inlineComments ?? this.inlineComments,
    statusBar: statusBar ?? this.statusBar,
    volumeNav: volumeNav ?? this.volumeNav,
    arrowNav: arrowNav ?? this.arrowNav,
  );
}
