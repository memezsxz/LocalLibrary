import 'package:equatable/equatable.dart';

import '../../../core/api/dto/filter_stories_params.dart';

// ─── Search params model ──────────────────────────────────────────────────────

enum SearchInclude { stories, parts, comments }

class AdvancedSearchParams extends Equatable {
  const AdvancedSearchParams({
    this.languages = const {},
    this.genreIds = const {},
    this.tagIds = const {},
    this.orderBy,
    this.include = const {SearchInclude.stories},
  });

  final Set<String> languages;
  final Set<int> genreIds;
  final Set<int> tagIds;
  final String? orderBy;
  final Set<SearchInclude> include;

  bool get isDefault =>
      languages.isEmpty &&
      genreIds.isEmpty &&
      tagIds.isEmpty &&
      orderBy == null &&
      include.length == 1 &&
      include.contains(SearchInclude.stories);

  AdvancedSearchParams copyWith({
    Set<String>? languages,
    Set<int>? genreIds,
    Set<int>? tagIds,
    String? orderBy,
    bool clearOrderBy = false,
    Set<SearchInclude>? include,
  }) {
    return AdvancedSearchParams(
      languages: languages ?? this.languages,
      genreIds: genreIds ?? this.genreIds,
      tagIds: tagIds ?? this.tagIds,
      orderBy: clearOrderBy ? null : orderBy ?? this.orderBy,
      include: include ?? this.include,
    );
  }

  @override
  List<Object?> get props => [languages, genreIds, tagIds, orderBy, include];
}

// ─── Cubit state ─────────────────────────────────────────────────────────────

class SearchState extends Equatable {
  const SearchState({
    this.query = '',
    this.params = const AdvancedSearchParams(),
  });

  final String query;
  final AdvancedSearchParams params;

  bool get hasActiveFilters => !params.isDefault;

  FilterStoriesParams toFilterParams({int pageOffset = 0, int pageLimit = 20}) {
    return FilterStoriesParams(
      query: query,
      pageOffset: pageOffset,
      pageLimit: pageLimit,
      orderBy: params.orderBy ?? '',
      includeStories: params.include.contains(SearchInclude.stories),
      includeParts: params.include.contains(SearchInclude.parts),
      includeComments: params.include.contains(SearchInclude.comments),
      languages: params.languages.toList(),
      genres: params.genreIds.toList(),
      tags: params.tagIds.toList(),
    );
  }

  SearchState copyWith({String? query, AdvancedSearchParams? params}) {
    return SearchState(
      query: query ?? this.query,
      params: params ?? this.params,
    );
  }

  @override
  List<Object?> get props => [query, params];
}
