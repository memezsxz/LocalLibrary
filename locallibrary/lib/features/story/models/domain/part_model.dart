import 'package:json_annotation/json_annotation.dart';

import 'media_model.dart';
import 'story_enums.dart';

part 'part_model.g.dart';

@JsonSerializable(fieldRename: FieldRename.snake, explicitToJson: true)
class Part {
  final int partId;
  final String wattId;
  final int? idx; // smallint in DB
  final String title;
  final DateTime datePublished; // SQL DATE
  final int? imageId; // FK to media
  final int? videoId; // FK to media (YouTube)
  final bool isDeleted;
  final String href;
  final int votes; // bigint
  final DateTime createdAt;
  final DateTime updatedAt;

  Part({
    required this.partId,
    required this.wattId,
    this.idx,
    required this.title,
    required this.datePublished,
    this.imageId,
    this.videoId,
    required this.isDeleted,
    required this.href,
    required this.votes,
    required this.createdAt,
    required this.updatedAt,
  });

  factory Part.fromJson(Map<String, dynamic> json) => _$PartFromJson(json);

  Map<String, dynamic> toJson() => _$PartToJson(this);
}

@JsonSerializable(fieldRename: FieldRename.snake, explicitToJson: true)
class Paragraph {
  final int paragraphId;
  final String? wattId;
  final int idx; // bigint
  final int partId;
  final Direction direction;
  final ContentType contentType;
  final String? content;
  final String? contentText; // generated column in DB
  final int? mediaId;
  final Media? media;
  final int commentsCount;

  Paragraph({
    required this.paragraphId,
    this.wattId,
    required this.idx,
    required this.partId,
    required this.direction,
    required this.contentType,
    this.content,
    this.contentText,
    this.mediaId,
    this.media,
    this.commentsCount = 0,
  });

  factory Paragraph.fromJson(Map<String, dynamic> json) =>
      _$ParagraphFromJson(json);

  Map<String, dynamic> toJson() => _$ParagraphToJson(this);
}
