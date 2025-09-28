import 'dart:convert';
import 'dart:math' as math;

import 'package:bloc/bloc.dart';
import 'package:desktop_multi_window/desktop_multi_window.dart';
import 'package:equatable/equatable.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:locallibrary/core/exstentions/window_controller.dart';
import 'package:screen_retriever/screen_retriever.dart';

import '../../core/commen/display_provider.dart';
import '../../core/route/route.dart';

part 'windows_event.dart';
part 'windows_state.dart';

class WindowInfo {
  final int id;
  final String name;
  final WindowController controller;

  WindowInfo({required this.id, required this.name, required this.controller});
}

sealed class WindowsEvent extends Equatable {
  const WindowsEvent();

  @override
  List<Object?> get props => [];
}

/// Open a window identified by a unique `name` (singleton per name).
class OpenWindowRequested extends WindowsEvent {
  final String name; // 'library', 'scrape', 'story:123'
  final Map<String, dynamic>? args; // passed to child
  final bool focusIfOpen;
  final String? title;
  final AppRouterMode routerMode;
  final String initialRoute;

  const OpenWindowRequested({
    required this.name,
    this.routerMode = AppRouterMode.main,
    this.args,
    this.focusIfOpen = true,
    this.title,
    this.initialRoute = "",
  });

  factory OpenWindowRequested.story(int storyId, {String? title}) {
    return OpenWindowRequested(
      name: 'story:$storyId',
      routerMode: AppRouterMode.subStoryWindow,
      initialRoute: '/stories/$storyId',
      title: title ?? 'Story #$storyId',
      focusIfOpen: false,
      args: <String, dynamic>{'story_id': storyId, 'name': 'story:$storyId'},
    );
  }

  factory OpenWindowRequested.scrape() {
    const scrapeInit = AppRoute.scrapeInitLocation;
    return OpenWindowRequested(
      name: 'scrape',
      routerMode: AppRouterMode.subScrapeWindow,
      initialRoute: scrapeInit,
      title: 'Add Story',
      focusIfOpen: true,
      args: <String, dynamic>{'route': scrapeInit, 'name': 'scrape'},
    );
  }

  @override
  List<Object?> get props => [
    name,
    args,
    focusIfOpen,
    title,
    routerMode,
    initialRoute,
  ];
}

class FocusWindowRequested extends WindowsEvent {
  final String name;

  const FocusWindowRequested(this.name);

  @override
  List<Object?> get props => [name];
}

class CloseWindowByIdRequested extends WindowsEvent {
  final int id;

  const CloseWindowByIdRequested(this.id);

  @override
  List<Object?> get props => [id];
}

class CloseWindowByNameRequested extends WindowsEvent {
  final String name;

  const CloseWindowByNameRequested(this.name);

  @override
  List<Object?> get props => [name];
}

/// Parent receives a method call from a child window.
class HandleMethodCall extends WindowsEvent {
  final MethodCall call;
  final int fromWindowId;

  const HandleMethodCall(this.call, this.fromWindowId);

  @override
  List<Object?> get props => [call.method, fromWindowId, call.arguments];
}

// app_windows_bloc.dart
class WindowsBloc extends Bloc<WindowsEvent, WindowsState> {
  WindowsBloc() : super(const WindowsState()) {
    on<OpenWindowRequested>(_onOpen);
    on<FocusWindowRequested>(_onFocus);
    on<CloseWindowByIdRequested>(_onCloseById);
    on<CloseWindowByNameRequested>(_onCloseByName);
    on<HandleMethodCall>(_onHandle);

    // Route child -> parent messages here
    DesktopMultiWindow.setMethodHandler((MethodCall call, int fromId) async {
      add(HandleMethodCall(call, fromId));
      return null;
    });
  }

  // Build the JSON that the child reads on startup
  String _launchArgs(OpenWindowRequested e, {required int parentId}) {
    final payload = <String, dynamic>{
      'name': e.name,
      'initialRoute': e.initialRoute,
      // <- used by sub-window main() to pick router + start location
      'router_mode': e.routerMode.name,
      // <- optional (also inferable from initialRoute)
      'parent_id': parentId,
      // <- so child can talk back to the parent
      if (e.args != null) ...e.args!,
    };
    return jsonEncode(payload);
  }

  // If you track the real parent id somewhere, return it here.
  // Otherwise, 0 usually refers to the primary window (works with your main()).
  int get _parentId => 0;

