// story_remote_data_source.dart
// app_api_data_source.dart
//
// Data source for:
//   GET /app/stories/:story_id              -> StoryBundle
//   GET /app/stories/:story_id/parts/:part_id -> PartFullInfo
//
// Optional helper included for listing stories if your server exposes it at GET /app/stories.
//
// Add to pubspec:
// dependencies:
//   http: ^1.2.2
//
// Then run your json_serializable build as usual.

import 'dart:async';
import 'dart:convert';

import 'package:dio/dio.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter_client_sse/constants/sse_request_type_enum.dart';
import 'package:flutter_client_sse/flutter_client_sse.dart';
import 'package:http/http.dart' as http;
import 'package:locallibrary/wattpad_publisher/models/server_models.dart';

import 'models/logs.dart';
import 'models/models.dart';

class ApiException implements Exception {
  final int? statusCode;
  final String message;
  final Uri? uri;
  final Object? inner;

  ApiException(this.message, {this.statusCode, this.uri, this.inner});

  @override
  String toString() =>
      'ApiException(statusCode: $statusCode, message: $message, uri: $uri, inner: $inner)';
}

class ApiPage<T> {
  final List<T> items;

  const ApiPage({required this.items});
}

class AppApiDataSource {
  final String baseUrl;
  final http.Client _client;
  final Duration timeout;
  final Map<String, String> defaultHeaders;

  /// Optionally pass an auth token or custom headers via [defaultHeaders].
  AppApiDataSource({
    required this.baseUrl,
    http.Client? client,
    this.timeout = const Duration(seconds: 15),
    Map<String, String>? defaultHeaders,
  }) : _client = client ?? http.Client(),
       defaultHeaders = {
         'Accept': 'application/json',
         'Content-Type': 'application/json',
         if (defaultHeaders != null) ...defaultHeaders,
       };

  /// Clean up the underlying HTTP client.
  void close() => _client.close();

  // ----------- Public API -----------

  /// GET /app/stories/:story_id
  Future<StoryBundle> getFullStoryInfo(int storyId) async {
    final path = '/app/stories/$storyId';
    final res = await _safeGet(_uri(path));
    final jsonMap = _decodeJsonMap(res);
    return StoryBundle.fromJson(jsonMap);
  }

  /// GET /app/stories/:story_id/parts/:part_id
  Future<PartFullInfo> getFullPartInfo({
    required int storyId,
    required int partId,
  }) async {
    final path = '/app/stories/$storyId/parts/$partId';
    final res = await _safeGet(_uri(path));
    final jsonMap = _decodeJsonMap(res);
    return PartFullInfo.fromJson(jsonMap);
  }

  /// Optional convenience for a "list stories" endpoint if present at /app/stories.
  /// Adjust the path if your server uses a different route.
  Future<List<Story>> listStories({int limit = 18, int offset = 0}) async {
    final path = '/stories';
    final qp = <String, String>{'limit': '$limit', 'offset': '$offset'};
    final res = await _safeGet(_uri(path).replace(queryParameters: qp));
    final body = _decodeBodyString(res);
    return storyListFromJson(body);
  }

  Future<List<int>> listCurrentlyReadingStories({
    required DateTime since,
    int limit = 6,
    int offset = 0,
  }) async {
    const path = '/stories/currently_reading';

    // base params
    final qp = <String, String>{'limit': '$limit', 'offset': '$offset'};

    // Only send timestamp if caller provided it.
    // Ensure RFC3339 without milliseconds: 2006-01-02T15:04:05Z
    final ts = since.toUtc().toIso8601String();
    final rfc3339 = ts.contains('.')
        ? '${ts.substring(0, ts.indexOf('.'))}Z'
        : ts; // already ends with 'Z'
    qp['timestamp'] = rfc3339;

    final uri = _uri(path).replace(queryParameters: qp);
    final res = await _safeGet(uri);
    final body = _decodeBodyString(res);
    final decoded = jsonDecode(body);

    // Accept either [1,2,3] or { "story_ids": [1,2,3] }
    final list = (decoded is List)
        ? decoded
        : (decoded is Map<String, dynamic> ? decoded['story_ids'] : null);

    if (list is! List) {
      throw Exception('Unexpected response for currently reading: $decoded');
    }
    return list.map<int>((e) => (e as num).toInt()).toList();
  }

