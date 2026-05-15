// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'tag_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

Tag _$TagFromJson(Map<String, dynamic> json) => Tag(
  tagId: (json['tag_id'] as num).toInt(),
  name: json['name'] as String,
  createdAt: DateTime.parse(json['created_at'] as String),
  updatedAt: DateTime.parse(json['updated_at'] as String),
);

Map<String, dynamic> _$TagToJson(Tag instance) => <String, dynamic>{
  'tag_id': instance.tagId,
  'name': instance.name,
  'created_at': instance.createdAt.toIso8601String(),
  'updated_at': instance.updatedAt.toIso8601String(),
};

StoryTag _$StoryTagFromJson(Map<String, dynamic> json) => StoryTag(
  storyId: (json['story_id'] as num).toInt(),
  tagId: (json['tag_id'] as num).toInt(),
);

Map<String, dynamic> _$StoryTagToJson(StoryTag instance) => <String, dynamic>{
  'story_id': instance.storyId,
  'tag_id': instance.tagId,
};
