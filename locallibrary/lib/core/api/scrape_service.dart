import 'dart:convert';

import 'package:flutter_client_sse/constants/sse_request_type_enum.dart';
import 'package:flutter_client_sse/flutter_client_sse.dart';

import '../../features/story/models/scrape/scrape_event_model.dart';

class ScrapeService {
  ScrapeService({required this.baseUrl, this.extraHeaders = const {}});

  final String baseUrl;
  final Map<String, String> extraHeaders;

  Stream<ScrapeEvent> streamScrapeStory({
    required String storyUrl,
    bool clearOutput = false,
  }) {
    return _stream(
      path: '/app/scrape/story/stream',
      body: {'url': storyUrl, 'clear_output': clearOutput},
    );
  }

  Stream<ScrapeEvent> streamScrapePart({
    required String partUrl,
    required int storyId,
    bool clearOutput = false,
    bool withComments = false,
  }) {
    return _stream(
      path: '/app/scrape/part/stream',
      body: {
        'url': partUrl,
        'story_id': storyId,
        'clear_output': clearOutput,
        'with_comments': withComments,
      },
    );
  }

  Stream<ScrapeEvent> streamScrapeComments({
    required String partUrl,
    required int storyId,
    bool clearOutput = false,
  }) {
    return _stream(
      path: '/app/scrape/comments/stream',
      body: {'url': partUrl, 'story_id': storyId, 'clear_output': clearOutput},
    );
  }

  // ─── Internal ─────────────────────────────────────────────────────────────

  Stream<ScrapeEvent> _stream({
    required String path,
    required Map<String, dynamic> body,
  }) {
    final headers = <String, String>{
      'Accept': 'text/event-stream',
      'Cache-Control': 'no-cache',
      'Content-Type': 'application/json',
      ...extraHeaders,
    };

    final base = SSEClient.subscribeToSSE(
      method: SSERequestType.POST,
      url: '$baseUrl$path',
      header: headers,
      body: body,
    );

    return base
        .where((m) => (m.data ?? '').isNotEmpty)
        .map((m) => ScrapeEvent(m.event ?? 'message', m.data!))
        .asyncExpand((evt) async* {
          for (final piece in _splitNdjson(evt.payload)) {
            yield ScrapeEvent(evt.name, piece);
          }
        });
  }

  Iterable<String> _splitNdjson(String s) sync* {
    for (final line in const LineSplitter().convert(s)) {
      final t = line.trim();
      if (t.isEmpty) continue;
      for (final piece in _splitConcatenated(t)) {
        final pt = piece.trim();
        if (pt.isNotEmpty) yield pt;
      }
    }
  }

  Iterable<String> _splitConcatenated(String s) sync* {
    final out = <String>[];
    final buf = StringBuffer();
    var depth = 0;
    var inString = false;
    var escape = false;

    for (final r in s.runes) {
      final ch = String.fromCharCode(r);
      buf.write(ch);

      if (escape) {
        escape = false;
        continue;
      }
      if (ch == '\\') {
        escape = true;
        continue;
      }
      if (ch == '"') {
        inString = !inString;
        continue;
      }
      if (inString) continue;

      if (ch == '{') depth++;
      if (ch == '}') {
        depth--;
        if (depth == 0) {
          out.add(buf.toString());
          buf.clear();
        }
      }
    }
    if (buf.isNotEmpty) out.add(buf.toString());
    for (final piece in out) yield piece;
  }
}
