import 'package:bloc/bloc.dart';
import 'package:locallibrary/core/datasource.dart';

import 'part_event.dart';
import 'part_state.dart';

export 'part_event.dart';
export 'part_state.dart';

class PartBloc extends Bloc<PartEvent, PartState> {
  final AppApiDataSource api;

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
      final info = await api.getFullPartInfo(
        storyId: event.storyId,
        partId: event.partId,
      );
      emit(PartLoaded(info));
    } catch (e) {
      emit(PartError(e.toString()));
    }
  }
}
