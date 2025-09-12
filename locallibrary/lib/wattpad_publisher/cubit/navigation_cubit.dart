import 'package:flutter/cupertino.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:locallibrary/wattpad_publisher/screens/dashboard.dart';
import 'package:locallibrary/wattpad_publisher/screens/home.dart';
import 'package:locallibrary/wattpad_publisher/screens/library.dart';
import 'package:locallibrary/wattpad_publisher/screens/notifications.dart';

part 'navigation_state.dart';

class NavigationCubit extends Cubit<NavigationScreenCubit> {
  NavigationCubit() : super(NavigationDashboardCubit());

  void changeContent(NavigationScreenCubit state) {
    print(state.toString());
    emit(state);
  }
}

