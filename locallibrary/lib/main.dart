import 'dart:convert';

import 'package:desktop_multi_window/desktop_multi_window.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:locallibrary/wattpad_publisher/bloc/story_bloc.dart';

import 'core/route/story_route.dart';
import 'core/theme/theme.dart';
import 'dependency_ingection.dart';

import 'package:locallibrary/core/route/route.dart';

import 'package:locallibrary/wattpad_publisher/cubit/navigation_cubit.dart';

Future<void> main(List<String> args) async {
  WidgetsFlutterBinding.ensureInitialized();
  await dotenv.load(fileName: '.env');
  initDI();

  // ----- Sub-window process -----
  if (args.isNotEmpty && args.first == 'multi_window') {
    final windowId = int.parse(args[1]);
    final Map<String, dynamic> payload =
        (args.length >= 3 && args[2].isNotEmpty)
        ? (jsonDecode(args[2]) as Map<String, dynamic>)
        : <String, dynamic>{};

    // Build the sub-window router with its initial route
    final String initialRoute =
        (payload['initialRoute'] as String?) ??
        (payload['storyId'] != null
            ? '/stories/${payload['storyId']}'
            : '/stories/1');

    final router = buildSubWindowRouter(initialLocation: initialRoute);

    // Handle messages from other windows
    DesktopMultiWindow.setMethodHandler((call, fromWindowId) async {
      switch (call.method) {
        case 'navigate':
          final map = (call.arguments as Map?)?.cast<String, dynamic>();
          final path = map?['path'] as String?;
          if (path != null && path.isNotEmpty) {
            router.go(path); // <-- path-based navigation
          }
          return true;
        case 'close':
          WindowController.fromWindowId(windowId).close();
          return true;
      }
      return null;
    });

    // Run a **locked** sub-window: no back navigation to “home”
    runApp(
      MultiBlocProvider(
        providers: [
          BlocProvider(create: (_) => NavigationCubit()),
          BlocProvider<StoryBloc>(create: (_) => sl<StoryBloc>()),
        ],
        child: PopScope(
          canPop: false, // disable back pops in this window
          child: MaterialApp.router(
            debugShowCheckedModeBanner: false,
            title: 'Local Library — Story',
            theme: AppTheme.lightMode,
            routerConfig: router, // <-- use the sub-window router
          ),
        ),
      ),
    );
    return;
  }

  // ----- Main window process -----
  runApp(
    MultiBlocProvider(
      providers: [BlocProvider(create: (_) => NavigationCubit())],
      child: MaterialApp.router(
        debugShowCheckedModeBanner: false,
        title: 'Local Library',
        theme: AppTheme.lightMode,
        routerConfig: AppRoute.router, // full router with home/library/etc.
      ),
    ),
  );
}
