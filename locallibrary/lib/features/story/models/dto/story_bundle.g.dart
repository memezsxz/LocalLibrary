// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'story_bundle.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

StoryBundle _$StoryBundleFromJson(Map<String, dynamic> json) => StoryBundle(
  story: Story.fromJson(json['story'] as Map<String, dynamic>),
  image: json['medium'] == null
      ? null
      : Media.fromJson(json['medium'] as Map<String, dynamic>),
  genre: Genre.fromJson(json['genre'] as Map<String, dynamic>),
  author: Author.fromJson(json['author'] as Map<String, dynamic>),
  storyProgress: StoryProgress.fromJson(
    json['story_progress'] as Map<String, dynamic>,
  ),
  currentPart: json['current_part'] == null
      ? null
      : Part.fromJson(json['current_part'] as Map<String, dynamic>),
  parts: (json['parts'] as List<dynamic>)
      .map((e) => Part.fromJson(e as Map<String, dynamic>))
      .toList(),
  tags: (json['tags'] as List<dynamic>)
      .map((e) => Tag.fromJson(e as Map<String, dynamic>))
      .toList(),
);

Map<String, dynamic> _$StoryBundleToJson(StoryBundle instance) =>
    <String, dynamic>{
      'story': instance.story.toJson(),
      'medium': instance.image?.toJson(),
      'genre': instance.genre.toJson(),
      'author': instance.author.toJson(),
      'story_progress': instance.storyProgress.toJson(),
      'current_part': instance.currentPart?.toJson(),
      'parts': instance.parts.map((e) => e.toJson()).toList(),
      'tags': instance.tags.map((e) => e.toJson()).toList(),
    };
