import 'package:json_annotation/json_annotation.dart';

part 'tag_model.g.dart';

@JsonSerializable(fieldRename: FieldRename.snake, explicitToJson: true)
class Tag {
  final int tagId;
  final String name;
  final DateTime createdAt;
  final DateTime updatedAt;

  Tag({
    required this.tagId,
    required this.name,
    required this.createdAt,
    required this.updatedAt,
  });

  factory Tag.fromJson(Map<String, dynamic> json) => _$TagFromJson(json);

  Map<String, dynamic> toJson() => _$TagToJson(this);
}

@JsonSerializable(fieldRename: FieldRename.snake, explicitToJson: true)
class StoryTag {
  final int storyId;
  final int tagId;

  StoryTag({required this.storyId, required this.tagId});

  factory StoryTag.fromJson(Map<String, dynamic> json) =>
      _$StoryTagFromJson(json);

  Map<String, dynamic> toJson() => _$StoryTagToJson(this);
}
