import 'dart:ui';

import 'package:screen_retriever/screen_retriever.dart';

abstract class DisplayProvider {
  Future<Offset> getCursorPoint();

  Future<List<Object>>
  getAllDisplays(); // accept any display shape; we read via dynamic
  Future<Object> getPrimaryDisplay();
}

class ScreenRetrieverDisplayProvider implements DisplayProvider {
  const ScreenRetrieverDisplayProvider();

  @override
  Future<Offset> getCursorPoint() {
    return ScreenRetriever.instance.getCursorScreenPoint();
  }

  @override
  Future<List<Object>> getAllDisplays() async {
    final list = await ScreenRetriever.instance.getAllDisplays();
    // We type-erase to Object so WindowPlacementX can work via `dynamic`.
    return list.cast<Object>();
  }

  @override
  Future<Object> getPrimaryDisplay() async {
    return await ScreenRetriever.instance.getPrimaryDisplay();
  }
}
