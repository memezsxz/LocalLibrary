// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'store_models.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

StoryTxResult _$StoryTxResultFromJson(Map<String, dynamic> json) =>
    StoryTxResult(
      author: Author.fromJson(json['author'] as Map<String, dynamic>),
      image: DbImage.fromJson(json['image'] as Map<String, dynamic>),
      story: Story.fromJson(json['story'] as Map<String, dynamic>),
      genre: Genre.fromJson(json['genre'] as Map<String, dynamic>),
      tags: (json['tags'] as List<dynamic>)
          .map((e) => Tag.fromJson(e as Map<String, dynamic>))
          .toList(),
    );

Map<String, dynamic> _$StoryTxResultToJson(StoryTxResult instance) =>
    <String, dynamic>{
      'author': instance.author.toJson(),
      'image': instance.image.toJson(),
      'story': instance.story.toJson(),
      'genre': instance.genre.toJson(),
      'tags': instance.tags.map((e) => e.toJson()).toList(),
    };
