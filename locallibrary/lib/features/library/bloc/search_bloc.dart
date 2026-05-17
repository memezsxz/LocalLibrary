import 'package:bloc/bloc.dart';

import '../../../core/api/library_api_client.dart';
import 'search_event.dart';
import 'search_state.dart';

class SearchBloc extends Bloc<SearchEvent, SearchResultState> {
  final LibraryApiClient api;

  SearchBloc({required this.api}) : super(const SearchResultInitial()) {
    on<SearchRequested>(_onSearchRequested);
    on<SearchLoadMore>(_onSearchLoadMore);
    on<SearchCleared>((_, emit) => emit(const SearchResultInitial()));
  }

  Future<void> _onSearchRequested(
    SearchRequested event,
    Emitter<SearchResultState> emit,
  ) async {
    emit(
      SearchResultLoading(
        results: const [],
        lastParams: event.params,
        hasMore: false,
      ),
    );

    try {
      final results = await api.searchFilter(event.params);
      emit(
        SearchResultLoaded(
          results: results,
          lastParams: event.params,
          hasMore: results.length >= event.params.pageLimit,
        ),
      );
    } catch (e) {
      emit(
        SearchResultError(
          message: e.toString(),
          results: const [],
          lastParams: event.params,
          hasMore: false,
        ),
      );
    }
  }

  Future<void> _onSearchLoadMore(
    SearchLoadMore event,
    Emitter<SearchResultState> emit,
  ) async {
    final last = state.lastParams;
    if (last == null || !state.hasMore || state is SearchResultLoading) return;

    final nextParams = last.copyWith(
      pageOffset: last.pageOffset + last.pageLimit,
    );

    emit(state.copyCore(lastParams: nextParams));

    try {
      final newPage = await api.searchFilter(nextParams);
      emit(
        SearchResultLoaded(
          results: [...state.results, ...newPage],
          lastParams: nextParams,
          hasMore: newPage.length >= nextParams.pageLimit,
        ),
      );
    } catch (e) {
      emit(
        SearchResultError(
          message: e.toString(),
          results: state.results,
          lastParams: nextParams,
          hasMore: false,
        ),
      );
    }
  }
}
