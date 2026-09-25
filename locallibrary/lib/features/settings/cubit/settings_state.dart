part of 'settings_cubit.dart';

enum AppFontFamily { defaultFont, serif, mono }

@immutable
class SettingsState {
  final BookSize bookSize;
  final double fontSize;
  final AppFontFamily fontFamily;
  final ThemeMode themeMode;

  const SettingsState({
    this.bookSize = BookSize.m,
    this.fontSize = 16,
    this.fontFamily = AppFontFamily.defaultFont,
    this.themeMode = ThemeMode.system,
  });

  SettingsState copyWith({
    BookSize? bookSize,
    double? fontSize,
    AppFontFamily? fontFamily,
    ThemeMode? themeMode,
  }) =>
      SettingsState(
        bookSize: bookSize ?? this.bookSize,
        fontSize: fontSize ?? this.fontSize,
        fontFamily: fontFamily ?? this.fontFamily,
        themeMode: themeMode ?? this.themeMode,
      );
}
