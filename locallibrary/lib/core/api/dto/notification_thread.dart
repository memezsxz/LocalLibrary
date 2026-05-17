import 'package:json_annotation/json_annotation.dart';

import '../../../features/story/models/domain/comment_model.dart';
import '../../../features/story/models/domain/part_model.dart';

part 'notification_thread.g.dart';

@JsonSerializable(fieldRename: FieldRename.snake)
class NotificationThread {
  final Paragraph? paragraph;
  final List<Comment> comments;

  const NotificationThread({required this.paragraph, required this.comments});

  factory NotificationThread.fromJson(Map<String, dynamic> json) =>
      _$NotificationThreadFromJson(json);
}
