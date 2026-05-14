import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../cubit/navigation_cubit.dart';

const _navItems = [
  (label: 'Home', icon: Icons.home_outlined, selected: Icons.home),
  (label: 'Library', icon: Icons.book_outlined, selected: Icons.book),
  (
    label: 'Notifications',
    icon: Icons.notifications_outlined,
    selected: Icons.notifications,
  ),
  (label: 'Settings', icon: Icons.settings_outlined, selected: Icons.settings),
];

class WDHome extends StatelessWidget {
  const WDHome({super.key});

  static final isDesktop =
      defaultTargetPlatform == TargetPlatform.macOS ||
      defaultTargetPlatform == TargetPlatform.windows ||
      defaultTargetPlatform == TargetPlatform.linux;

  static final _screens = [
    NavigationDashboardCubit(),
    NavigationLibraryCubit(),
    NavigationNotificationsCubit(),
    NavigationSettingsCubit(),
    NavigationScrapeCubit(),
  ];

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<NavigationCubit, NavigationScreenCubit>(
      builder: (context, navState) {
        void onTab(int i) =>
            context.read<NavigationCubit>().changeContent(_screens[i]);
        final currentIndex = _screens.indexWhere(
          (s) => s.runtimeType == navState.runtimeType,
        );

        final body = SafeArea(
          child: Padding(
            padding: const EdgeInsets.all(8.0),
            child: IndexedStack(
              index: currentIndex,
              children: [for (final screen in _screens) screen.get()],
            ),
          ),
        );

        if (isDesktop) {
          return Scaffold(
            floatingActionButton: navState is NavigationDashboardCubit
                ? _scrape()
                : null,
            body: Row(
              children: [
                NavigationRail(
                  destinations: _navigationRailDestinations(),
                  selectedIndex: currentIndex,
                  onDestinationSelected: onTab,
                  trailing: Expanded(
                    child: Align(
                      alignment: Alignment.bottomCenter,
                      child: Padding(
                        padding: const EdgeInsets.only(bottom: 16),
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          // children: [_scrape(), _settings()],
                        ),
                      ),
                    ),
                  ),
                ),
                const VerticalDivider(thickness: 1, width: 1),
                Expanded(child: body),
              ],
            ),
          );
        }

        return Scaffold(
          floatingActionButton: navState is NavigationDashboardCubit
              ? _scrape()
              : null,
          bottomNavigationBar: NavigationBar(
            labelBehavior: NavigationDestinationLabelBehavior.onlyShowSelected,
            destinations: _bottomNavigationBarDestinations(),
            selectedIndex: currentIndex,
            onDestinationSelected: onTab,
          ),
          body: body,
        );
      },
    );
  }

  List<NavigationRailDestination> _navigationRailDestinations() {
    return _navItems
        .map(
          (i) => NavigationRailDestination(
            icon: Icon(i.icon),
            selectedIcon: Icon(i.selected),
            label: Text(i.label),
          ),
        )
        .toList();
  }

  List<NavigationDestination> _bottomNavigationBarDestinations() {
    return _navItems
        .map(
          (i) => NavigationDestination(
            icon: Icon(i.icon),
            selectedIcon: Icon(i.selected),
            label: i.label,
          ),
        )
        .toList();
  }

  // IconButton _settings() {
  //   return    IconButton(
  //     icon: const Icon(Icons.settings),
  //     tooltip: 'Settings',
  //     onPressed: () => {},
  //   );
  // }

  FloatingActionButton _scrape() {
    return FloatingActionButton.small(
      tooltip: 'Scrape',
      onPressed: () => {},
      child: const Icon(Icons.add_box_sharp),
    );
  }

  // Widget _buildTab(AppTab tab) => switch (tab) {
  //   HomeTab() => const HomeScreen(),
  //   StoryTab(:final storyId) => StoryScreen(storyId: storyId),
  //   ScrapeTab() => const ScrapeStoryScreen(),
  //   NotificationsTab() => const NotificationsScreen(),
  //   SettingsTab() => const SettingsScreen(),
  // };
}
