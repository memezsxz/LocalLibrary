import 'dart:convert';

import 'package:desktop_multi_window/desktop_multi_window.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:locallibrary/core/route/route.dart';
import 'package:locallibrary/wattpad_publisher/bloc/story_bloc.dart';
import 'package:locallibrary/wattpad_publisher/cubit/navigation_cubit.dart';
import 'package:locallibrary/window_service.dart';

import 'core/theme/theme.dart';
import 'dependency_ingection.dart';

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
        (payload['initialRoute'] as String?) ?? AppRoute.scrapeInitLocation;

    // pick mode based on where you’re landing
    final mode = initialRoute.startsWith(AppRoute.scrapeInitLocation)
        ? AppRouterMode.subScrapeWindow
        : AppRouterMode.subStoryWindow;

    final router = AppRoute.buildRouter(
      initialLocation: initialRoute,
      mode: mode,
    );

    // Handle messages from other windows
    DesktopMultiWindow.setMethodHandler((call, fromWindowId) async {
      switch (call.method) {
        case 'scrape_closed':
          ScrapeStoryAppWindow.I.markClosed(fromWindowId);
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
        case 'focus':
          final ctrl = WindowController.fromWindowId(windowId);
          ctrl.show();
          // TODO: add window_manager and call focus here
          return true;
      }
      return null;
    });

    // WidgetsBinding.instance.addPostFrameCallback((_) {
    //   // attach to whatever close action you use:
    //   DesktopMultiWindow.invokeMethod(0, 'addStoryClosed', {'id': windowId});
    // });

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
        routerConfig:
            AppRoute.buildRouter(), // full router with home/library/etc.
      ),
    ),
  );
}
