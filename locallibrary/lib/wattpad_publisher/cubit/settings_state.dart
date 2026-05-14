part of 'settings_cubit.dart';

@immutable
class SettingsState {
  final BookSize bookSize;

  const SettingsState({this.bookSize = BookSize.m});

  SettingsState copyWith({BookSize? bookSize}) =>
      SettingsState(bookSize: bookSize ?? this.bookSize);
}
