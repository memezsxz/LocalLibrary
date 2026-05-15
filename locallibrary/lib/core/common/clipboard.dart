import 'package:flutter/services.dart';

class ClipboardService {
  static final ClipboardService _instance = ClipboardService._internal();

  factory ClipboardService() => _instance;

  ClipboardService._internal();

  Future<void> copyToClipboard(String text) async {
    await Clipboard.setData(ClipboardData(text: text));
  }

  Future<String?> getFromClipboard() async {
    final data = await Clipboard.getData(Clipboard.kTextPlain);
    return data?.text;
  }

  Future<bool> hasClipboardData() async {
    final data = await Clipboard.getData(Clipboard.kTextPlain);
    return data?.text != null && data!.text!.isNotEmpty;
  }
}
