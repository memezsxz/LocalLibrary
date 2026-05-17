// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'part_info.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

PartInfo _$PartInfoFromJson(Map<String, dynamic> json) => PartInfo(
  partId: (json['part_id'] as num).toInt(),
  title: json['title'] as String,
  votes: (json['votes'] as num).toInt(),
  wattId: json['watt_id'] as String,
  datePublished: DateTime.parse(json['date_published'] as String),
  isDeleted: json['is_deleted'] as bool,
  imageMediaId: (json['image_media_id'] as num?)?.toInt(),
  imageFilePath: json['image_file_path'] as String?,
  videoMediaId: (json['video_media_id'] as num?)?.toInt(),
  videoFilePath: json['video_file_path'] as String?,
  paragraphCount: (json['paragraph_count'] as num).toInt(),
  commentCount: (json['comment_count'] as num).toInt(),
);

Map<String, dynamic> _$PartInfoToJson(PartInfo instance) => <String, dynamic>{
  'part_id': instance.partId,
  'title': instance.title,
  'votes': instance.votes,
  'watt_id': instance.wattId,
  'date_published': instance.datePublished.toIso8601String(),
  'is_deleted': instance.isDeleted,
  'image_media_id': instance.imageMediaId,
  'image_file_path': instance.imageFilePath,
  'video_media_id': instance.videoMediaId,
  'video_file_path': instance.videoFilePath,
  'paragraph_count': instance.paragraphCount,
  'comment_count': instance.commentCount,
};
