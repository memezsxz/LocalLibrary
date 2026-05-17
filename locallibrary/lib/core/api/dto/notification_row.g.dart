// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'notification_row.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

NotificationRow _$NotificationRowFromJson(Map<String, dynamic> json) =>
    NotificationRow(
      notification: AppNotification.fromJson(
        json['notification'] as Map<String, dynamic>,
      ),
      medium: json['medium'] == null
          ? null
          : Media.fromJson(json['medium'] as Map<String, dynamic>),
      commentPreview: json['comment_preview'] as String?,
      commentBody: json['comment_body'] as String?,
    );

Map<String, dynamic> _$NotificationRowToJson(NotificationRow instance) =>
    <String, dynamic>{
      'notification': instance.notification.toJson(),
      'medium': instance.medium?.toJson(),
      'comment_preview': instance.commentPreview,
      'comment_body': instance.commentBody,
    };
