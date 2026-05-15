// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'author_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

Author _$AuthorFromJson(Map<String, dynamic> json) => Author(
  authorId: (json['author_id'] as num).toInt(),
  name: json['name'] as String,
  profileUrl: json['profile_url'] as String,
  username: json['username'] as String,
  createdAt: DateTime.parse(json['created_at'] as String),
  updatedAt: DateTime.parse(json['updated_at'] as String),
);

Map<String, dynamic> _$AuthorToJson(Author instance) => <String, dynamic>{
  'author_id': instance.authorId,
  'name': instance.name,
  'profile_url': instance.profileUrl,
  'username': instance.username,
  'created_at': instance.createdAt.toIso8601String(),
  'updated_at': instance.updatedAt.toIso8601String(),
};
