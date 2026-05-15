import 'package:flutter_bloc/flutter_bloc.dart';

import 'search_state.dart';

class SearchCubit extends Cubit<SearchState> {
  SearchCubit() : super(const SearchState());

  void setQuery(String query) => emit(state.copyWith(query: query));

  void setParams(AdvancedSearchParams params) =>
      emit(state.copyWith(params: params));

  void clearParams() =>
      emit(state.copyWith(params: const AdvancedSearchParams()));

  void clear() => emit(const SearchState());
}
