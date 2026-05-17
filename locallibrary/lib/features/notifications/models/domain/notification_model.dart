import 'package:json_annotation/json_annotation.dart';

import '../../../story/models/domain/story_enums.dart';

part 'notification_model.g.dart';

@JsonSerializable(fieldRename: FieldRename.snake, explicitToJson: true)
class AppNotification {
  final int notificationId;
  final int storyId;
  final int? partId;
  final int? paragraphId;
  final int? commentId;
  final NotificationType notificationType;
  final String message;
  final bool isRead;
  final DateTime createdAt;
  final DateTime updatedAt;

  AppNotification({
    required this.notificationId,
    required this.storyId,
    this.partId,
    this.paragraphId,
    this.commentId,
    required this.notificationType,
    required this.message,
    required this.isRead,
    required this.createdAt,
    required this.updatedAt,
  });

  factory AppNotification.fromJson(Map<String, dynamic> json) =>
      _$AppNotificationFromJson(json);

  Map<String, dynamic> toJson() => _$AppNotificationToJson(this);

  AppNotification copyWith({bool? isRead}) => AppNotification(
    notificationId: notificationId,
    storyId: storyId,
    partId: partId,
    paragraphId: paragraphId,
    commentId: commentId,
    notificationType: notificationType,
    message: message,
    isRead: isRead ?? this.isRead,
    createdAt: createdAt,
    updatedAt: updatedAt,
  );
}
