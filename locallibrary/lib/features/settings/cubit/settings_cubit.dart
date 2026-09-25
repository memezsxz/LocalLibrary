import 'package:bloc/bloc.dart';
import 'package:flutter/material.dart';

import '../../story/models/enum/book_size.dart';

part 'settings_state.dart';

class SettingsCubit extends Cubit<SettingsState> {
  SettingsCubit() : super(SettingsState());

  void setBookSize(BookSize size) => emit(state.copyWith(bookSize: size));

  void setFontSize(double size) => emit(state.copyWith(fontSize: size));

  void setFontFamily(AppFontFamily family) =>
      emit(state.copyWith(fontFamily: family));

  void setThemeMode(ThemeMode mode) => emit(state.copyWith(themeMode: mode));
}
