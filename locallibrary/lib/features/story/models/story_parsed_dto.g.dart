// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'story_parsed_dto.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

PartLink _$PartLinkFromJson(Map<String, dynamic> json) => PartLink(
  wattId: PartLink._asNonEmptyString(json['watt_id']),
  url: json['url'] as String?,
  title: json['title'] as String?,
);

Map<String, dynamic> _$PartLinkToJson(PartLink instance) => <String, dynamic>{
  'watt_id': instance.wattId,
  'url': instance.url,
  'title': instance.title,
};
