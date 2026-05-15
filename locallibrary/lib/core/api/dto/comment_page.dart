import 'package:json_annotation/json_annotation.dart';

import '../../../features/story/models/domain/comment_model.dart';

part 'comment_page.g.dart';

@JsonSerializable()
class CommentPage {
  final List<Comment> items;

  const CommentPage({required this.items});

  factory CommentPage.fromJson(Map<String, dynamic> json) =>
      _$CommentPageFromJson(json);

  Map<String, dynamic> toJson() => _$CommentPageToJson(this);
}
