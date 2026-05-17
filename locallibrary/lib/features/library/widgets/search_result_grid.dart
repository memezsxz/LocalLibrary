import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:locallibrary/features/story/models/enum/book_size.dart';

import '../../../dependency_injection.dart';
import '../../settings/cubit/settings_cubit.dart';
import '../bloc/search_bloc.dart';
import '../bloc/search_event.dart';
import '../bloc/search_state.dart';
import 'book_cover_card.dart';

class SearchResultGrid extends StatefulWidget {
  const SearchResultGrid({super.key});

  @override
  State<SearchResultGrid> createState() => _SearchResultGridState();
}

class _SearchResultGridState extends State<SearchResultGrid> {
  final _scroll = ScrollController();

  @override
  void initState() {
    super.initState();
    _scroll.addListener(_onScroll);
  }

  @override
  void dispose() {
    _scroll.dispose();
    super.dispose();
  }

  void _onScroll() {
    if (_scroll.position.extentAfter < 600) {
      context.read<SearchBloc>().add(SearchLoadMore());
    }
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<SearchBloc, SearchResultState>(
      builder: (context, state) {
        if (state is SearchResultInitial) {
          return const SizedBox.shrink();
        }

        if (state is SearchResultLoading && state.results.isEmpty) {
          return const Center(child: CircularProgressIndicator());
        }

        if (state is SearchResultError && state.results.isEmpty) {
          return Center(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(state.message),
                const SizedBox(height: 8),
                TextButton(
                  onPressed: () => context.read<SearchBloc>().add(
                    SearchRequested(state.lastParams!),
                  ),
                  child: const Text('Retry'),
                ),
              ],
            ),
          );
        }

        final books = state.results;

        if (books.isEmpty) {
          return const Center(child: Text('No results found'));
        }

        final isLoadingMore =
            state is SearchResultLoading || state is SearchResultError;
        final bookSize = sl<SettingsCubit>().state.bookSize;

        return GridView.builder(
          controller: _scroll,
          padding: const EdgeInsets.all(10),
          physics: const AlwaysScrollableScrollPhysics(),
          gridDelegate: SliverGridDelegateWithMaxCrossAxisExtent(
            maxCrossAxisExtent: bookSize.maxExtent(),
            childAspectRatio: 0.6,
            crossAxisSpacing: 8,
            mainAxisSpacing: 8,
          ),
          itemCount: books.length + (isLoadingMore && state.hasMore ? 1 : 0),
          itemBuilder: (context, i) {
            if (i >= books.length) {
              return const Center(child: CircularProgressIndicator());
            }
            return BookCoverCard.fromBook(book: books[i]);
          },
        );
      },
    );
  }
}
