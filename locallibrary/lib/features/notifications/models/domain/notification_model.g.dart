// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'notification_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

AppNotification _$AppNotificationFromJson(Map<String, dynamic> json) =>
    AppNotification(
      notificationId: (json['notification_id'] as num).toInt(),
      storyId: (json['story_id'] as num).toInt(),
      partId: (json['part_id'] as num?)?.toInt(),
      paragraphId: (json['paragraph_id'] as num?)?.toInt(),
      commentId: (json['comment_id'] as num?)?.toInt(),
      notificationType: $enumDecode(
        _$NotificationTypeEnumMap,
        json['notification_type'],
      ),
      message: json['message'] as String,
      isRead: json['is_read'] as bool,
      createdAt: DateTime.parse(json['created_at'] as String),
      updatedAt: DateTime.parse(json['updated_at'] as String),
    );

Map<String, dynamic> _$AppNotificationToJson(
  AppNotification instance,
) => <String, dynamic>{
  'notification_id': instance.notificationId,
  'story_id': instance.storyId,
  'part_id': instance.partId,
  'paragraph_id': instance.paragraphId,
  'comment_id': instance.commentId,
  'notification_type': _$NotificationTypeEnumMap[instance.notificationType]!,
  'message': instance.message,
  'is_read': instance.isRead,
  'created_at': instance.createdAt.toIso8601String(),
  'updated_at': instance.updatedAt.toIso8601String(),
};

const _$NotificationTypeEnumMap = {
  NotificationType.partAdded: 'part_added',
  NotificationType.partDeleted: 'part_deleted',
  NotificationType.storyAdded: 'story_added',
  NotificationType.storyDeleted: 'story_deleted',
  NotificationType.authorComment: 'author_comment',
};
