import '../models/logs.dart';

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
    this.input =
        'https://www.wattpad.com/story/149595841-%D8%AA%D9%81%D8%A7%D8%AD%D8%A9-%D8%A7%D9%84%D8%B2%D9%85%D8%B1%D8%AF', // TODO: remove after done testing scraping, set back to ''
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