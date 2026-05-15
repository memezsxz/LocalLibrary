import 'dart:convert';

String? defaultErrorExtractor(String data) {
  try {
    final v = _tryParseJsonMap(data);
    if (v == null) return null;

    if (v['status'] == 'failed') {
      final e = v['error'];
      if (e is Map) {
        return (e['message'] ?? e['error'] ?? 'Operation failed').toString();
      }
      return 'Operation failed';
    }
    if (v.containsKey('message')) return v['message']?.toString();
    if (v.containsKey('error')) return v['error']?.toString();
  } catch (_) {}
  return null;
}

Iterable<String> splitNdjsonOrConcatenated(String s) sync* {
  for (final line in const LineSplitter().convert(s)) {
    final t = line.trim();
    if (t.isEmpty) continue;
    yield t;
  }
}

bool _looksLikeJson(String s) {
  final t = s.trimLeft();
  return t.startsWith('{') || t.startsWith('[');
}

Map<String, dynamic>? _tryParseJsonMap(String s) {
  try {
    final v = jsonDecode(s);
    if (v is Map<String, dynamic>) return v;
  } catch (_) {}
  return null;
}
