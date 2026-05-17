// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'notification_page.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

NotificationPage _$NotificationPageFromJson(Map<String, dynamic> json) =>
    NotificationPage(
      items: (json['items'] as List<dynamic>)
          .map((e) => NotificationRow.fromJson(e as Map<String, dynamic>))
          .toList(),
    );

Map<String, dynamic> _$NotificationPageToJson(NotificationPage instance) =>
    <String, dynamic>{'items': instance.items};
