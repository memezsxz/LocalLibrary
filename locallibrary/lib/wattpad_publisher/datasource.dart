// story_remote_data_source.dart
import 'dart:io';
import 'package:dio/dio.dart';
import 'package:flutter/cupertino.dart';
import 'package:locallibrary/wattpad_publisher/models/server_models.dart';

import 'models/models.dart';

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
import 'package:http/http.dart' as http;

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
  Future<List<Story>> listStories() async {
    final path = '/app/stories';
    final res = await _safeGet(_uri(path));
    final body = _decodeBodyString(res);
    return storyListFromJson(body);
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

  /// Stream logs for a Story scrape (SSE).
  Stream<ScrapeEvent> streamScrapeStory({
    required String storyUrl,
    // required String outputDir,
    bool clearOutput = false,
  }) {
    final uri = _uri('/app/scrape/story/stream');
    final body = jsonEncode({
      'story_url': storyUrl,
      // 'output_dir': outputDir,
      'clear_output': clearOutput,
    });
    return _postSSE(uri, body);
  }

  /// Stream logs for a Part scrape (SSE).
  Stream<ScrapeEvent> streamScrapePart({
    required String partUrl,
    // required String outputDir,
    bool clearOutput = false,
  }) {
    final uri = _uri('/app/scrape/part/stream');
    final body = jsonEncode({
      'part_url': partUrl,
      // 'output_dir': outputDir,
      'clear_output': clearOutput,
    });
    return _postSSE(uri, body);
  }

  /// Stream logs for a Part-Comments scrape (SSE).
  Stream<ScrapeEvent> streamScrapePartComments({
    required String partUrl,
    // required String outputDir,
    bool clearOutput = false,
  }) {
    final uri = _uri('/scrape/part-comments/stream');
    final body = jsonEncode({
      'part_url': partUrl,
      // 'output_dir': outputDir,
      'clear_output': clearOutput,
    });
    return _postSSE(uri, body);
  }

  /// Optional: Blocking call that returns all logs at the end (non-SSE endpoint).
  Future<List<dynamic>> scrapeStoryOnce({
    required String storyUrl,
    // required String outputDir,
    bool clearOutput = false,
  }) async {
    final uri = _uri('/scrape/story');
    final res = await _client
        .post(
          uri,
          headers: {
            // override accept for JSON POST
            ...defaultHeaders,
            'Accept': 'application/json',
          },
          body: jsonEncode({
            'story_url': storyUrl,
            // 'output_dir': outputDir,
            'clear_output': clearOutput,
          }),
        )
        .timeout(timeout);

    _ensureSuccess(res);
    final map = _decodeJsonMap(res);
    final logs = map['logs'];
    if (logs is List) return logs;
    throw ApiException(
      'Unexpected response shape: missing "logs"',
      statusCode: res.statusCode,
      uri: res.request?.url,
    );
  }

  // -------------------- Internal SSE plumbing --------------------

  /// Posts JSON and parses text/event-stream into ScrapeEvent objects.
  /// Cancelling the StreamSubscription will close the underlying HTTP client.
  Stream<ScrapeEvent> _postSSE(Uri uri, String jsonBody) {
    // Use a dedicated client per SSE so cancel/close won’t affect the shared one.
    final sseClient = http.Client();
    final req = http.Request('POST', uri)
      ..headers.addAll({
        // SSE requires this Accept; Content-Type stays JSON.
        'Accept': 'text/event-stream',
        'Content-Type': 'application/json',
        // (Optionally forward auth headers if defaultHeaders carry them)
        ...{
          for (final e in defaultHeaders.entries)
            if (e.key.toLowerCase() != 'accept') e.key: e.value,
        },
      })
      ..body = jsonBody;

    final controller = StreamController<ScrapeEvent>(
      onCancel: () {
        sseClient.close();
      },
    );

    () async {
      http.StreamedResponse resp;
      try {
        resp = await sseClient.send(req).timeout(timeout);
      } on TimeoutException catch (e) {
        controller.addError(
          ApiException('SSE connect timeout', uri: uri, inner: e),
        );
        await controller.close();
        return;
      } catch (e) {
        controller.addError(
          ApiException('SSE connect error', uri: uri, inner: e),
        );
        await controller.close();
        return;
      }

      if (resp.statusCode < 200 || resp.statusCode >= 300) {
        // read small error payload if present
        final errBody = await resp.stream.bytesToString();
        controller.addError(
          ApiException(
            'HTTP ${resp.statusCode}: $errBody',
            statusCode: resp.statusCode,
            uri: uri,
          ),
        );
        await controller.close();
        return;
      }

      // Parse SSE frames: lines of "event: ..." and "data: ...", separated by blank line
      String currentEvent = 'message';
      final dataLines = <String>[];

      void flush() {
        if (dataLines.isEmpty) return;
        final payload = dataLines.join('\n');
        dynamic parsed = payload;
        // Try to parse JSON data payloads (your backend sends JSON in "data:")
        try {
          parsed = jsonDecode(payload);
        } catch (_) {
          // leave as string if not JSON
        }
        controller.add(ScrapeEvent(currentEvent, parsed));
        currentEvent = 'message';
        dataLines.clear();
      }

      // read as text lines
      final sub = resp.stream
          .transform(utf8.decoder)
          .transform(const LineSplitter())
          .listen(
            (line) {
              // Per SSE: empty line => dispatch event
              if (line.isEmpty) {
                flush();
                return;
              }
              if (line.startsWith('event:')) {
                currentEvent = line.substring(6).trim();
                return;
              }
              if (line.startsWith('data:')) {
                dataLines.add(line.substring(5).trimLeft());
                return;
              }
              // Optional: ignore "retry:" or other fields; or treat as data
              // Here we ignore other fields.
            },
            onError: (e, st) async {
              controller.addError(
                ApiException('SSE stream error', uri: uri, inner: e),
              );
              await controller.close();
            },
            onDone: () async {
              // flush any pending
              flush();
              await controller.close();
            },
            cancelOnError: true,
          );

      // If the consumer cancels early, stop reading
      controller.onCancel = () async {
        await sub.cancel();
        sseClient.close();
      };
    }();

    return controller.stream;
  }

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

    final uri = _uri('/app/stories/$storyId/paragraphs/$paragraphId/comments', list);
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

class ScrapeEvent {
  final String type; // "started" | "log" | "finished" | "error" | ...
  final dynamic data; // parsed JSON if data line is JSON, else String

  ScrapeEvent(this.type, this.data);

  @override
  String toString() => 'ScrapeEvent(type: $type, data: $data)';
}
