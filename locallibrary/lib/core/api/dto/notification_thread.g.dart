// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'notification_thread.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

NotificationThread _$NotificationThreadFromJson(Map<String, dynamic> json) =>
    NotificationThread(
      paragraph: json['paragraph'] == null
          ? null
          : Paragraph.fromJson(json['paragraph'] as Map<String, dynamic>),
      comments: (json['comments'] as List<dynamic>)
          .map((e) => Comment.fromJson(e as Map<String, dynamic>))
          .toList(),
    );

Map<String, dynamic> _$NotificationThreadToJson(NotificationThread instance) =>
    <String, dynamic>{
      'paragraph': instance.paragraph,
      'comments': instance.comments,
    };
