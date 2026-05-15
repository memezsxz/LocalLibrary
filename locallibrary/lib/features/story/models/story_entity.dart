import 'package:json_annotation/json_annotation.dart';

import 'story_model.dart';

part 'story_entity.g.dart';


@JsonSerializable(explicitToJson: true, fieldRename: FieldRename.snake)
class StoryTxResult {
  final Author author;
  final Media image;
  final Story story;
  final Genre genre;
  final List<Tag> tags;

  const StoryTxResult({
    required this.author,
    required this.image,
    required this.story,
    required this.genre,
    required this.tags,
  });

  factory StoryTxResult.fromJson(Map<String, dynamic> json) =>
      _$StoryTxResultFromJson(json);

  Map<String, dynamic> toJson() => _$StoryTxResultToJson(this);
}

@JsonSerializable(explicitToJson: true, fieldRename: FieldRename.snake)
class PartTxResult {
  final Part part;
  final Media? image;
  final Media? video;

  @JsonKey(name: 'paragraphs')
  @JsonKey(defaultValue: List<Paragraph>)
  final List<Paragraph> paragraphs;

  @JsonKey(name: 'comments')
  @JsonKey(defaultValue: List<Comment>)
  final List<Comment> comments;

  PartTxResult(
      {required this.part, this.image, this.video, required this.paragraphs,
        required this.comments});

  factory PartTxResult.fromJson(Map<String, dynamic> json) =>
      _$PartTxResultFromJson(json);

  Map<String, dynamic> toJson() => _$PartTxResultToJson(this);
}
