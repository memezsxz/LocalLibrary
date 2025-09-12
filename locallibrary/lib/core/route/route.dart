import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart' show Text, Center, Scaffold;
import 'package:go_router/go_router.dart';
import 'package:locallibrary/core/route/story_route.dart';

import '../../wattpad_publisher/screens/home.dart';
import '../../wattpad_publisher/screens/library.dart';
import '../../wattpad_publisher/screens/notifications.dart';
import '../../wattpad_publisher/screens/story_screen.dart';

class AppRoute {
  static const String homeRoute = '/';
  static const String libraryRoute = 'library'; // relative (nested)
  static const String notificationsRoute = 'notifications';

  static final router = GoRouter(
    initialLocation: homeRoute,
    routes: [
      GoRoute(
        name: 'home',
        path: homeRoute,
        builder: (context, state) => const WDHome(),
        routes: [
          GoRoute(
            name: 'library',
            path: libraryRoute, // → /library
            builder: (context, state) => const Library(),
          ),
          GoRoute(
            name: 'notifications',
            path: notificationsRoute, // → /notifications
            builder: (context, state) => const Notifications(),
          ),

          // Optional story route (top-level under "/", using a path param)
        ],
      ),
      GoRoute(
        name: 'story',
        path: '/stories/:story_id', // must be absolute at top-level
        pageBuilder: (context, state) {
          final idStr = state.pathParameters['story_id'] ?? '';
          final storyId = int.tryParse(idStr);

          if (storyId == null) {
            return const NoTransitionPage(
              child: Scaffold(body: Center(child: Text('Invalid story id'))),
            );
          }

          if (shouldOpenInWindow(state)) {
            return NoTransitionPage(child: StoryWindowLauncherPage(storyId: storyId));
          }

          // Fallback: inline (mobile/web, or when not explicitly requested)
          return NoTransitionPage(child: StoryScreen(storyId: storyId));
        },
      ),
    ],
  );
}


/// Returns true if we should open a separate desktop window for this route.
bool shouldOpenInWindow(GoRouterState state) {
  // Strategy A: always on desktop
  if (!kIsWeb && (Platform.isMacOS || Platform.isWindows || Platform.isLinux)) {
    return true;
  }

  // Strategy B (optional): only when requested via query or extra
  // final inQuery = state.uri.queryParameters['open'] == 'window';
  // final inExtra = state.extra == 'window';
  // return (!kIsWeb && (Platform.isMacOS || Platform.isWindows || Platform.isLinux)) && (inQuery || inExtra);

  return false;
}
