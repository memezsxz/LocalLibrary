// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'logs.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

ScrapeEvent _$ScrapeEventFromJson(Map<String, dynamic> json) => ScrapeEvent(
  json['name'] as String,
  json['payload'] as String,
  receivedAt: json['received_at'] == null
      ? null
      : DateTime.parse(json['received_at'] as String),
);

Map<String, dynamic> _$ScrapeEventToJson(ScrapeEvent instance) =>
    <String, dynamic>{
      'name': instance.name,
      'payload': instance.payload,
      'received_at': instance.receivedAt.toIso8601String(),
    };
