import 'package:json_annotation/json_annotation.dart';

import 'media_model.dart';

part 'book_cover_model.g.dart';

@JsonSerializable(explicitToJson: true, fieldRename: FieldRename.snake)
class BookMinimal {
  @JsonKey(name: 'medium')
  Media image;
  int storyId;
  String title;
  final String wattId;

  BookMinimal({
    required this.storyId,
    required this.wattId,
    required this.title,
    required this.image,
  });

  factory BookMinimal.fromJson(Map<String, dynamic> json) =>
      _$BookMinimalFromJson(json);

  Map<String, dynamic> toJson() => _$BookMinimalToJson(this);
}
