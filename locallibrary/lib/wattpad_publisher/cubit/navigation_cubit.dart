import 'package:flutter/cupertino.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:locallibrary/wattpad_publisher/screens/dashboard.dart';
import 'package:locallibrary/wattpad_publisher/screens/library.dart';
import 'package:locallibrary/wattpad_publisher/screens/notifications.dart';
import 'package:locallibrary/wattpad_publisher/screens/settings.dart';
import 'package:locallibrary/wattpad_publisher/screens/story_screen.dart';

import '../screens/scrape.dart';

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

