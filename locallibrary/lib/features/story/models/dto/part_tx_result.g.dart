// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'part_tx_result.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

PartTxResult _$PartTxResultFromJson(Map<String, dynamic> json) => PartTxResult(
  part: Part.fromJson(json['part'] as Map<String, dynamic>),
  image: json['image'] == null
      ? null
      : Media.fromJson(json['image'] as Map<String, dynamic>),
  video: json['video'] == null
      ? null
      : Media.fromJson(json['video'] as Map<String, dynamic>),
  paragraphs: (json['paragraphs'] as List<dynamic>)
      .map((e) => Paragraph.fromJson(e as Map<String, dynamic>))
      .toList(),
  comments: (json['comments'] as List<dynamic>)
      .map((e) => Comment.fromJson(e as Map<String, dynamic>))
      .toList(),
);

Map<String, dynamic> _$PartTxResultToJson(PartTxResult instance) =>
    <String, dynamic>{
      'part': instance.part.toJson(),
      'image': instance.image?.toJson(),
      'video': instance.video?.toJson(),
      'paragraphs': instance.paragraphs.map((e) => e.toJson()).toList(),
      'comments': instance.comments.map((e) => e.toJson()).toList(),
    };