  Future<void> _onOpen(
    OpenWindowRequested e,
    Emitter<WindowsState> emit,
  ) async {
    print("opening");
    // If already open → focus & return
    final existingId = state.idByName[e.name];
    print("opening : ${state.idByName[e.name]}");

    if (existingId != null && e.focusIfOpen) {
      final c =
          state.windowsById[existingId]?.controller ??
          WindowController.fromWindowId(existingId);
      c
        ..show()
        ..focus();
      emit(state.copyWith(lastActiveId: existingId));
      return;
    }

    // Create a new subwindow with routing-aware payload
    final controller = await DesktopMultiWindow.createWindow(
      _launchArgs(e, parentId: _parentId),
    );

    if ((e.title ?? '').isNotEmpty) {
      try {
        await controller.setTitle(e.title!);
      } catch (_) {}
    }

    // 1) make a provider using screen_retriever once (e.g., in DI)
    final dp =
        ScreenRetrieverDisplayProvider(); // implement DisplayProvider using screen_retriever

    // 2) use the extension anywhere you have a WindowController
    // if (e.name == 'scrape') {
    //   await controller.setFixedCenteredOnCursor(
    //     displays: dp,
    //     // width: 520,
    //     // height: 420,
    //   );
    // } else {
    await controller.setRelativeCentered(
      displays: dp,
      widthPercent: 0.8,
      heightPercent: 0.8,
    );
    // }

    controller
      // ..setTitle('Story $storyId • Part $partId')
      ..center()
      // ..setFrame(const Offset(0, 0) & const Size(1100, 720))
      ..show();

    // await controller.show();
    // await controller.focus();

    final id = controller.windowId;
    final info = WindowInfo(id: id, name: e.name, controller: controller);

    final windowsById = Map<int, WindowInfo>.from(state.windowsById)
      ..[id] = info;
    final idByName = Map<String, int>.from(state.idByName)..[e.name] = id;

    emit(
      state.copyWith(
        windowsById: windowsById,
        idByName: idByName,
        lastActiveId: id,
      ),
    );
  }

  Future<Display> _pickDisplayUnderCursor() async {
    final point = await ScreenRetriever.instance.getCursorScreenPoint();
    final displays = await ScreenRetriever.instance.getAllDisplays();
    if (displays.isEmpty) {
      return await ScreenRetriever.instance.getPrimaryDisplay();
    }

    Rect boundsOf(Display d) {
      // Older versions expose position/size; some expose visiblePosition/visibleSize.
      // We read visible* via `dynamic` if present.
      final dyn = d as dynamic;
      final Size? visSize = (dyn is dynamic && (dyn.visibleSize is Size))
          ? dyn.visibleSize as Size
          : null;
      final Offset? visPos = (dyn is dynamic && (dyn.visiblePosition is Offset))
          ? dyn.visiblePosition as Offset
          : null;

      final size = visSize ?? d.size;
      final pos = visPos ?? d.visiblePosition!;
      return Rect.fromLTWH(pos.dx, pos.dy, size.width, size.height);
    }

    // 1) exact match: display containing the cursor
    for (final d in displays) {
      if (boundsOf(d).contains(point)) return d;
    }

    // 2) fallback: nearest display by center distance
    Display best = displays.first;
    double bestDist = double.infinity;
    for (final d in displays) {
      final b = boundsOf(d);
      final center = b.center;
      final dx = center.dx - point.dx;
      final dy = center.dy - point.dy;
      final dist = math.sqrt(dx * dx + dy * dy);
      if (dist < bestDist) {
        bestDist = dist;
        best = d;
      }
    }
    return best;
  }

  /// Size the window to a percentage of the chosen display’s work area and center it.
  Future<void> setRelativeFrame(
    WindowController controller, {
    double widthPercent = 0.8, // 80% of display width
    double heightPercent = 0.8, // 80% of display height
    double minWidth = 900,
    double minHeight = 600,
    double maxWidth = 2000,
    double maxHeight = 1400,
    bool useCursorDisplay = true,
  }) async {
    final display = useCursorDisplay
        ? await _pickDisplayUnderCursor()
        : await ScreenRetriever.instance.getPrimaryDisplay();

    // Try visible (work area) first; fall back to full bounds.
    final dyn = display as dynamic;
    final Size? visSize = (dyn is dynamic && (dyn.visibleSize is Size))
        ? dyn.visibleSize as Size
        : null;
    final Offset? visPos = (dyn is dynamic && (dyn.visiblePosition is Offset))
        ? dyn.visiblePosition as Offset
        : null;

    final Size size = visSize ?? display.size;
    final Offset pos = visPos ?? display.visiblePosition!;

    // Some versions expose scaleFactor; if not, assume logical pixels.
    final double scale = (dyn is dynamic && (dyn.scaleFactor is num))
        ? (dyn.scaleFactor as num).toDouble()
        : 1.0;

    final double areaW = size.width / scale;
    final double areaH = size.height / scale;
    final double areaX = pos.dx / scale;
    final double areaY = pos.dy / scale;

    final targetW = areaW * widthPercent;
    final targetH = areaH * heightPercent;

    final w = targetW.clamp(minWidth, maxWidth);
    final h = targetH.clamp(minHeight, maxHeight);

    final left = areaX + (areaW - w) / 2;
    final top = areaY + (areaH - h) / 2;

    await controller.setFrame(Rect.fromLTWH(left, top, w, h));
  }

  Future<void> _onFocus(
    FocusWindowRequested e,
    Emitter<WindowsState> emit,
  ) async {
    final id = state.idByName[e.name];
    if (id == null) return;
    final c =
        state.windowsById[id]?.controller ?? WindowController.fromWindowId(id);
    await c.focus();
    emit(state.copyWith(lastActiveId: id));
  }

