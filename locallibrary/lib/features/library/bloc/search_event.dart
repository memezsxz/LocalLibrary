import '../../../core/api/dto/filter_stories_params.dart';

sealed class SearchEvent {}

/// Trigger a fresh search (resets page offset to 0).
class SearchRequested extends SearchEvent {
  final FilterStoriesParams params;

  SearchRequested(this.params);
}

/// Load the next page using the same params as the last request.
class SearchLoadMore extends SearchEvent {}

/// Reset to initial state.
class SearchCleared extends SearchEvent {}
