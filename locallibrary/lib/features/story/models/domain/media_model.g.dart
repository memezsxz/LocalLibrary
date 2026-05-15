// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'media_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

Media _$MediaFromJson(Map<String, dynamic> json) => Media(
  mediaId: (json['media_id'] as num).toInt(),
  uuid: json['uuid'] as String,
  type: $enumDecode(_$MediaTypeEnumMap, json['type']),
  url: json['url'] as String?,
  path: json['path'] as String?,
);

Map<String, dynamic> _$MediaToJson(Media instance) => <String, dynamic>{
  'media_id': instance.mediaId,
  'uuid': instance.uuid,
  'type': _$MediaTypeEnumMap[instance.type]!,
  'url': instance.url,
  'path': instance.path,
};

const _$MediaTypeEnumMap = {
  MediaType.video: 'video',
  MediaType.audio: 'audio',
  MediaType.image: 'image',
  MediaType.link: 'link',
};