  Future<void> _onCloseById(
    CloseWindowByIdRequested e,
    Emitter<WindowsState> emit,
  ) async {
    print("closing");
    final info = state.windowsById[e.id]!;

    try {
      final c = info?.controller ?? WindowController.fromWindowId(e.id);
      await c.close();
    } catch (_) {}

    final windowsById = Map<int, WindowInfo>.from(state.windowsById)
      ..remove(e.id);
    final idByName = Map<String, int>.from(state.idByName);
    if (info != null) idByName.remove(info.name);

    emit(
      state.copyWith(
        windowsById: windowsById,
        idByName: idByName,
        clearLastActive: state.lastActiveId == e.id,
      ),
    );
  }

  Future<void> _onCloseByName(
    CloseWindowByNameRequested e,
    Emitter<WindowsState> emit,
  ) async {
    final id = state.idByName[e.name];
    if (id != null) add(CloseWindowByIdRequested(id));
  }

  Future<void> _onHandle(HandleMethodCall e, Emitter<WindowsState> emit) async {
    final method = e.call.method;
    final args = e.call.arguments;

    print(method);
    switch (method) {
      case 'open_story':
        {
          final sid = (args is Map && args['story_id'] is int)
              ? args['story_id'] as int
              : null;
          if (sid != null) add(OpenWindowRequested.story(sid));
          break;
        }

      case 'register_window':
        {
          final name = (args is Map && args['name'] is String)
              ? args['name'] as String
              : null;
          if (name == null) return;
          // print("window id: from closed ${state.windowsById[e.fromWindowId]}");

          final controller = WindowController.fromWindowId(e.fromWindowId);
          final info = WindowInfo(
            id: e.fromWindowId,
            name: name,
            controller: controller,
          );

          final windowsById = Map<int, WindowInfo>.from(state.windowsById)
            ..[e.fromWindowId] = info;
          final idByName = Map<String, int>.from(state.idByName)
            ..[name] = e.fromWindowId;

          emit(
            state.copyWith(
              windowsById: windowsById,
              idByName: idByName,
              lastActiveId: e.fromWindowId,
            ),
          );
          break;
        }

      case 'window_closed':
        {
          // <-- NEW (you used 'scrape_closed' before—handle both if needed)
          final info = state.windowsById[e.fromWindowId];
          print("info $info");
          if (info != null) {
            final windowsById = Map<int, WindowInfo>.from(state.windowsById)
              ..remove(e.fromWindowId);
            final idByName = Map<String, int>.from(state.idByName)
              ..remove(info.name);
            emit(
              state.copyWith(
                windowsById: windowsById,
                idByName: idByName,
                clearLastActive: state.lastActiveId == e.fromWindowId,
              ),
            );
          }
          break;
        }

      case 'close_name':
        {
          final name = (args is Map && args['name'] is String)
              ? args['name'] as String
              : null;
          if (name != null) add(CloseWindowByNameRequested(name));
          break;
        }

      case 'close_id':
        {
          final id = (args is Map && args['id'] is int)
              ? args['id'] as int
              : null;
          if (id != null) add(CloseWindowByIdRequested(id));
          break;
        }

      case 'focus_name':
        {
          final name = (args is Map && args['name'] is String)
              ? args['name'] as String
              : null;
          if (name != null) add(FocusWindowRequested(name));
          break;
        }

      // add more methods here...

      default:
        optional:
        debugPrint('Unknown window method: $method');
        break;
    }
  }
}

class WindowsState extends Equatable {
  /// id -> info
  final Map<int, WindowInfo> windowsById;

  /// name -> id
  final Map<String, int> idByName;
  final int? lastActiveId;

  const WindowsState({
    this.windowsById = const {},
    this.idByName = const {},
    this.lastActiveId,
  });

  WindowsState copyWith({
    Map<int, WindowInfo>? windowsById,
    Map<String, int>? idByName,
    int? lastActiveId,
    bool clearLastActive = false,
  }) {
    return WindowsState(
      windowsById: windowsById ?? this.windowsById,
      idByName: idByName ?? this.idByName,
      lastActiveId: clearLastActive
          ? null
          : (lastActiveId ?? this.lastActiveId),
    );
  }

  @override
  List<Object?> get props => [windowsById, idByName, lastActiveId];
}

Future<void> closeNamed(String screenName) async {
  await DesktopMultiWindow.invokeMethod(0, 'close_name', {'name': screenName});
}

Future<void> closeStory(int storyId) async {
  await DesktopMultiWindow.invokeMethod(0, 'close_name', {
    'name': "story:$storyId",
  });
}

Future<void> openStory(int storyId) async {
  await DesktopMultiWindow.invokeMethod(0, 'open_story', {'story_id': storyId});
}

Future<void> closeId(int screenId) async {
  await DesktopMultiWindow.invokeMethod(0, 'close_id', {'id': screenId});
}
