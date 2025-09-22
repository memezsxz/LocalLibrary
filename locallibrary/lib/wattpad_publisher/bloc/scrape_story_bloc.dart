import 'dart:async';
import 'dart:convert';

import 'package:bloc/bloc.dart';

import '../datasource.dart';
import '../models/logs.dart';
import '../models/server_models.dart';

part 'scrape_story_event.dart';
part 'scrape_story_state.dart';

enum ScrapeStatus { idle, connecting, streaming, done, error }

class ScrapeStoryState {
  final ScrapeStatus status;
  final String url;
  final String? errorMessage;
  final List<ScrapeEvent> events;
  final String? urlHint;
  final ScrapeStoryRes? result;

  const ScrapeStoryState({
    this.status = ScrapeStatus.idle,
    this.url = '',
    this.errorMessage,
    this.events = const [],
    this.result,
    this.urlHint,
  });

  ScrapeStoryState copyWith({
    ScrapeStatus? status,
    String? url,
    String? errorMessage,
    List<ScrapeEvent>? events,
    ScrapeStoryRes? result,
    bool clearError = false,
    bool clearResult = false,
    String? urlHint,
  }) {
    return ScrapeStoryState(
      status: status ?? this.status,
      url: url ?? this.url,
      errorMessage: clearError ? null : (errorMessage ?? this.errorMessage),
      events: events ?? this.events,
      result: clearResult ? null : (result ?? this.result),
    );
  }
}

String? _validateUrlMessage(String raw) {
  final v = raw.trim();
  if (v.isEmpty) return 'Problem: Url is required';

  final uri = Uri.tryParse(v);
  if (uri == null ||
      (uri.host != 'www.wattpad.com' && uri.host != 'wattpad.com')) {
    return 'Problem: not a wattpad.com URL';
  }

  // Expect /story/<digits>(-slug...)
  if (uri.pathSegments.length < 2 || uri.pathSegments.first != 'story') {
    return 'Problem: expected /story/<digits>(-slug)';
  }

  // First segment after /story must start with digits
  final idMatch = RegExp(r'^\d+').firstMatch(uri.pathSegments[1]);
  if (idMatch == null) {
    return 'Problem: missing numeric id after /story/';
  }

  return null; // valid!
}

String _normalizeUrl(String raw) {
  // Trim, optionally force https + www if you prefer
  var v = raw.trim();
  // if (!v.startsWith('http')) v = 'https://$v';
  // v = v.replaceFirst('wattpad.com', 'www.wattpad.com'); // normalize host
  return v;
}

abstract class ScrapeStoryEvent {}

class UrlChanged extends ScrapeStoryEvent {
  final String url;

  UrlChanged(this.url);
}

class StartRequested extends ScrapeStoryEvent {
  StartRequested();
}

class CancelRequested extends ScrapeStoryEvent {
  CancelRequested();
}

/// Internal: when an SSE frame arrives
class SseFrameArrived extends ScrapeStoryEvent {
  final String name;
  final String data;

  SseFrameArrived(this.name, this.data);
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

/// Extract a human error message if present in the JSON body your server sends for `error`.
String? _extractErrorMessage(String data) {
  final m = _tryParseJsonMap(data);
  if (m == null) return null;
  // Your server sample:
  // { "step": "...", "error": { "error": "...", "message": "...", ... }, "status": "failed" }
  if (m['status'] == 'failed') {
    final err = m['error'];
    if (err is Map) {
      return (err['message'] ?? err['error'] ?? 'Operation failed').toString();
    }
    return 'Operation failed';
  }
  // Sometimes servers send: { "error": "...", "message": "..." }
  if (m.containsKey('message')) return m['message']?.toString();
  if (m.containsKey('error')) return m['error']?.toString();
  return null;
}

/// Extract the finished result if present
ScrapeStoryRes? _extractFinishedResult(String data) {
  try {
    final v = jsonDecode(data);
    final obj = (v is Map && v['ok'] == true && v['result'] is Map)
        ? v['result'] as Map<String, dynamic>
        : (v is Map<String, dynamic> ? v : null);
    if (obj == null) return null;
    return ScrapeStoryRes.fromJson(obj);
  } catch (_) {
    return null; // let caller mark done with null result
  }
}

class ScrapeStoryBloc extends Bloc<ScrapeStoryEvent, ScrapeStoryState> {
  AppApiDataSource api;
  StreamSubscription<ScrapeEvent>? _sseSub;

  ScrapeStoryRes? _lastResult; // <-- typed cache
  ScrapeStoryRes? get lastResult => _lastResult;

  Completer<ScrapeStoryRes?>? _doneCompleter; // <-- typed waiter

  Future<ScrapeStoryRes?> waitUntilDone({Duration? timeout}) {
    _doneCompleter ??= Completer<ScrapeStoryRes?>();
    if (timeout != null) {
      return _doneCompleter!.future.timeout(
        timeout,
        onTimeout: () => _lastResult,
      );
    }
    return _doneCompleter!.future;
  }

  void _resolveWaiter() {
    _doneCompleter?.complete(_lastResult);
    _doneCompleter = null;
  }

  ScrapeStoryBloc({required this.api}) : super(const ScrapeStoryState()) {
    on<StartRequested>(_onStart);
    on<CancelRequested>(_onCancel);

    // Every SSE chunk decoded upstream into name + data will be sent as SseFrameArrived
    on<SseFrameArrived>(_onSseFrame);

    on<UrlChanged>((e, emit) {
      final normalized = _normalizeUrl(e.url);
      final hint = _validateUrlMessage(normalized);
      emit(
        state.copyWith(
          url: normalized,
          urlHint: hint,
          clearError: true,
          clearResult: true,
        ),
      );
    });
  }

