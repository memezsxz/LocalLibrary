part of 'base_scrape_bloc.dart';

enum ScrapeStatus { idle, connecting, streaming, done, error }

class BaseScrapeState<TRes> {
  final ScrapeStatus status;
  final String input; // url or id, up to the subclass
  final String? errorMessage;
  final String? inputHint;
  final List<ScrapeEvent> events;
  final TRes? result;

  const BaseScrapeState({
    this.status = ScrapeStatus.idle,
    this.input = '',
    this.errorMessage,
    this.inputHint,
    this.events = const [],
    this.result,
  });

  BaseScrapeState<TRes> copyWith({
    ScrapeStatus? status,
    String? input,
    String? errorMessage,
    String? inputHint,
    List<ScrapeEvent>? events,
    TRes? result,
    bool clearError = false,
    bool clearResult = false,
  }) {
    return BaseScrapeState<TRes>(
      status: status ?? this.status,
      input: input ?? this.input,
      errorMessage: clearError ? null : (errorMessage ?? this.errorMessage),
      inputHint: inputHint ?? this.inputHint,
      events: events ?? this.events,
      result: clearResult ? null : (result ?? this.result),
    );
  }
}
