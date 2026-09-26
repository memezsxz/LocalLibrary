import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../core/theme/app_theme.dart';
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

  static final _tabStates = [
    NavigationDashboardState(),
    NavigationNotificationsState(),
    NavigationLibraryState(),
    NavigationSettingsState(),
  ];

  // Built once — stable references keep IndexedStack element tree alive.
  static final _tabWidgets = [
    for (final s in _tabStates) s.build(),
  ];

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<NavigationCubit, NavigationState>(
      builder: (context, navState) {
        void onTab(int i) =>
            context.read<NavigationCubit>().changeContent(_tabStates[i]);

        final currentIndex = _tabStates
            .indexWhere((s) => s.runtimeType == navState.runtimeType)
            .clamp(0, navItems.length - 1);

        final isDetail =
            navState is NavigationStoryState ||
            navState is NavigationScrapeStoryState ||
            navState is NavigationPartState;

        final showScrape = navState is NavigationDashboardState;

        final fab = showScrape
            ? FloatingActionButton(
                tooltip: 'Scrape',
                onPressed: () => showScrapeSheet(context),
          backgroundColor: context.colors.primary,
          foregroundColor: context.colors.textOnLight,
          elevation: 2,
          highlightElevation: 4,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          child: const Icon(Icons.add_rounded),
              )
            : null;

        // IndexedStack is always in the tree (preserves scroll & state).
        // Detail screens overlay on top via Stack.
        final body = Stack(
          children: [
            SafeArea(
              child: Padding(
                padding: const EdgeInsets.all(8.0),
                child: Offstage(
                  offstage: isDetail,
                  child: IndexedStack(
                    index: currentIndex,
                    children: _tabWidgets,
                  ),
                ),
              ),
            ),
            if (isDetail) navState.build(),
          ],
        );

        return isDesktop
            ? DesktopScaffold(
                selectedIndex: currentIndex,
                body: body,
                floatingActionButton: fab,
          hideNav: isDetail,
                onDestinationSelected: onTab,
              )
            : MobileScaffold(
                selectedIndex: currentIndex,
                body: body,
                floatingActionButton: fab,
          hideNav: isDetail,
                onDestinationSelected: onTab,
              );
      },
    );
  }
}
