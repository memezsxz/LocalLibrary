import 'package:json_annotation/json_annotation.dart';

import '../../../features/notifications/models/domain/notification_model.dart';
import '../../../features/story/models/domain/media_model.dart';

part 'notification_row.g.dart';

@JsonSerializable(fieldRename: FieldRename.snake, explicitToJson: true)
class NotificationRow {
  final AppNotification notification;
  final Media? medium;
  final String? commentPreview;
  final String? commentBody;

  const NotificationRow({
    required this.notification,
    this.medium,
    this.commentPreview,
    this.commentBody,
  });

  factory NotificationRow.fromJson(Map<String, dynamic> json) =>
      _$NotificationRowFromJson(json);

  Map<String, dynamic> toJson() => _$NotificationRowToJson(this);

  NotificationRow copyWith({AppNotification? notification}) => NotificationRow(
    notification: notification ?? this.notification,
    medium: medium,
    commentPreview: commentPreview,
    commentBody: commentBody,
  );

  // treat empty string (from COALESCE) as null
  String? get preview => (commentPreview == null || commentPreview!.isEmpty)
      ? null
      : commentPreview;
}
