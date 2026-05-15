import 'package:json_annotation/json_annotation.dart';

import 'story_enums.dart';

part 'comment_model.g.dart';

@JsonSerializable(fieldRename: FieldRename.snake, explicitToJson: true)
class Comment {
  final int commentId;
  final String wattId;
  final String text;
  final String userName;
  final int likes;
  final int partId;
  final int? paragraphId;
  final int? parentCommentId;
  final int? depth; // smallint
  final ParentType parentType;
  final String? wattParentId;
  final bool isDeleted;
  final String? link;
  final DateTime? dateCreated;
  final DateTime? dateModified;
  final int repliesCount;
  final DateTime createdAt;
  final DateTime updatedAt;

  Comment({
    required this.commentId,
    required this.wattId,
    required this.text,
    required this.userName,
    required this.likes,
    required this.partId,
    this.paragraphId,
    this.parentCommentId,
    this.depth,
    required this.parentType,
    this.wattParentId,
    required this.isDeleted,
    this.link,
    this.dateCreated,
    this.dateModified,
    this.repliesCount = 0,
    required this.createdAt,
    required this.updatedAt,
  });

  factory Comment.fromJson(Map<String, dynamic> json) =>
      _$CommentFromJson(json);

  Map<String, dynamic> toJson() => _$CommentToJson(this);
}
