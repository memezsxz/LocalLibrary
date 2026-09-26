import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../core/api/library_api_client.dart';
import '../../../core/common/widgets/page_header.dart';
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
  // The GridView beneath (BookGrid / SearchResultGrid) pads itself by this
  // much on every side — the header and search bar match it here so their
  // text and the grid's cards share one left edge.
  static const double _gridInset = 10;

  Timer? _debounce;

  // Defaults shown immediately; overwritten once the real fetch below
  // resolves. Keeps the header non-blank instead of hiding the subtitle
  // while loading (or if the fetch never succeeds).
  int _totalCount = 148;
  int _inProgressCount = 12;

  @override
  void initState() {
    super.initState();
    _loadCounts();
  }

  Future<void> _loadCounts() async {
    final api = sl<LibraryApiClient>();
    try {
      final books = await api.listStories(500, 0);
      if (!mounted) return;
      setState(() {
        _totalCount = books.length;
        _inProgressCount = books.where((b) {
          final p = b.storyProgress?.progress;
          return p != null && p > 0 && p < 1;
        }).length;
      });
    } catch (e) {
      // Keeps the defaults above on failure.
      debugPrint('[Dashboard] failed to load book counts: $e');
    }
  }

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
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(
            _gridInset,
            _gridInset,
            _gridInset,
            10,
          ),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Expanded(
                flex: 3,
                child: PageHeader(
                  title: 'Your Library',
                  subtitle:
                  '$_totalCount books · $_inProgressCount in progress',
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                flex: 2,
                child: BlocBuilder<SearchCubit, SearchState>(
                  buildWhen: (prev, next) =>
                  prev.hasActiveFilters != next.hasActiveFilters ||
                      prev.query.isEmpty != next.query.isEmpty,
                  builder: (ctx, state) =>
                      SearchInputBar(
                        hasActiveFilters: state.hasActiveFilters,
                        showClear:
                        state.hasActiveFilters || state.query.isNotEmpty,
                        onChanged: (q) {
                          cubit.setQuery(q);
                          _triggerSearch();
                        },
                        onClear: () {
                          cubit.clear();
                          context.read<SearchBloc>().add(SearchCleared());
                        },
                        onAdvancedSearch: () =>
                            openAdvancedSearchDialog(
                              context: ctx,
                              initial: context
                                  .read<SearchCubit>()
                                  .state
                                  .params,
                              onApply: (params) {
                                cubit.setParams(params);
                                _triggerSearch(immediate: true);
                              },
                            ),
                      ),
                ),
              ),
            ],
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