  Future<List<int>> listRecentlyAddedStories({
    required DateTime since,
    int limit = 6,
    int offset = 0,
  }) async {
    const path = '/stories/recently_added';

    // base params
    final qp = <String, String>{'limit': '$limit', 'offset': '$offset'};

    // Only send timestamp if caller provided it.
    // Ensure RFC3339 without milliseconds: 2006-01-02T15:04:05Z
    final ts = since.toUtc().toIso8601String();
    final rfc3339 = ts.contains('.')
        ? '${ts.substring(0, ts.indexOf('.'))}Z'
        : ts; // already ends with 'Z'
    qp['timestamp'] = rfc3339;

    final uri = _uri(path).replace(queryParameters: qp);
    final res = await _safeGet(uri);
    final body = _decodeBodyString(res);
    final decoded = jsonDecode(body);

    // Accept either [1,2,3] or { "story_ids": [1,2,3] }
    final list = (decoded is List)
        ? decoded
        : (decoded is Map<String, dynamic> ? decoded['story_ids'] : null);

    if (list is! List) {
      throw Exception('Unexpected response for recently added: $decoded');
    }
    return list.map<int>((e) => (e as num).toInt()).toList();
  }

  Future<List<int>> listRecentlyFinishedStories({
    required DateTime since,
    int limit = 6,
    int offset = 0,
  }) async {
    const path = '/stories/recently_finished';

    // base params
    final qp = <String, String>{'limit': '$limit', 'offset': '$offset'};

    // Only send timestamp if caller provided it.
    // Ensure RFC3339 without milliseconds: 2006-01-02T15:04:05Z
    final ts = since.toUtc().toIso8601String();
    final rfc3339 = ts.contains('.')
        ? '${ts.substring(0, ts.indexOf('.'))}Z'
        : ts; // already ends with 'Z'
    qp['timestamp'] = rfc3339;

    final uri = _uri(path).replace(queryParameters: qp);
    final res = await _safeGet(uri);
    final body = _decodeBodyString(res);
    final decoded = jsonDecode(body);

    // Accept either [1,2,3] or { "story_ids": [1,2,3] }
    final list = (decoded is List)
        ? decoded
        : (decoded is Map<String, dynamic> ? decoded['story_ids'] : null);

    if (list is! List) {
      throw Exception('Unexpected response for currently finished: $decoded');
    }
    return list.map<int>((e) => (e as num).toInt()).toList();
  }

  Future<List<Paragraph>> fetchPartParagraphs({
    required int storyId,
    required int partId,
    int limit = 50,
    int offset = 0,
  }) async {
    final uri = _uri(
      '/stories/$storyId/parts/$partId/paragraphs',
      // adjust if your server uses /app/ prefix
      {'limit': '$limit', 'offset': '$offset'},
    );

    final res = await _safeGet(uri);
    final body = _decodeBodyString(res);
    final decoded = jsonDecode(body);

    // Support a few common shapes: plain list, {paragraphs: [...]}, {results: [...]}, {items: [...]}
    List list;
    if (decoded is List) {
      list = decoded;
    } else if (decoded is Map) {
      list =
          (decoded['paragraphs'] ??
                  decoded['results'] ??
                  decoded['items'] ??
                  [])
              as List;
    } else {
      list = const [];
    }

    return list
        .map((e) => Paragraph.fromJson(e as Map<String, dynamic>))
        .toList();
  }

  // ----------- Internal helpers -----------

