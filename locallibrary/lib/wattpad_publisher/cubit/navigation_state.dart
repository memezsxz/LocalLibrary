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

final class NavigationSettingsCubit extends NavigationScreenCubit {
  @override
  Widget get() {
    return Settings();
  }
}

final class NavigationScrapeCubit extends NavigationScreenCubit {
  @override
  Widget get() {
    return Scrape();
  }
}

final class NavigationStoryCubit extends NavigationScreenCubit {
  final int storyId;

  NavigationStoryCubit({required this.storyId});

  @override
  Widget get() {
    return StoryScreen(storyId: storyId);
  }
}
