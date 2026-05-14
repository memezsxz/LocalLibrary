import 'package:bloc/bloc.dart';
import 'package:meta/meta.dart';

import '../models/book_size.dart';

part 'settings_state.dart';

class SettingsCubit extends Cubit<SettingsState> {
  SettingsCubit() : super(SettingsState());

  void setBookSize(BookSize size) => emit(state.copyWith(bookSize: size));
}
