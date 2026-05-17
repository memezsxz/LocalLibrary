// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'filter_stories_params.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

FilterStoriesParams _$FilterStoriesParamsFromJson(Map<String, dynamic> json) =>
    FilterStoriesParams(
      pageOffset: (json['page_offset'] as num?)?.toInt() ?? 0,
      pageLimit: (json['page_limit'] as num?)?.toInt() ?? 20,
      query: json['query'] as String? ?? '',
      orderBy: json['order_by'] as String? ?? '',
      includeStories: json['include_stories'] as bool? ?? true,
      includeParts: json['include_parts'] as bool? ?? false,
      includeComments: json['include_comments'] as bool? ?? false,
      isDeleted: json['is_deleted'] as bool? ?? false,
      languages:
          (json['languages'] as List<dynamic>?)
              ?.map((e) => e as String)
              .toList() ??
          const [],
      genres:
          (json['genres'] as List<dynamic>?)
              ?.map((e) => (e as num).toInt())
              .toList() ??
          const [],
      tags:
          (json['tags'] as List<dynamic>?)
              ?.map((e) => (e as num).toInt())
              .toList() ??
          const [],
    );

Map<String, dynamic> _$FilterStoriesParamsToJson(
  FilterStoriesParams instance,
) => <String, dynamic>{
  'page_offset': instance.pageOffset,
  'page_limit': instance.pageLimit,
  'query': instance.query,
  'order_by': instance.orderBy,
  'include_stories': instance.includeStories,
  'include_parts': instance.includeParts,
  'include_comments': instance.includeComments,
  'is_deleted': instance.isDeleted,
  'languages': instance.languages,
  'genres': instance.genres,
  'tags': instance.tags,
};
