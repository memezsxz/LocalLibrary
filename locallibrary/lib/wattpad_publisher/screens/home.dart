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
        final currentIndex = _screens
            .indexWhere((s) => s.runtimeType == navState.runtimeType)
            .clamp(0, _screens.length - 1);

        final hideNav =
            navState is NavigationStoryCubit || navState is NavigationPartCubit;
        final showScrape = navState is NavigationDashboardCubit;

        final body = hideNav
            ? navState.get()
            : SafeArea(
                child: Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: IndexedStack(
                    index: currentIndex,
                    children: [for (final screen in _screens) screen.get()],
                  ),
                ),
              );

        if (isDesktop) {
          return _desktopBody(currentIndex, body, showScrape, hideNav, onTab);
        }
        return _mobileBody(currentIndex, body, showScrape, hideNav, onTab);
      },
    );
  }

  Widget _desktopBody(
    int currentIndex,
    Widget body,
    bool showScrape,
    bool hideNav,
    ValueChanged<int> onTab,
  ) {
    final nav = [];
    return Scaffold(
      floatingActionButton: showScrape ? _scrape() : null,
      body: Row(
        children: [
          if (!hideNav)
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
          if (!hideNav) const VerticalDivider(thickness: 1, width: 1),
          Expanded(child: body),
        ],
      ),
    );
  }

  Widget _mobileBody(
    int currentIndex,
    Widget body,
    bool showScrape,
    bool hideNav,
    ValueChanged<int> onTab,
  ) {
    return Scaffold(
      floatingActionButton: showScrape ? _scrape() : null,
      bottomNavigationBar: hideNav
          ? null
          : NavigationBar(
              labelBehavior:
                  NavigationDestinationLabelBehavior.onlyShowSelected,
              destinations: _bottomNavigationBarDestinations(),
              selectedIndex: currentIndex,
              onDestinationSelected: onTab,
            ),
      body: body,
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
