part of 'navigation_cubit.dart';
@immutable
sealed class NavigationScreenCubit {
  Widget get();
}

final class NavigationDashboardCubit extends NavigationScreenCubit {
  @override
  Widget get() {
    return Dashboard();
  }
}

final class NavigationLibraryCubit extends NavigationScreenCubit {
  @override
  Widget get() {
    return Library();
  }
}

final class NavigationNotificationsCubit extends NavigationScreenCubit {
  @override
  Widget get() {
    return Notifications();
  }
}