  Uri _uri(String path, [Map<String, dynamic>? query]) {
    final normalizedBase = baseUrl.endsWith('/')
        ? baseUrl.substring(0, baseUrl.length - 1)
        : baseUrl;
    return Uri.parse('$normalizedBase$path').replace(
      queryParameters: query?.map((k, v) => MapEntry(k, v?.toString() ?? '')),
    );
  }

  Future<http.Response> _safeGet(Uri uri) async {
    try {
      final res = await _client
          .get(uri, headers: defaultHeaders)
          .timeout(timeout);
      _ensureSuccess(res);
      return res;
    } on TimeoutException catch (e) {
      throw ApiException('Request timed out', uri: uri, inner: e);
    } on http.ClientException catch (e) {
      throw ApiException('Network error', uri: uri, inner: e);
    } catch (e) {
      throw ApiException('Unexpected error', uri: uri, inner: e);
    }
  }

  void _ensureSuccess(http.Response res) {
    if (res.statusCode < 200 || res.statusCode >= 300) {
      final msg = _safeExtractError(res);
      throw ApiException(
        'HTTP ${res.statusCode}: $msg',
        statusCode: res.statusCode,
        uri: res.request?.url,
      );
    }
  }

  String _decodeBodyString(http.Response res) =>
      // Use bytes+utf8 to preserve Arabic text correctly.
      utf8.decode(res.bodyBytes);

  Map<String, dynamic> _decodeJsonMap(http.Response res) {
    final body = _decodeBodyString(res);
    final dynamic decoded = jsonDecode(body);
    if (decoded is Map<String, dynamic>) return decoded;
    throw ApiException(
      'Expected JSON object but got ${decoded.runtimeType}',
      statusCode: res.statusCode,
      uri: res.request?.url,
    );
  }

  String _safeExtractError(http.Response res) {
    try {
      final decoded = jsonDecode(_decodeBodyString(res));
      if (decoded is Map && decoded['error'] != null) {
        return decoded['error'].toString();
      }
      return decoded.toString();
    } catch (_) {
      return res.reasonPhrase ?? 'Unknown error';
    }
  }

  /// Emits SimpleEvent(event, payload) from your POST SSE endpoint.
  Stream<ScrapeEvent> streamScrapeStory({
    required String storyUrl, // the Wattpad URL
    bool clearOutput = false,
    Map<String, String>? extraHeaders,
  }) {
    final headers = <String, String>{
      'Accept': 'text/event-stream',
      'Cache-Control': 'no-cache',
      'Content-Type': 'application/json',
      if (extraHeaders != null) ...extraHeaders,
    };

    final body = {
      'url': storyUrl,
      // 'output_dir': outputDir,
      'clear_output': clearOutput,
    };

    final url = _uri(
      '/app/scrape/story/stream'
      '',
    ).toString();

    print(url);

    // Subscribe with POST, body, and headers
    final base = SSEClient.subscribeToSSE(
      method: SSERequestType.POST,
      url: url,
      header: headers,
      body: body,
    ); // -> Stream<SSEModel> with .event, .data

    // Map to SimpleEvent and **fan-out** when multiple JSONs appear in one data payload
    return base
        .where((m) => (m.data ?? '').isNotEmpty)
        .map((m) => ScrapeEvent(m.event ?? 'message', m.data!))
        .asyncExpand((evt) async* {
          for (final piece in _splitNdjsonOrConcatenated(evt.payload)) {
            yield ScrapeEvent(evt.name, piece);
          }
        });
  }

