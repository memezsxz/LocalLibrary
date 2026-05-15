// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'part_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

Part _$PartFromJson(Map<String, dynamic> json) => Part(
  partId: (json['part_id'] as num).toInt(),
  wattId: json['watt_id'] as String,
  idx: (json['idx'] as num?)?.toInt(),
  title: json['title'] as String,
  datePublished: DateTime.parse(json['date_published'] as String),
  imageId: (json['image_id'] as num?)?.toInt(),
  videoId: (json['video_id'] as num?)?.toInt(),
  isDeleted: json['is_deleted'] as bool,
  href: json['href'] as String,
  votes: (json['votes'] as num).toInt(),
  createdAt: DateTime.parse(json['created_at'] as String),
  updatedAt: DateTime.parse(json['updated_at'] as String),
);

Map<String, dynamic> _$PartToJson(Part instance) => <String, dynamic>{
  'part_id': instance.partId,
  'watt_id': instance.wattId,
  'idx': instance.idx,
  'title': instance.title,
  'date_published': instance.datePublished.toIso8601String(),
  'image_id': instance.imageId,
  'video_id': instance.videoId,
  'is_deleted': instance.isDeleted,
  'href': instance.href,
  'votes': instance.votes,
  'created_at': instance.createdAt.toIso8601String(),
  'updated_at': instance.updatedAt.toIso8601String(),
};

Paragraph _$ParagraphFromJson(Map<String, dynamic> json) => Paragraph(
  paragraphId: (json['paragraph_id'] as num).toInt(),
  wattId: json['watt_id'] as String?,
  idx: (json['idx'] as num).toInt(),
  partId: (json['part_id'] as num).toInt(),
  direction: $enumDecode(_$DirectionEnumMap, json['direction']),
  contentType: $enumDecode(_$ContentTypeEnumMap, json['content_type']),
  content: json['content'] as String?,
  contentText: json['content_text'] as String?,
  mediaId: (json['media_id'] as num?)?.toInt(),
  media: json['media'] == null
      ? null
      : Media.fromJson(json['media'] as Map<String, dynamic>),
  commentsCount: (json['comments_count'] as num?)?.toInt() ?? 0,
);

Map<String, dynamic> _$ParagraphToJson(Paragraph instance) => <String, dynamic>{
  'paragraph_id': instance.paragraphId,
  'watt_id': instance.wattId,
  'idx': instance.idx,
  'part_id': instance.partId,
  'direction': _$DirectionEnumMap[instance.direction]!,
  'content_type': _$ContentTypeEnumMap[instance.contentType]!,
  'content': instance.content,
  'content_text': instance.contentText,
  'media_id': instance.mediaId,
  'media': instance.media?.toJson(),
  'comments_count': instance.commentsCount,
};

const _$DirectionEnumMap = {Direction.rtl: 'RTL', Direction.ltr: 'LTR'};

const _$ContentTypeEnumMap = {
  ContentType.text: 'text',
  ContentType.image: 'image',
  ContentType.video: 'video',
  ContentType.link: 'link',
};
