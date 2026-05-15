import 'package:json_annotation/json_annotation.dart';

import '../domain/author_model.dart';
import '../domain/media_model.dart';
import '../domain/story_model.dart';

part 'story_tx_result.g.dart';

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
