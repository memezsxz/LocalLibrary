import 'package:json_annotation/json_annotation.dart';

import '../domain/media_model.dart';
import '../domain/part_model.dart';

part 'part_full_info.g.dart';

@JsonSerializable(explicitToJson: true, fieldRename: FieldRename.snake)
class PartFullInfo {
  @JsonKey(name: 'part')
  final Part part;

  @JsonKey(name: 'paragraphs')
  final List<Paragraph> paragraphs;

  @JsonKey(name: 'image')
  final Media? image;

  @JsonKey(name: 'video')
  final Media? video;

  @JsonKey(name: 'comments_count')
  final int commentsCount;

  PartFullInfo({
    required this.part,
    required this.paragraphs,
    required this.commentsCount,
    this.image,
    this.video,
  });

  factory PartFullInfo.fromJson(Map<String, dynamic> json) =>
      _$PartFullInfoFromJson(json);

  Map<String, dynamic> toJson() => _$PartFullInfoToJson(this);
}
