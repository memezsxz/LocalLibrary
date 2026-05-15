import 'package:bloc/bloc.dart';
import 'package:locallibrary/core/datasource.dart';
import 'package:meta/meta.dart';

import '../../story/models/story_dto.dart';

@immutable
sealed class PartEvent {
  const PartEvent();
}

class PartFetchRequested extends PartEvent {
  final int storyId;
  final int partId;                 // initial part
  final List<int>? sequence;        // optional full list of part IDs for next/prev
  const PartFetchRequested({required this.storyId, required this.partId, this.sequence});
}

class PartLoadNextRequested extends PartEvent {
  const PartLoadNextRequested();
}

class PartDataProvided extends PartEvent {
  final PartFullInfo info;

  const PartDataProvided(this.info);
}

// STATES
@immutable
sealed class PartState {
  const PartState();
}

class PartInitial extends PartState {
  const PartInitial();
}

class PartLoading extends PartState {
  const PartLoading();
}

class PartLoaded extends PartState {
  final PartFullInfo info;
  const PartLoaded(this.info);
}

class PartError extends PartState {
  final String message;
  const PartError(this.message);
}

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
