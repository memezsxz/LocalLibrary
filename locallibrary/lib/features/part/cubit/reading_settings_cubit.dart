import 'package:bloc/bloc.dart';
import 'package:meta/meta.dart';

import '../models/enum/reading_enums.dart';

part 'reading_settings_state.dart';

class ReadingSettingsCubit extends Cubit<ReadingSettingsState> {
  ReadingSettingsCubit() : super(const ReadingSettingsState());

  void setBrightness(double v) => emit(state.copyWith(brightness: v));

  void setTheme(ReadingTheme v) => emit(state.copyWith(theme: v));

  void setOrientation(ReadingOrientation v) =>
      emit(state.copyWith(orientation: v));

  void setFont(String v) => emit(state.copyWith(font: v));

  void setSpacing(ReadingSpacing v) => emit(state.copyWith(spacing: v));

  void setIndent(ReadingIndent v) => emit(state.copyWith(indent: v));

  void setMode(ReadingMode v) => emit(state.copyWith(mode: v));

  void setInlineComments(bool v) => emit(state.copyWith(inlineComments: v));

  void setStatusBar(bool v) => emit(state.copyWith(statusBar: v));

  void setVolumeNav(bool v) => emit(state.copyWith(volumeNav: v));

  void setArrowNav(bool v) => emit(state.copyWith(arrowNav: v));
}
