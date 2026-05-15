// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'book_cover_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

BookMinimal _$BookMinimalFromJson(Map<String, dynamic> json) => BookMinimal(
  storyId: (json['story_id'] as num).toInt(),
  wattId: json['watt_id'] as String,
  title: json['title'] as String,
  image: Media.fromJson(json['medium'] as Map<String, dynamic>),
);

Map<String, dynamic> _$BookMinimalToJson(BookMinimal instance) =>
    <String, dynamic>{
      'medium': instance.image.toJson(),
      'story_id': instance.storyId,
      'title': instance.title,
      'watt_id': instance.wattId,
    };
