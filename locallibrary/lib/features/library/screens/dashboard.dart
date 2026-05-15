import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../core/api/library_api_client.dart';
import '../../../dependency_injection.dart';
import '../cubit/search_cubit.dart';
import '../cubit/search_state.dart';
import '../widgets/advanced_search_dialog.dart';
import '../widgets/book_grid.dart';
import '../widgets/search_input_bar.dart';

class Dashboard extends StatelessWidget {
  const Dashboard({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => SearchCubit(),
      child: const _DashboardBody(),
    );
  }
}

class _DashboardBody extends StatelessWidget {
  const _DashboardBody();

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
            prev.hasActiveFilters != next.hasActiveFilters,
            builder: (context, state) =>
                SearchInputBar(
                  hasActiveFilters: state.hasActiveFilters,
                  onChanged: cubit.setQuery,
                  onAdvancedSearch: () =>
                      openAdvancedSearchDialog(
                        context: context,
                        initial: state.params,
                        onApply: cubit.setParams,
                      ),
                ),
          ),
        ),
        Expanded(
          child: BookGrid(
            fetch: (limit, offset) async {
              final stories = await sl<LibraryApiClient>()
                  .listStories(limit, offset);
              return stories.map((s) => s.storyId).toList();
            },
          ),
        ),
      ],
    );
  }
}