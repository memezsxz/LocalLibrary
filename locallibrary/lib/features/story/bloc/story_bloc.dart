import 'package:bloc/bloc.dart';
import 'package:locallibrary/core/datasource.dart';
import 'package:meta/meta.dart';

import '../models/story_dto.dart';
import '../models/story_models.dart';

part 'story_event.dart';
part 'story_state.dart';

class StoryBloc extends Bloc<StoryEvent, StoryState> {
  final AppApiDataSource api;

  StoryBloc({required this.api}) : super(const StoryInitial()) {
    on<StoryRequested>(_onStoryRequested);
    on<StoriesPrefetchRequested>(_onPrefetch);
    on<StoryCleared>((_, emit) => emit(const StoryInitial()));
    on<StoryCurrentPartChanged>(_onCurrentPartChanged);
  }

  Future<void> _onStoryRequested(StoryRequested e,
      Emitter<StoryState> emit,) async {
    // Cached?
    final cached = state.bundleFor(e.storyId);
    if (cached != null && !e.force) {
      emit(
        StoryLoaded(
          cached,
          bundles: state.bundles,
          loadingIds: state.loadingIds,
          errors: state.errors,
        ),
      );
      return;
    }

    // mark loading for this id
    final loadingIds = {...state.loadingIds}..add(e.storyId);
    final errors = {...state.errors}..remove(e.storyId);
    emit(
      StoryLoading(
        bundles: state.bundles,
        loadingIds: loadingIds,
        errors: errors,
      ),
    );

    try {
      final bundle = await api.getFullStoryInfo(e.storyId);
      final bundles = {...state.bundles}..[e.storyId] = bundle;
      loadingIds.remove(e.storyId);

      emit(
        StoryLoaded(
          bundle,
          bundles: bundles,
          loadingIds: loadingIds,
          errors: errors,
        ),
      );
    } catch (err) {
      loadingIds.remove(e.storyId);
      final newErrors = {...errors}..[e.storyId] = err.toString();
      emit(
        StoryError(
          err.toString(),
          storyId: e.storyId,
          bundles: state.bundles,
          loadingIds: loadingIds,
          errors: newErrors,
        ),
      );
    }
  }

  Future<void> _onPrefetch(StoriesPrefetchRequested e,
      Emitter<StoryState> emit,) async {
    for (final id in e.storyIds) {
      add(StoryRequested(id));
    }
  }

  void _onCurrentPartChanged(
    StoryCurrentPartChanged e,
    Emitter<StoryState> emit,
  ) {
    final existing = state.bundleFor(e.storyId);
    if (existing == null) return;
    final updated = existing.copyWith(currentPart: e.part);
    final bundles = {...state.bundles}..[e.storyId] = updated;
    emit(state.copyCore(bundles: bundles));
  }
}
