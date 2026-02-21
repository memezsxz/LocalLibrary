import 'dart:convert';

import 'package:desktop_multi_window/desktop_multi_window.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:locallibrary/core/route/route.dart';
import 'package:locallibrary/wattpad_publisher/bloc/story_bloc.dart';
import 'package:locallibrary/wattpad_publisher/bloc/windows_bloc.dart';
import 'package:locallibrary/wattpad_publisher/cubit/navigation_cubit.dart';

import 'core/theme/theme.dart';
import 'dependency_ingection.dart';

class WindowCloseNotifier extends StatefulWidget {
  final int parentId;
  final Widget child;

  const WindowCloseNotifier({
    super.key,
    required this.parentId,
    required this.child,
  });

  @override
  State<WindowCloseNotifier> createState() => _WindowCloseNotifierState();
}

class _WindowCloseNotifierState extends State<WindowCloseNotifier> {
  @override
  void dispose() {
    try {
      DesktopMultiWindow.invokeMethod(widget.parentId, 'window_closed', {});
    } catch (_) {}
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => widget.child;
}

Future<void> main(List<String> args) async {
  WidgetsFlutterBinding.ensureInitialized();
  await dotenv.load(fileName: '.env');
  initDI();

  // close all windows after hot restart
  // try {
  //   final ids = await DesktopMultiWindow.getAllSubWindowIds();
  //   for (final id in ids) {
  //     try { await WindowController.fromWindowId(id).close(); } catch (_) {}
  //   }
  // } catch (_) {}

  if (args.isNotEmpty && args.first == 'multi_window') {
    // Read JSON payload passed from createWindow(...)
    // (This works even if process args aren’t populated on your platform)
    final Map<String, dynamic> payload =
        (args.length >= 3 && args[2].isNotEmpty)
        ? jsonDecode(args[2]) as Map<String, dynamic>
        : <String, dynamic>{};

    final String name = (payload['name'] as String?) ?? 'unnamed';
    final int parentId = (payload['parent_id'] as int?) ?? 0;

    // Tell the parent “this window id is called <name>”
    try {
      await DesktopMultiWindow.invokeMethod(parentId, 'register_window', {
        'name': name,
      });
    } catch (_) {}

    final String initialRoute =
        (payload['initialRoute'] as String?) ?? AppRoute.scrapeInitLocation;

    final AppRouterMode mode = switch (payload['router_mode']) {
      final String s when s == AppRouterMode.subScrapeWindow.name =>
        AppRouterMode.subScrapeWindow,
      final String s when s == AppRouterMode.subStoryWindow.name =>
        AppRouterMode.subStoryWindow,
      _ =>
        initialRoute.startsWith(AppRoute.scrapeInitLocation)
            ? AppRouterMode.subScrapeWindow
            : AppRouterMode.subStoryWindow,
    };

    final router = AppRoute.buildRouter(
      initialLocation: initialRoute, // <-- use the passed route
      mode: mode,
    );

    runApp(
      MultiBlocProvider(
        providers: [BlocProvider<StoryBloc>(create: (_) => sl<StoryBloc>())],
        child: WindowCloseNotifier(
          parentId: parentId,
          child: MaterialApp.router(
            debugShowCheckedModeBanner: false,
            title: payload["name"],
            theme: AppTheme.lightMode,
            routerConfig: router, // <-- use the sub-window router
          ),
        ),
      ),
    );

    return;
  }
  sl.get<WindowsBloc>();

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
