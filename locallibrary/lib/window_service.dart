// window_service.dart
//
// Convenience helpers to open additional desktop windows that land on the
// routes your GoRouter (AppRoute.router) understands.
//
// Example usage from any widget/cubit:
//   final id = await AppWindows.openStoryWindow(storyId: 1);
//   final id2 = await AppWindows.openPartWindow(storyId: 1, partId: 10);
//   await AppWindows.navigate(windowId: id2, path: '/story/1/parts/10'); // later
//
// Remember: each window has its own isolate. Use invokeMethod to pass messages.

import 'dart:convert';

import 'package:desktop_multi_window/desktop_multi_window.dart';
import 'package:flutter/material.dart';

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
}
