import 'package:flutter_bloc/flutter_bloc.dart';

import 'navigation_state.dart';

class NavigationCubit extends Cubit<NavigationState> {
  NavigationCubit() : super(NavigationDashboardState());

  final List<NavigationState> _stack = [];

  void changeContent(NavigationState state) {
    _stack.add(state);
    emit(state);
  }

  void push(NavigationState screen) {
    _stack.add(state);
    emit(screen);
  }

  void pop() {
    if (_stack.isEmpty) return;
    emit(_stack.removeLast());
  }
}