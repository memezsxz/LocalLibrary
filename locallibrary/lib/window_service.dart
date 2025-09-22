import 'dart:async';
import 'dart:convert';

import 'package:desktop_multi_window/desktop_multi_window.dart';
import 'package:flutter/material.dart';

import 'core/route/route.dart';

class AppWindows {
  /// Launch a window and navigate it to a story details route.
  static Future<int> openStoryWindow({required int storyId}) async {
    final controller = await DesktopMultiWindow.createWindow(
      jsonEncode({
        'initialRoute': '/stories/$storyId',
        'kind': 'story',
        'storyId': storyId,
      }),
    );
    controller
      ..setTitle('Story #$storyId')
      ..center()
      ..setFrame(const Offset(0, 0) & const Size(1100, 720))
      ..show();
    return controller.windowId;
  }

  /// Launch a window and navigate it straight to a part view.
  static Future<int> openPartWindow({
    required int storyId,
    required int partId,
  }) async {
    final controller = await DesktopMultiWindow.createWindow(
      jsonEncode({
        'initialRoute': '/stories/$storyId/parts/$partId',
        'kind': 'part',
        'storyId': storyId,
        'partId': partId,
      }),
    );
    controller
      ..setTitle('Story $storyId • Part $partId')
      ..center()
      ..setFrame(const Offset(0, 0) & const Size(1100, 720))
      ..show();
    return controller.windowId;
  }

  /// Send a navigation command to an existing sub-window.
  static Future<dynamic> navigate({
    required int windowId,
    required String path,
  }) {
    return DesktopMultiWindow.invokeMethod(windowId, 'navigate', {
      'path': path,
    });
  }

  /// Programmatically close a window.
  static Future<dynamic> close({required int windowId}) {
    return DesktopMultiWindow.invokeMethod(windowId, 'close', {});
  }

  /// Get all current sub-window IDs (not including the main window with id=0).
  static Future<List<int>> subWindowIds() {
    return DesktopMultiWindow.getAllSubWindowIds();
  }

  static Future<void> focus({required int windowId}) async {
    // If you later add window_manager, call show()/focus() there.
    await DesktopMultiWindow.invokeMethod(windowId, 'focus', {});
  }
}

class ScrapeStoryAppWindow {
  ScrapeStoryAppWindow._();

  static final ScrapeStoryAppWindow I = ScrapeStoryAppWindow._();

  /// Listen to this for changes (null when closed, int when open).
  final ValueNotifier<int?> id = ValueNotifier<int?>(null);

  Future<void> openOrFocus() async {
    final current = id.value;
    if (current == null) {
      final win = await DesktopMultiWindow.createWindow(
        jsonEncode({
          'initialRoute': AppRoute.scrapeInitLocation, // your route
          'kind': 'scrape',
          // send parent id if you need to call back
          // 'parentId': DesktopMultiWindow.getMainWindowId(),
        }),
      );
      id.value = win.windowId;
      win
        ..setTitle('Local Library — Add Story')
        ..setFrame(const Offset(120, 120) & const Size(1040, 760))
        ..show();
      return;
    }
    try {
      await DesktopMultiWindow.invokeMethod(current, 'focus', null);
    } catch (_) {
      id.value = null;
      await openOrFocus();
    }
  }

  void markClosed(int closedId) {
    if (id.value == closedId) id.value = null;
  }
}

// now i want to enable update when the id changes to a number or becomes null (extension ScrapeStoryAppWindow on AppWindows {
// static int? _id;
//
// static Future<void> openOrFocus() async {
// if (_id == null) {
// final win = await DesktopMultiWindow.createWindow(
// jsonEncode({
// 'initialRoute': AppRoute.scrapeInitLocation,
// // make sure your sub-window router handles this
// 'kind': 'scrape',
// }),
// );
// _id = win.windowId;
// win
// ..setTitle('Local Library — Add Story')
// ..setFrame(const Offset(120, 120) & const Size(1040, 760))
// ..show();
// return;
// }
// // Ask the sub-window to bring itself to front (handled in sub-window main)
// try {
// await DesktopMultiWindow.invokeMethod(_id!, 'focus', null);
// } catch (_) {
// // If the window was closed/crashed, recreate
// _id = null;
// await openOrFocus();
// }
// }
//
// static void markClosed(int id) {
// if (_id == id) _id = null;
// }
// }
// )  what is the best way to do this in a subscription way or any other way?
