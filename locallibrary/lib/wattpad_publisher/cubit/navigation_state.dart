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

final class NavigationStoryCubit extends NavigationScreenCubit {
  final int storyId;

  NavigationStoryCubit({required this.storyId});

  @override
  Widget get() {
    return StoryScreen(storyId: storyId);
  }
}

final class NavigationScrapeStoryCubit extends NavigationScreenCubit {
  final int storyId;
  final ScrapeStoryRes scrapeRes;

  NavigationScrapeStoryCubit({required this.storyId, required this.scrapeRes});

  @override
  Widget get() {
    return ScrapeStoryViewScreen(storyId: storyId, scrapeRes: scrapeRes);
  }
}

ffinal class NavigationPartCubit extends NavigationScreenCubit {
  final int storyId;
  final int partId;

  NavigationPartCubit({required this.storyId, required this.partId});

  @override
  Widget get() {
    return PartScreen(key: ValueKey('part_${storyId}_$partId'),
        storyId: storyId,
        partId: partId);
  }
}
