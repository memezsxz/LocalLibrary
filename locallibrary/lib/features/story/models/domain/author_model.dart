import 'package:json_annotation/json_annotation.dart';

part 'author_model.g.dart';

@JsonSerializable(fieldRename: FieldRename.snake, explicitToJson: true)
class Author {
  final int authorId;
  final String name;
  final String profileUrl;
  final String username;
  final DateTime createdAt;
  final DateTime updatedAt;

  Author({
    required this.authorId,
    required this.name,
    required this.profileUrl,
    required this.username,
    required this.createdAt,
    required this.updatedAt,
  });

  factory Author.fromJson(Map<String, dynamic> json) => _$AuthorFromJson(json);

  Map<String, dynamic> toJson() => _$AuthorToJson(this);
}