  Stream<ScrapeEvent> streamScrapePart({
    required String partUrl, // the Wattpad URL
    required int storyId, // the Wattpad URL
    bool clearOutput = false,
    Map<String, String>? extraHeaders,
  }) {
    final headers = <String, String>{
      'Accept': 'text/event-stream',
      'Cache-Control': 'no-cache',
      'Content-Type': 'application/json',
      if (extraHeaders != null) ...extraHeaders,
    };

    final body = {
      'url': partUrl,
      "story_id": storyId,
      'clear_output': clearOutput,
    };

    final url = _uri(
      '/app/scrape/part/stream'
      '',
    ).toString();

    // Subscribe with POST, body, and headers
    final base = SSEClient.subscribeToSSE(
      method: SSERequestType.POST,
      url: url,

      header: headers,
      body: body,
    ); // -> Stream<SSEModel> with .event, .data

    // Map to SimpleEvent and **fan-out** when multiple JSONs appear in one data payload
    return base
        .where((m) => (m.data ?? '').isNotEmpty)
        .map((m) => ScrapeEvent(m.event ?? 'message', m.data!))
        .asyncExpand((evt) async* {
          for (final piece in _splitNdjsonOrConcatenated(evt.payload)) {
            yield ScrapeEvent(evt.name, piece);
          }
        });
  }

  Stream<ScrapeEvent> streamScrapeComments({
    required String partUrl,
    required int storyId,
    bool clearOutput = false,
    Map<String, String>? extraHeaders,
  }) {
    final headers = <String, String>{
      'Accept': 'text/event-stream',
      'Cache-Control': 'no-cache',
      'Content-Type': 'application/json',
      if (extraHeaders != null) ...extraHeaders,
    };

    final body = {
      'url': partUrl,
      'story_id': storyId,
      'clear_output': clearOutput,
    };

    final url = _uri('/app/scrape/comments/stream').toString();

    final base = SSEClient.subscribeToSSE(
      method: SSERequestType.POST,
      url: url,
      header: headers,
      body: body,
    );

    return base
        .where((m) => (m.data ?? '').isNotEmpty)
        .map((m) => ScrapeEvent(m.event ?? 'message', m.data!))
        .asyncExpand((evt) async* {
          for (final piece in _splitNdjsonOrConcatenated(evt.payload)) {
            yield ScrapeEvent(evt.name, piece);
          }
        });
  }

  /// Splits NDJSON/newline or concatenated `{...}{...}` JSON into individual JSON strings.
  Iterable<String> _splitNdjsonOrConcatenated(String s) sync* {
    for (final line in const LineSplitter().convert(s)) {
      final t = line.trim();
      if (t.isEmpty) continue;
      for (final piece in _splitConcatenatedJsonObjects(t)) {
        final pt = piece.trim();
        if (pt.isNotEmpty) yield pt;
      }
    }
  }

  Iterable<String> _splitConcatenatedJsonObjects(String s) sync* {
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

    for (final piece in out) {
      yield piece;
    }
  }

  // -------------------- Internal SSE plumbing --------------------

  /// Posts JSON and parses text/event-stream into ScrapeEvent objects.
  /// Cancelling the StreamSubscription will close the underlying HTTP client.

  // comments
  // ===========================
  //           comments
  // ===========================

  // Flexible parser: accepts [], {items:[]}, {comments:[]}, {data:{items:[]}}
  List<Comment> _parseComments(dynamic decoded) {
    List raw;
    if (decoded is List) {
      raw = decoded;
    } else if (decoded is Map) {
      final container =
          decoded['items'] ??
          decoded['comments'] ??
          (decoded['data'] is Map ? decoded['data']['items'] : null);
      raw = (container is List) ? container : const [];
    } else {
      raw = const [];
    }
    return raw
        .whereType<Map<String, dynamic>>()
        .map((e) => Comment.fromJson(e))
        .toList();
  }

  /// GET /app/stories/:story_id/paragraphs/:paragraph_id/comments?limit&offset
  Future<ApiPage<Comment>> fetchParagraphComments({
    required int storyId,
    required int paragraphId,
    int? limit,
    int? offset,
  }) async {
    Map<String, dynamic> list = {};
    if (limit != null) list['limit'] = '$limit';
    if (offset != null) list['offset'] = '$offset';

    final uri = _uri(
      '/app/stories/$storyId/paragraphs/$paragraphId/comments',
      list,
    );
    final res = await _safeGet(uri);
    final body = _decodeBodyString(res);
    final decoded = jsonDecode(body);
    return ApiPage<Comment>(items: _parseComments(decoded));
  }

