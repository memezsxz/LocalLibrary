import 'package:desktop_multi_window/desktop_multi_window.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:locallibrary/core/route/route.dart';
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

  sl.get<WindowsBloc>();

  runApp(
    MultiBlocProvider(
      providers: [BlocProvider(create: (_) => NavigationCubit())],
      child: MaterialApp.router(
        debugShowCheckedModeBanner: false,
        title: 'Local Library',
        theme: AppTheme.lightMode,
        routerConfig: AppRoute.buildRouter(),
      ),
    ),
  );
}
