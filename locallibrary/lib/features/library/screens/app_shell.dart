import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../story/screens/scrape_story_screen.dart';
import '../cubit/navigation_cubit.dart';
import '../cubit/navigation_state.dart';
import '../widgets/desktop_scaffold.dart';
import '../widgets/mobile_scaffold.dart';
import '../widgets/nav_items.dart';

class AppShell extends StatelessWidget {
  const AppShell({super.key});

  static final isDesktop =
      defaultTargetPlatform == TargetPlatform.macOS ||
      defaultTargetPlatform == TargetPlatform.windows ||
      defaultTargetPlatform == TargetPlatform.linux;

  static final _screens = [
    NavigationDashboardState(),
    NavigationLibraryState(),
    NavigationNotificationsState(),
    NavigationSettingsState(),
  ];

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<NavigationCubit, NavigationState>(
      builder: (context, navState) {
        void onTab(int i) =>
            context.read<NavigationCubit>().changeContent(_screens[i]);

        final currentIndex = _screens
            .indexWhere((s) => s.runtimeType == navState.runtimeType)
            .clamp(0, navItems.length - 1);

        final hideNav =
            navState is NavigationStoryState ||
            navState is NavigationScrapeStoryState ||
            navState is NavigationPartState;

        final showScrape = navState is NavigationDashboardState;

        final fab = showScrape
            ? FloatingActionButton.small(
                tooltip: 'Scrape',
                onPressed: () => showScrapeSheet(context),
                child: const Icon(Icons.add_box_sharp),
              )
            : null;

        final body = hideNav
            ? navState.build()
            : SafeArea(
                child: Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: IndexedStack(
                    index: currentIndex,
                    children: [for (final s in _screens) s.build()],
                  ),
                ),
              );

        return isDesktop
            ? DesktopScaffold(
                selectedIndex: currentIndex,
                body: body,
                floatingActionButton: fab,
                hideNav: hideNav,
                onDestinationSelected: onTab,
              )
            : MobileScaffold(
                selectedIndex: currentIndex,
                body: body,
                floatingActionButton: fab,
                hideNav: hideNav,
                onDestinationSelected: onTab,
              );
      },
    );
  }
}