  Future<void> _onStart(
    StartRequested e,
    Emitter<ScrapeStoryState> emit,
  ) async {
    // ⬇️ Validate first
    final hint = _validateUrlMessage(state.url);
    if (hint != null) {
      emit(
        state.copyWith(
          status: ScrapeStatus.idle,
          urlHint: hint,
          errorMessage: hint,
        ),
      );
      return;
    }

    // cancel previous
    await _sseSub?.cancel();

    emit(
      state.copyWith(
        status: ScrapeStatus.connecting,
        events: const [],
        urlHint: null,
        clearError: true,
        clearResult: true,
      ),
    );

    // Start your SSE call; produce name + data strings
    // Example using your existing SSE code path:
    // final stream = sseClient.connect(url: state.url); // <-- build it
    // The stream should yield raw lines; parse into (eventName, data) pairs or do it inside the client.

    // Minimal pseudo:
    final stream = _startSseRequest(state.url);
    emit(state.copyWith(status: ScrapeStatus.streaming));
    _lastResult = null;

    _sseSub = stream.listen(
      (evt) => add(SseFrameArrived(evt.name, evt.payload)),
      onError: (err, st) {
        emit(
          state.copyWith(
            status: ScrapeStatus.error,
            errorMessage: err.toString(),
          ),
        );
        _resolveWaiter();
      },
      onDone: () {
        if (state.status != ScrapeStatus.error &&
            state.status != ScrapeStatus.done) {
          emit(state.copyWith(status: ScrapeStatus.idle));
          _resolveWaiter();
        }
      },
    );
  }

  Future<void> _onCancel(
    CancelRequested e,
    Emitter<ScrapeStoryState> emit,
  ) async {
    await _sseSub?.cancel();
    emit(state.copyWith(status: ScrapeStatus.idle));
    _resolveWaiter();
  }

  void _onSseFrame(SseFrameArrived e, Emitter<ScrapeStoryState> emit) {
    // 1) append to events list
    final nextEvents = List<ScrapeEvent>.from(state.events)
      ..add(ScrapeEvent(e.name, e.data));

    // 2) error detection
    if (e.name == 'error') {
      final msg = _extractErrorMessage(e.data) ?? 'Unknown error';
      emit(
        state.copyWith(
          status: ScrapeStatus.error,
          events: nextEvents,
          errorMessage: msg,
        ),
      );
      _resolveWaiter();

      return;
    }

    // 3) finished detection
    if (e.name == 'finished') {
      final result = _extractFinishedResult(e.data);
      _lastResult = result;

      if (result == null) {
        // Keep DONE status, but surface a parse error and keep result=null.
        emit(
          state.copyWith(
            status: ScrapeStatus.done,
            events: [
              ...nextEvents,
              // Optional: append a synthetic event so you can inspect the raw payload later
              ScrapeEvent('parse_error', 'Could not parse finished payload'),
              ScrapeEvent('finished_raw', e.data),
            ],
            result: null,
            errorMessage: 'Finished, but could not parse the story payload.',
          ),
        );
        _lastResult = null;
        _resolveWaiter();
        return;
      }

      emit(
        state.copyWith(
          status: ScrapeStatus.done,
          events: nextEvents,
          result: result,
        ),
      );
      _resolveWaiter();

      return;
    }

    // 4) otherwise just record
    emit(state.copyWith(events: nextEvents));
  }

  @override
  Future<void> close() {
    _sseSub?.cancel();
    return super.close();
  }

  // --------- You provide these two implementations ----------
  // A) Start the SSE request and return a stream of complete frames
  //    Either already parsed (name,data) or raw lines you will parse below.
  Stream<ScrapeEvent> _startSseRequest(String url) {
    // base stream from your API that yields SimpleEvent (or decode frames to SimpleEvent first)
    final base = api.streamScrapeStory(
      storyUrl: url,
      clearOutput: false,
    ); // Stream<SimpleEvent>

    // Fan-out combined payloads into separate events
    return base.asyncExpand((evt) async* {
      // Only needed if server sometimes puts multiple JSONs in one payload
      if (evt.name == 'log' || evt.name == 'error' || evt.name == 'info') {
        for (final piece in _splitNdjsonOrConcatenated(evt.payload)) {
          yield ScrapeEvent(evt.name, piece);
        }
      } else {
        yield evt;
      }
    });
  }

  // B) If your SSE client yields raw text, parse it to (name,data) per frame:
  (String, String)? _parseEventAndData(String raw) {
    // If you already parse in the client, delete this.
    // A complete SSE frame looks like multiple lines ending with a blank line.
    // For simplicity assume you've batched a frame into one `raw` string already:
    // event: foo\n
    // data: {...}\n
    // \n
    String? event;
    final dataLines = <String>[];
    for (final line in raw.split('\n')) {
      if (line.startsWith('event:')) {
        event = line.substring(6).trim();
      } else if (line.startsWith('data:')) {
        dataLines.add(line.substring(5).trimLeft());
      }
    }
    if (event == null) return null;
    final data = dataLines.join('\n');
    return (event, data);
  }

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
    // Splits like {"a":1}{"b":2} -> ["{\"a\":1}", "{\"b\":2}"]
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
