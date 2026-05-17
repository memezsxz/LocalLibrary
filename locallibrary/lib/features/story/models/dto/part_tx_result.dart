import 'package:json_annotation/json_annotation.dart';

import '../domain/comment_model.dart';
import '../domain/media_model.dart';
import '../domain/part_model.dart';

part 'part_tx_result.g.dart';

@JsonSerializable(explicitToJson: true, fieldRename: FieldRename.snake)
class PartTxResult {
  final Part part;
  final Media? image;
  final Media? video;

  @JsonKey(name: 'paragraphs')
  @JsonKey(defaultValue: List<Paragraph>)
  final List<Paragraph>? paragraphs;

  // @JsonKey(name: 'comments')
  // @JsonKey(defaultValue: List<Comment>)
  final List<Comment>? comments;

  PartTxResult({
    required this.part,
    this.image,
    this.video,
    required this.paragraphs,
    required this.comments,
  });

  factory PartTxResult.fromJson(Map<String, dynamic> json) =>
      _$PartTxResultFromJson(json);

  Map<String, dynamic> toJson() => _$PartTxResultToJson(this);
}
