part of 'story_bloc.dart';

@immutable
sealed class StoryEvent {
  const StoryEvent();
}

/// Fetch one story; uses cache unless [force] is true.
class StoryRequested extends StoryEvent {
  final int storyId;
  final bool force;
  const StoryRequested(this.storyId, {this.force = false});
}

/// Warm the cache with many IDs (each goes through StoryRequested).
class StoriesPrefetchRequested extends StoryEvent {
  final List<int> storyIds;
  const StoriesPrefetchRequested(this.storyIds);
}

/// Optional: clear all cache & errors.
class StoryCleared extends StoryEvent {
  const StoryCleared();
}
