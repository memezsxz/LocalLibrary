// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'comment_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

Comment _$CommentFromJson(Map<String, dynamic> json) => Comment(
  commentId: (json['comment_id'] as num).toInt(),
  wattId: json['watt_id'] as String,
  text: json['text'] as String,
  userName: json['user_name'] as String,
  likes: (json['likes'] as num).toInt(),
  partId: (json['part_id'] as num).toInt(),
  paragraphId: (json['paragraph_id'] as num?)?.toInt(),
  parentCommentId: (json['parent_comment_id'] as num?)?.toInt(),
  depth: (json['depth'] as num?)?.toInt(),
  parentType: $enumDecode(_$ParentTypeEnumMap, json['parent_type']),
  wattParentId: json['watt_parent_id'] as String?,
  isDeleted: json['is_deleted'] as bool,
  link: json['link'] as String?,
  dateCreated: json['date_created'] == null
      ? null
      : DateTime.parse(json['date_created'] as String),
  dateModified: json['date_modified'] == null
      ? null
      : DateTime.parse(json['date_modified'] as String),
  repliesCount: (json['replies_count'] as num?)?.toInt() ?? 0,
  createdAt: DateTime.parse(json['created_at'] as String),
  updatedAt: DateTime.parse(json['updated_at'] as String),
);

Map<String, dynamic> _$CommentToJson(Comment instance) => <String, dynamic>{
  'comment_id': instance.commentId,
  'watt_id': instance.wattId,
  'text': instance.text,
  'user_name': instance.userName,
  'likes': instance.likes,
  'part_id': instance.partId,
  'paragraph_id': instance.paragraphId,
  'parent_comment_id': instance.parentCommentId,
  'depth': instance.depth,
  'parent_type': _$ParentTypeEnumMap[instance.parentType]!,
  'watt_parent_id': instance.wattParentId,
  'is_deleted': instance.isDeleted,
  'link': instance.link,
  'date_created': instance.dateCreated?.toIso8601String(),
  'date_modified': instance.dateModified?.toIso8601String(),
  'replies_count': instance.repliesCount,
  'created_at': instance.createdAt.toIso8601String(),
  'updated_at': instance.updatedAt.toIso8601String(),
};

const _$ParentTypeEnumMap = {
  ParentType.paragraph: 'paragraph',
  ParentType.comment: 'comment',
  ParentType.part: 'part',
};