  /// GET /app/stories/:story_id/parts/:part_id/comments?limit&offset
  Future<ApiPage<Comment>> fetchPartComments({
    required int storyId,
    required int partId,
    int? limit,
    int? offset,
  }) async {
    Map<String, dynamic> list = {};
    if (limit != null) list['limit'] = '$limit';
    if (offset != null) list['offset'] = '$offset';

    final uri = _uri('/app/stories/$storyId/parts/$partId/comments', list);
    final res = await _safeGet(uri);
    final body = _decodeBodyString(res);
    final decoded = jsonDecode(body);
    return ApiPage<Comment>(items: _parseComments(decoded));
  }

  /// GET /app/stories/:story_id/comments/:comment_id/replies?limit&offset
  Future<ApiPage<Comment>> fetchCommentReplies({
    required int storyId,
    required int commentId,
    int? limit,
    int? offset,
  }) async {
    Map<String, dynamic> list = {};
    if (limit != null) list['limit'] = '$limit';
    if (offset != null) list['offset'] = '$offset';
    final uri = _uri('/app/stories/$storyId/comments/$commentId/replies', list);
    final res = await _safeGet(uri);
    final body = _decodeBodyString(res);
    final decoded = jsonDecode(body);
    return ApiPage<Comment>(items: _parseComments(decoded));
  }

  /// GET /app/stories/:story_id/parts/:part_id/paragraphs/count
  Future<int> getPartParagraphsCount({
    required int storyId,
    required int partId,
  }) async {
    final res = await _safeGet(
      _uri('/app/stories/$storyId/parts/$partId/paragraphs/count'),
    );
    return _parseCount(res);
  }

  /// GET /app/stories/:story_id/parts/:part_id/comments/count
  Future<int> getPartCommentsCount({
    required int storyId,
    required int partId,
  }) async {
    final res = await _safeGet(
      _uri('/app/stories/$storyId/parts/$partId/comments/count'),
    );
    return _parseCount(res);
  }

  int _parseCount(http.Response res) {
    final decoded = jsonDecode(_decodeBodyString(res));
    if (decoded is int) return decoded;
    if (decoded is num) return decoded.toInt();
    if (decoded is Map) {
      final v = decoded['count'] ?? decoded['total'];
      if (v is num) return v.toInt();
    }
    throw ApiException(
      'Unexpected count response: $decoded',
      statusCode: res.statusCode,
      uri: res.request?.url,
    );
  }

  // streamScrapePartByIds({required int storyId, required int partId, required bool clearOutput}) {}
}

// Contract
abstract class StoryRemoteDataSource {
  Future<BookMinimal> fetchMinimal({
    required int storyId,
    CancelToken? cancelToken,
  });
}

// Implementation (Dio)
class StoryRemoteDataSourceImpl implements StoryRemoteDataSource {
  final Dio _dio;

  StoryRemoteDataSourceImpl({required Dio dio}) : _dio = dio;

  @override
  Future<BookMinimal> fetchMinimal({
    required int storyId,
    CancelToken? cancelToken,
  }) async {
    try {
      final res = await _dio.get<Map<String, dynamic>>(
        '/stories/$storyId/min',
        cancelToken: cancelToken,
      );
      if (res.statusCode == 200 && res.data != null) {
        return BookMinimal.fromJson(res.data!);
      }
      throw ApiException(
        'Unexpected status ${res.statusCode}',
        statusCode: res.statusCode,
      );
    } on DioException catch (e) {
      // Log details so you see WHY it failed
      debugPrint(
        'Dio error type: ${e.type} | msg: ${e.message} | url: ${_dio.options.baseUrl}',
      );
      throw ApiException('Network error: ${e.message}');
    }
  }
}
