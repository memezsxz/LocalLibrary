part of 'story_bloc.dart';


@immutable
abstract class StoryState {
  /// Cache of loaded stories: storyId -> StoryBundle
  final Map<int, StoryBundle> bundles;

  /// Which stories are currently being fetched.
  final Set<int> loadingIds;

  /// Per-story error message (if last fetch failed).
  final Map<int, String> errors;

  const StoryState({
    required this.bundles,
    required this.loadingIds,
    required this.errors,
  });

  // convenience helpers
  bool isLoading(int id) => loadingIds.contains(id);
  String? errorFor(int id) => errors[id];
  StoryBundle? bundleFor(int id) => bundles[id];

  StoryState copyCore({
    Map<int, StoryBundle>? bundles,
    Set<int>? loadingIds,
    Map<int, String>? errors,
  });

  StoryBundle? getBundle(int storyId) => bundles[storyId];
}

class StoryInitial extends StoryState {
  const StoryInitial()
      : super(bundles: const {}, loadingIds: const {}, errors: const {});

  @override
  StoryState copyCore({Map<int, StoryBundle>? bundles, Set<int>? loadingIds, Map<int, String>? errors}) {
    return StoryInitial()
      .._ignore(); // not used; bloc will replace with concrete states
  }
  void _ignore() {}
}

class StoryLoading extends StoryState {
  const StoryLoading({
    required super.bundles,
    required super.loadingIds,
    required super.errors,
  });

  @override
  StoryLoading copyCore({Map<int, StoryBundle>? bundles, Set<int>? loadingIds, Map<int, String>? errors}) {
    return StoryLoading(
      bundles: bundles ?? this.bundles,
      loadingIds: loadingIds ?? this.loadingIds,
      errors: errors ?? this.errors,
    );
  }
}

class StoryLoaded extends StoryState {
  final StoryBundle bundle; // the most recently loaded one (still keeps the whole cache)
  const StoryLoaded(
      this.bundle, {
        required super.bundles,
        required super.loadingIds,
        required super.errors,
      });

  @override
  StoryLoaded copyCore({Map<int, StoryBundle>? bundles, Set<int>? loadingIds, Map<int, String>? errors}) {
    return StoryLoaded(
      bundle,
      bundles: bundles ?? this.bundles,
      loadingIds: loadingIds ?? this.loadingIds,
      errors: errors ?? this.errors,
    );
  }
}

class StoryError extends StoryState {
  final String message;     // the most recent error
  final int storyId;        // which id failed
  const StoryError(
      this.message, {
        required this.storyId,
        required super.bundles,
        required super.loadingIds,
        required super.errors,
      });

  @override
  StoryError copyCore({Map<int, StoryBundle>? bundles, Set<int>? loadingIds, Map<int, String>? errors}) {
    return StoryError(
      message,
      storyId: storyId,
      bundles: bundles ?? this.bundles,
      loadingIds: loadingIds ?? this.loadingIds,
      errors: errors ?? this.errors,
    );
  }
}
