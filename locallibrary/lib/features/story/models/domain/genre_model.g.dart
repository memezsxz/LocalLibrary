// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'genre_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

Genre _$GenreFromJson(Map<String, dynamic> json) => Genre(
  genreId: (json['genre_id'] as num).toInt(),
  name: json['name'] as String,
  createdAt: DateTime.parse(json['created_at'] as String),
  updatedAt: DateTime.parse(json['updated_at'] as String),
);

Map<String, dynamic> _$GenreToJson(Genre instance) => <String, dynamic>{
  'genre_id': instance.genreId,
  'name': instance.name,
  'created_at': instance.createdAt.toIso8601String(),
  'updated_at': instance.updatedAt.toIso8601String(),
};
