import 'package:json_annotation/json_annotation.dart';

part 'genre_model.g.dart';

@JsonSerializable(fieldRename: FieldRename.snake, explicitToJson: true)
class Genre {
  final int genreId;
  final String name;
  final DateTime createdAt;
  final DateTime updatedAt;

  Genre({
    required this.genreId,
    required this.name,
    required this.createdAt,
    required this.updatedAt,
  });

  factory Genre.fromJson(Map<String, dynamic> json) => _$GenreFromJson(json);

  Map<String, dynamic> toJson() => _$GenreToJson(this);
}
