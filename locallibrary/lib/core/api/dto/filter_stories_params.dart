import 'package:json_annotation/json_annotation.dart';

part 'filter_stories_params.g.dart';

@JsonSerializable(fieldRename: FieldRename.snake)
class FilterStoriesParams {
  final int pageOffset;
  final int pageLimit;
  final String query;
  final String orderBy;
  final bool includeStories;
  final bool includeParts;
  final bool includeComments;
  final bool isDeleted;
  final List<String> languages;
  final List<int> genres;
  final List<int> tags;

  const FilterStoriesParams({
    this.pageOffset = 0,
    this.pageLimit = 20,
    this.query = '',
    this.orderBy = '',
    this.includeStories = true,
    this.includeParts = false,
    this.includeComments = false,
    this.isDeleted = false,
    this.languages = const [],
    this.genres = const [],
    this.tags = const [],
  });

  FilterStoriesParams copyWith({
    int? pageOffset,
    int? pageLimit,
    String? query,
    String? orderBy,
    bool? includeStories,
    bool? includeParts,
    bool? includeComments,
    bool? isDeleted,
    List<String>? languages,
    List<int>? genres,
    List<int>? tags,
  }) {
    return FilterStoriesParams(
      pageOffset: pageOffset ?? this.pageOffset,
      pageLimit: pageLimit ?? this.pageLimit,
      query: query ?? this.query,
      orderBy: orderBy ?? this.orderBy,
      includeStories: includeStories ?? this.includeStories,
      includeParts: includeParts ?? this.includeParts,
      includeComments: includeComments ?? this.includeComments,
      isDeleted: isDeleted ?? this.isDeleted,
      languages: languages ?? this.languages,
      genres: genres ?? this.genres,
      tags: tags ?? this.tags,
    );
  }

  factory FilterStoriesParams.fromJson(Map<String, dynamic> json) =>
      _$FilterStoriesParamsFromJson(json);

  Map<String, dynamic> toJson() => _$FilterStoriesParamsToJson(this);
}
