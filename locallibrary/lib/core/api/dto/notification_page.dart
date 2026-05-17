import 'package:json_annotation/json_annotation.dart';

import 'notification_row.dart';

part 'notification_page.g.dart';

@JsonSerializable()
class NotificationPage {
  final List<NotificationRow> items;

  const NotificationPage({required this.items});

  factory NotificationPage.fromJson(Map<String, dynamic> json) =>
      _$NotificationPageFromJson(json);

  Map<String, dynamic> toJson() => _$NotificationPageToJson(this);
}
