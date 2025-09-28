part of 'scrape_part_bloc.dart';

@immutable
sealed class ScrapePartEvent extends BaseScrapeState {}

// 1) Custom events (extend BaseScrapeEvent)
class StartScraping extends ScrapePartEvent {
  final int storyId;
  final String url;

  StartScraping({required this.storyId, required this.url});
}
