import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart'
    show Text, Center, Scaffold, BuildContext, Widget, TextAlign;
import 'package:go_router/go_router.dart';

import '../../wattpad_publisher/screens/home.dart';
import '../../wattpad_publisher/screens/library.dart';
import '../../wattpad_publisher/screens/notifications.dart';
import '../../wattpad_publisher/screens/part_screen.dart';
import '../../wattpad_publisher/screens/scrape_story_screen.dart';
import '../../wattpad_publisher/screens/story_screen.dart';


enum AppRouterMode { main, subStoryWindow, subScrapeWindow }



class AppRoute {
  static const String homeRoute = '/';
  static const String libraryRoute = 'library'; // relative (nested)
  static const String notificationsRoute = 'notifications';

  static const String storyInitLocation = "/stories/:story_id";
  static const String scrapeInitLocation = "/scrape_story";


  static GoRouter buildRouter({
    String initialLocation = homeRoute,
    AppRouterMode mode = AppRouterMode.main,
  }) {
    return GoRouter(
      initialLocation: initialLocation,
      routes: _routes(mode),
      errorBuilder: (context, state) =>
      const Scaffold(body: Center(child: Text('Route not found'))),
    );
  }

  static List<RouteBase> _routes(AppRouterMode mode) =>
      [
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
          path: '/stories/:story_id',
          builder: (context, state) {
            final id = int.tryParse(state.pathParameters['story_id'] ?? '');
            if (id == null) {
              return _missing('Invalid story id');
            }
            return StoryScreen(storyId: id);
          },

          routes: [
            GoRoute(
              name: 'part',
              path: 'parts/:part_id',
              builder: (context, state) {
                final storyId = int.tryParse(
                  state.pathParameters['story_id'] ?? '',
                );
                final partId = int.tryParse(
                  state.pathParameters['part_id'] ?? '',
                );
                if (storyId == null || partId == null) {
                  return _missing('Invalid story/part id');
                }

                return PartScreen(storyId: storyId, partId: partId);
              },
            ),
          ],
        ),
        GoRoute(
          name: 'scrape_story',
          path: scrapeInitLocation,
          builder: (context, state) {
            return ScrapeStoryScreen();
          },
        ),
      ];


// static final router = GoRouter(
//   initialLocation: homeRoute,
//   routes: [
//     GoRoute(
//       name: 'home',
//       path: homeRoute,
//       builder: (context, state) => const WDHome(),
//       routes: [
//         GoRoute(
//           name: 'library',
//           path: libraryRoute, // → /library
//           builder: (context, state) => const Library(),
//         ),
//         GoRoute(
//           name: 'notifications',
//           path: notificationsRoute, // → /notifications
//           builder: (context, state) => const Notifications(),
//         ),
//
//         // Optional story route (top-level under "/", using a path param)
//       ],
//     ),
//     GoRoute(
//       name: 'story',
//       path: '/stories/:story_id',
//       builder: (context, state) {
//         final id = int.tryParse(state.pathParameters['story_id'] ?? '');
//         if (id == null) {
//           return _missing('Invalid story id');
//         }
//         return StoryScreen(storyId: id);
//       },
//
//       routes: [
//         GoRoute(
//           name: 'part',
//           path: '/parts/:part_id',
//           builder: (context, state) {
//             final storyId = int.tryParse(
//               state.pathParameters['story_id'] ?? '',
//             );
//             final partId = int.tryParse(
//               state.pathParameters['part_id'] ?? '',
//             );
//             if (storyId == null || partId == null) {
//               return _missing('Invalid story/part id');
//             }
//
//             return PartScreen(storyId: storyId, partId: partId);
//           },
//         ),
//       ],
//     ),
//     GoRoute(
//       name: 'scrape_story',
//       path: '/scrape_story',
//       builder: (context, state) {
//         return ScrapeStoryScreen();
//       },
//     ),
//   ],
// );



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

Widget _missing(String text) =>
    Scaffold(
      body: Center(child: Text(text, textAlign: TextAlign.center)),
    );

void goToPart(BuildContext context, int storyId, int partId) {
  context.goNamed(
    "part",
    pathParameters: {"story_id": "$storyId", "part_id": "$partId"},
  );
}

void goToStory(BuildContext context, int storyId) {
  context.goNamed("story", pathParameters: {"story_id": "$storyId"});
}
