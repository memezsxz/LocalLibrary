// app_secrets.dart
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'dart:io' show Platform;

class AppSecrets {
  static String get apiBaseUrl {
    // read AFTER dotenv.load()
    final raw = (dotenv.maybeGet('API_BASE_URL') ?? '').trim();

    // strip accidental quotes in .env like API_BASE_URL="0.0.0.0:5050"
    var url = raw.replaceAll('"', '').replaceAll("'", '');

    // sensible defaults for local dev
    if (url.isEmpty) {
      if (kIsWeb) return 'http://localhost:5050';
      if (!kIsWeb && Platform.isAndroid) return 'http://10.0.2.2:5050';
      return 'http://127.0.0.1:5050'; // macOS/iOS simulator/desktop
    }

    // add scheme if missing
    if (!url.startsWith('http://') && !url.startsWith('https://')) {
      url = 'http://$url';
    }

    // 0.0.0.0 is not routable from the client; map to localhost
    url = url.replaceFirst('://0.0.0.0', '://127.0.0.1');

    return url;
  }
}
