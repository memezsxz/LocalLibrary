import 'package:json_annotation/json_annotation.dart';

import 'models.dart';

part 'store_models.g.dart';

@JsonSerializable(explicitToJson: true, fieldRename: FieldRename.snake)
class StoryTxResult {
  final Author author;
  final DbImage image;
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
