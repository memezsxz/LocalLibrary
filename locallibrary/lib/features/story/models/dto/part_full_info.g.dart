// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'part_full_info.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

PartFullInfo _$PartFullInfoFromJson(Map<String, dynamic> json) => PartFullInfo(
  part: Part.fromJson(json['part'] as Map<String, dynamic>),
  paragraphs: (json['paragraphs'] as List<dynamic>)
      .map((e) => Paragraph.fromJson(e as Map<String, dynamic>))
      .toList(),
  commentsCount: (json['comments_count'] as num).toInt(),
  image: json['image'] == null
      ? null
      : Media.fromJson(json['image'] as Map<String, dynamic>),
  video: json['video'] == null
      ? null
      : Media.fromJson(json['video'] as Map<String, dynamic>),
);

Map<String, dynamic> _$PartFullInfoToJson(PartFullInfo instance) =>
    <String, dynamic>{
      'part': instance.part.toJson(),
      'paragraphs': instance.paragraphs.map((e) => e.toJson()).toList(),
      'image': instance.image?.toJson(),
      'video': instance.video?.toJson(),
      'comments_count': instance.commentsCount,
    };
