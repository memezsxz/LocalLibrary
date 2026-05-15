part of 'base_scrape_bloc.dart';

@immutable
abstract class BaseScrapeEvent {}

class InputChanged extends BaseScrapeEvent {
  final String v;

  InputChanged(this.v);
}

class StartRequested extends BaseScrapeEvent {}

class CancelRequested extends BaseScrapeEvent {}

class SseFrameArrived extends BaseScrapeEvent {
  final String name;
  final String data;

  SseFrameArrived(this.name, this.data);
}
