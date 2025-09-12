import 'package:bloc/bloc.dart';
import 'package:locallibrary/wattpad_publisher/datasource.dart';
import 'package:locallibrary/wattpad_publisher/models/server_models.dart';
import 'package:meta/meta.dart';

part 'story_event.dart';
part 'story_state.dart';

class StoryBloc extends Bloc<StoryEvent, StoryState> {
  final AppApiDataSource api;

  StoryBloc({required this.api}) : super(const StoryInitial()) {
    on<StoryRequested>(_onStoryRequested);
    on<StoriesPrefetchRequested>(_onPrefetch);
    on<StoryCleared>((_, emit) => emit(const StoryInitial()));
  }

  Future<void> _onStoryRequested(
      StoryRequested e,
      Emitter<StoryState> emit,
      ) async {
    // Cached?
    final cached = state.bundleFor(e.storyId);
    if (cached != null && !e.force) {
      emit(StoryLoaded(
        cached,
        bundles: state.bundles,
        loadingIds: state.loadingIds,
        errors: state.errors,
      ));
      return;
    }

    // mark loading for this id
    final loadingIds = {...state.loadingIds}..add(e.storyId);
    final errors = {...state.errors}..remove(e.storyId);
    emit(StoryLoading(bundles: state.bundles, loadingIds: loadingIds, errors: errors));

    try {
      final bundle = await api.getFullStoryInfo(e.storyId);
      final bundles = {...state.bundles}..[e.storyId] = bundle;
      loadingIds.remove(e.storyId);

      emit(StoryLoaded(
        bundle,
        bundles: bundles,
        loadingIds: loadingIds,
        errors: errors,
      ));
    } catch (err) {
      loadingIds.remove(e.storyId);
      final newErrors = {...errors}..[e.storyId] = err.toString();
      emit(StoryError(
        err.toString(),
        storyId: e.storyId,
        bundles: state.bundles,
        loadingIds: loadingIds,
        errors: newErrors,
      ));
    }
  }

  Future<void> _onPrefetch(
      StoriesPrefetchRequested e,
      Emitter<StoryState> emit,
      ) async {
    for (final id in e.storyIds) {
      add(StoryRequested(id));
    }
  }
}
