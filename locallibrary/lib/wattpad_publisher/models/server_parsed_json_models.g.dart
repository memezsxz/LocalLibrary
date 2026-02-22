// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'server_parsed_json_models.dart';

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
