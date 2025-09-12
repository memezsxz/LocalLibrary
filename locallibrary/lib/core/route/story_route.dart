import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:locallibrary/wattpad_publisher/bloc/comments_bloc.dart';
import 'package:locallibrary/wattpad_publisher/cubit/part_side_panel_cubit.dart';
import 'package:locallibrary/wattpad_publisher/datasource.dart';
import 'package:locallibrary/wattpad_publisher/screens/part_screen.dart';

import '../../dependency_ingection.dart';
import '../../wattpad_publisher/screens/story_screen.dart';

Widget _missing(String text) => Scaffold(
  body: Center(child: Text(text, textAlign: TextAlign.center)),
);

GoRouter buildSubWindowRouter({required String initialLocation}) {
  return GoRouter(
    initialLocation: initialLocation,
    routes: [
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
            path: '/parts/:part_id',
            builder: (context, state) {
              final storyId = int.tryParse(state.pathParameters['story_id'] ?? '');
              final partId = int.tryParse(state.pathParameters['part_id'] ?? '');
              if (storyId == null || partId == null) {
                return _missing('Invalid story/part id');
              }

              return PartScreen(storyId: storyId, partId: partId);
            },
          ),

        ]
      ),
    ],
  );
}

void goToPart(BuildContext context, int storyId, int partId) {
  context.goNamed(
    "part",
    pathParameters: {"story_id": "$storyId", "part_id": "$partId"},
  );
}

void goToStory(BuildContext context, int storyId) {
  context.goNamed(
    "story",
    pathParameters: {"story_id": "$storyId"},
  );
}
