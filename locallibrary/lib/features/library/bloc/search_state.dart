import 'package:meta/meta.dart';

import '../../../core/api/dto/filter_stories_params.dart';
import '../../../features/story/models/domain/book_cover_model.dart';

@immutable
sealed class SearchResultState {
  final List<BookMinimal> results;
  final FilterStoriesParams? lastParams;

  /// True when the last page returned a full page — more may exist.
  final bool hasMore;

  const SearchResultState({
    required this.results,
    required this.lastParams,
    required this.hasMore,
  });

  SearchResultState copyCore({
    List<BookMinimal>? results,
    FilterStoriesParams? lastParams,
    bool? hasMore,
  });
}

class SearchResultInitial extends SearchResultState {
  const SearchResultInitial()
    : super(results: const [], lastParams: null, hasMore: false);

  @override
  SearchResultInitial copyCore({
    List<BookMinimal>? results,
    FilterStoriesParams? lastParams,
    bool? hasMore,
  }) => const SearchResultInitial();
}

class SearchResultLoading extends SearchResultState {
  const SearchResultLoading({
    required super.results,
    required super.lastParams,
    required super.hasMore,
  });

  @override
  SearchResultLoading copyCore({
    List<BookMinimal>? results,
    FilterStoriesParams? lastParams,
    bool? hasMore,
  }) {
    return SearchResultLoading(
      results: results ?? this.results,
      lastParams: lastParams ?? this.lastParams,
      hasMore: hasMore ?? this.hasMore,
    );
  }
}

class SearchResultLoaded extends SearchResultState {
  const SearchResultLoaded({
    required super.results,
    required super.lastParams,
    required super.hasMore,
  });

  @override
  SearchResultLoaded copyCore({
    List<BookMinimal>? results,
    FilterStoriesParams? lastParams,
    bool? hasMore,
  }) {
    return SearchResultLoaded(
      results: results ?? this.results,
      lastParams: lastParams ?? this.lastParams,
      hasMore: hasMore ?? this.hasMore,
    );
  }
}

class SearchResultError extends SearchResultState {
  final String message;

  const SearchResultError({
    required this.message,
    required super.results,
    required super.lastParams,
    required super.hasMore,
  });

  @override
  SearchResultError copyCore({
    List<BookMinimal>? results,
    FilterStoriesParams? lastParams,
    bool? hasMore,
  }) {
    return SearchResultError(
      message: message,
      results: results ?? this.results,
      lastParams: lastParams ?? this.lastParams,
      hasMore: hasMore ?? this.hasMore,
    );
  }
}
