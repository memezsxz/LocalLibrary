import 'package:flutter/cupertino.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../part/screens/part_screen.dart';
import '../../settings/screens/settings.dart';
import '../../story/models/story_dto.dart';
import '../../story/screens/scrape_story_view_screen.dart';
import '../../story/screens/story_screen.dart';
import '../screens/dashboard.dart';
import '../screens/library.dart';
import '../screens/notifications.dart';

part 'navigation_state.dart';

class NavigationCubit extends Cubit<NavigationScreenCubit> {
  NavigationCubit() : super(NavigationDashboardCubit());
  final List<NavigationScreenCubit> _stack = [];

  void changeContent(NavigationScreenCubit state) {
    _stack.add(state);
    emit(state);
  }

  void push(NavigationScreenCubit screen) {
    _stack.add(state);
    emit(screen);
  }

  void pop() {
    if (_stack.isEmpty) return;
    emit(_stack.removeLast());
  }
}

