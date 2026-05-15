// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'story_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

Story _$StoryFromJson(Map<String, dynamic> json) => Story(
  storyId: (json['story_id'] as num).toInt(),
  wattId: json['watt_id'] as String,
  authorId: (json['author_id'] as num).toInt(),
  title: json['title'] as String,
  description: json['description'] as String,
  genreId: (json['genre_id'] as num).toInt(),
  imageId: (json['image_id'] as num?)?.toInt(),
  isDeleted: json['is_deleted'] as bool,
  isFamilyFriendly: json['is_family_friendly'] as bool,
  isFree: json['is_free'] as bool,
  language: json['language'] as String,
  url: json['url'] as String?,
  ageRange: json['age_range'] as String,
  dateCreated: json['date_created'] == null
      ? null
      : DateTime.parse(json['date_created'] as String),
  dateModified: json['date_modified'] == null
      ? null
      : DateTime.parse(json['date_modified'] as String),
  datePublished: json['date_published'] == null
      ? null
      : DateTime.parse(json['date_published'] as String),
  createdAt: DateTime.parse(json['created_at'] as String),
  updatedAt: DateTime.parse(json['updated_at'] as String),
);

Map<String, dynamic> _$StoryToJson(Story instance) => <String, dynamic>{
  'story_id': instance.storyId,
  'watt_id': instance.wattId,
  'author_id': instance.authorId,
  'title': instance.title,
  'description': instance.description,
  'genre_id': instance.genreId,
  'image_id': instance.imageId,
  'is_deleted': instance.isDeleted,
  'is_family_friendly': instance.isFamilyFriendly,
  'is_free': instance.isFree,
  'language': instance.language,
  'url': instance.url,
  'age_range': instance.ageRange,
  'date_created': instance.dateCreated?.toIso8601String(),
  'date_modified': instance.dateModified?.toIso8601String(),
  'date_published': instance.datePublished?.toIso8601String(),
  'created_at': instance.createdAt.toIso8601String(),
  'updated_at': instance.updatedAt.toIso8601String(),
};
