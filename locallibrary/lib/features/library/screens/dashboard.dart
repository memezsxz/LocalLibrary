import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../core/api/library_api_client.dart';
import '../../../dependency_injection.dart';
import '../bloc/search_bloc.dart';
import '../bloc/search_event.dart';
import '../cubit/search_cubit.dart';
import '../cubit/search_state.dart';
import '../widgets/advanced_search_dialog.dart';
import '../widgets/book_grid.dart';
import '../widgets/search_input_bar.dart';
import '../widgets/search_result_grid.dart';

class Dashboard extends StatelessWidget {
  const Dashboard({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider.value(value: sl<SearchCubit>()),
        BlocProvider.value(value: sl<SearchBloc>()),
      ],
      child: const _DashboardBody(),
    );
  }
}

class _DashboardBody extends StatefulWidget {
  const _DashboardBody();

  @override
  State<_DashboardBody> createState() => _DashboardBodyState();
}

class _DashboardBodyState extends State<_DashboardBody> {
  Timer? _debounce;

  @override
  void dispose() {
    _debounce?.cancel();
    super.dispose();
  }

  void _triggerSearch({bool immediate = false}) {
    _debounce?.cancel();
    void fn() {
      if (!mounted) return;
      final s = context.read<SearchCubit>().state;
      if (s.query.isEmpty && !s.hasActiveFilters) {
        context.read<SearchBloc>().add(SearchCleared());
        return;
      }
      context.read<SearchBloc>().add(SearchRequested(s.toFilterParams()));
    }

    if (immediate) {
      fn();
    } else {
      _debounce = Timer(const Duration(milliseconds: 400), fn);
    }
  }

  @override
  Widget build(BuildContext context) {
    final cubit = context.read<SearchCubit>();

    return Column(
      spacing: 10,
      children: [
        Padding(
          padding: const EdgeInsets.only(bottom: 5),
          child: BlocBuilder<SearchCubit, SearchState>(
            buildWhen: (prev, next) =>
                prev.hasActiveFilters != next.hasActiveFilters ||
                prev.query.isEmpty != next.query.isEmpty,
            builder: (ctx, state) => SearchInputBar(
              hasActiveFilters: state.hasActiveFilters,
              showClear: state.hasActiveFilters || state.query.isNotEmpty,
              onChanged: (q) {
                cubit.setQuery(q);
                _triggerSearch();
              },
              onClear: () {
                cubit.clear();
                context.read<SearchBloc>().add(SearchCleared());
              },
              onAdvancedSearch: () => openAdvancedSearchDialog(
                context: ctx,
                initial: context.read<SearchCubit>().state.params,
                onApply: (params) {
                  cubit.setParams(params);
                  _triggerSearch(immediate: true);
                },
              ),
            ),
          ),
        ),
        Expanded(
          child: BlocBuilder<SearchCubit, SearchState>(
            buildWhen: (prev, next) =>
                (prev.query.isEmpty) != (next.query.isEmpty) ||
                prev.hasActiveFilters != next.hasActiveFilters,
            builder: (_, state) {
              if (state.query.isEmpty && !state.hasActiveFilters) {
                return BookGrid(
                  fetch: (limit, offset) =>
                      sl<LibraryApiClient>().listStories(limit, offset),
                );
              }
              return const SearchResultGrid();
            },
          ),
        ),
      ],
    );
  }
}
