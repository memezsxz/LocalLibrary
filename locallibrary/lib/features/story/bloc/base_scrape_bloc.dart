import 'dart:async';

import 'package:bloc/bloc.dart';

import '../models/logs.dart';
import 'base_scrape_event.dart';
import 'base_scrape_state.dart';

typedef ErrorExtractor = String? Function(String json);
typedef FinishedParser<TRes> = TRes? Function(String json);
typedef StreamStarter = Stream<ScrapeEvent>;

abstract class BaseScrapeBloc<TRes>
    extends Bloc<BaseScrapeEvent, BaseScrapeState<TRes>> {
  BaseScrapeBloc({
    required this.startStream,
    required this.validateInput,
    required this.parseFinished,
    required this.extractError,
  }) : super(BaseScrapeState<TRes>()) {
    on<InputChanged>(_onInputChanged);
    on<StartRequested>(_onStart);
    on<CancelRequested>(_onCancel);
    on<SseFrameArrived>(_onSseFrame);
  }

  final StreamStarter Function(String input) startStream;
  final String? Function(String input) validateInput;
  final FinishedParser<TRes> parseFinished;
  final ErrorExtractor extractError;

  StreamSubscription<ScrapeEvent>? _sseSub;
  TRes? _lastResult;
  Completer<TRes?>? _done;

  Future<TRes?> waitUntilDone({Duration? timeout}) {
    _done ??= Completer<TRes?>();
    if (timeout != null) {
      return _done!.future.timeout(timeout, onTimeout: () => _lastResult);
    }
    return _done!.future;
  }

  void _resolve() {
    _done?.complete(_lastResult);
    _done = null;
  }

  void reset() {
    _sseSub?.cancel();
    _sseSub = null;
    _done?.complete(null);
    _done = null;
    emit(BaseScrapeState<TRes>());
  }

  void _onInputChanged(InputChanged e, Emitter<BaseScrapeState<TRes>> emit) {
    final norm = e.v.trim(); // or your custom normalizer
    emit(
      state.copyWith(
        input: norm,
        inputHint: validateInput(norm),
        clearError: true,
        clearResult: true,
      ),
    );
  }

  Future<void> _onStart(
    StartRequested e,
    Emitter<BaseScrapeState<TRes>> emit,
  ) async {
    final hint = validateInput(state.input);
    if (hint != null) {
      emit(
        state.copyWith(
          status: ScrapeStatus.idle,
          inputHint: hint,
          errorMessage: hint,
        ),
      );
      return;
    }

    await _sseSub?.cancel();
    emit(
      state.copyWith(
        status: ScrapeStatus.connecting,
        events: const [],
        inputHint: null,
        clearError: true,
        clearResult: true,
      ),
    );

    final stream = startStream(state.input);
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
        _resolve();
      },
      onDone: () {
        if (state.status != ScrapeStatus.error &&
            state.status != ScrapeStatus.done) {
          emit(state.copyWith(status: ScrapeStatus.idle));
          _resolve();
        }
      },
    );
  }

  Future<void> _onCancel(
    CancelRequested e,
    Emitter<BaseScrapeState<TRes>> emit,
  ) async {
    await _sseSub?.cancel();
    emit(state.copyWith(status: ScrapeStatus.idle));
    _resolve();
  }

  void _onSseFrame(SseFrameArrived e, Emitter<BaseScrapeState<TRes>> emit) {
    final next = List<ScrapeEvent>.from(state.events)
      ..add(ScrapeEvent(e.name, e.data));

    if (e.name.contains("error")) {
      final msg = extractError(e.data) ?? 'Unknown error';
      emit(
        state.copyWith(
          status: ScrapeStatus.error,
          events: next,
          errorMessage: msg,
        ),
      );
      _resolve();
      return;
    }

    if (e.name == 'finished') {
      final res = parseFinished(e.data);
      _lastResult = res;

      if (res == null) {
        emit(
          state.copyWith(
            status: ScrapeStatus.done,
            events: [
              ...next,
              ScrapeEvent('parse_error', 'Could not parse finished payload'),
              ScrapeEvent('finished_raw', e.data),
            ],
            errorMessage: 'Finished, but could not parse payload.',
            result: null,
          ),
        );
        _lastResult = null;
        _resolve();
        return;
      }

      emit(
        state.copyWith(status: ScrapeStatus.done, events: next, result: res),
      );
      _resolve();
      return;
    }

    emit(state.copyWith(events: next));
  }

  @override
  Future<void> close() {
    _sseSub?.cancel();
    return super.close();
  }
}

