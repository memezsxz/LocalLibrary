import 'package:bloc/bloc.dart';

import '../../../core/api/story_api_client.dart';
import 'part_event.dart';
import 'part_state.dart';

export 'part_event.dart';
export 'part_state.dart';

class PartBloc extends Bloc<PartEvent, PartState> {
  final StoryApiClient api;

  PartBloc({required this.api}) : super(const PartInitial()) {
    on<PartFetchRequested>(_onFetch);
    on<PartDataProvided>((e, emit) => emit(PartLoaded(e.info)));
  }

  Future<void> _onFetch(
      PartFetchRequested event,
      Emitter<PartState> emit,
      ) async {
    emit(const PartLoading());
    try {
      final info = await api.getFullPartInfo(event.storyId, event.partId);
      emit(PartLoaded(info));
    } catch (e) {
      emit(PartError(e.toString()));
    }
  }
}
