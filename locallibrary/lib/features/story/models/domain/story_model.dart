import 'dart:convert';

import 'package:json_annotation/json_annotation.dart';

export 'genre_model.dart';
export 'tag_model.dart';

part 'story_model.g.dart';

@JsonSerializable(fieldRename: FieldRename.snake, explicitToJson: true)
class Story {
  final int storyId;
  final String wattId;
  final int authorId;
  final String title;
  final String description;
  final int genreId;
  final int? imageId;
  final bool isDeleted;
  final bool isFamilyFriendly;
  final bool isFree;
  final String language;
  final String? url;
  final String ageRange;
  final DateTime?
  dateCreated; // SQL DATE: stored/serialized as ISO-8601 date string
  final DateTime? dateModified; // SQL DATE
  final DateTime? datePublished; // SQL DATE
  final DateTime createdAt;
  final DateTime updatedAt;

  Story({
    required this.storyId,
    required this.wattId,
    required this.authorId,
    required this.title,
    required this.description,
    required this.genreId,
    this.imageId,
    required this.isDeleted,
    required this.isFamilyFriendly,
    required this.isFree,
    required this.language,
    this.url,
    required this.ageRange,
    this.dateCreated,
    this.dateModified,
    this.datePublished,
    required this.createdAt,
    required this.updatedAt,
  });

  factory Story.fromJson(Map<String, dynamic> json) => _$StoryFromJson(json);

  Map<String, dynamic> toJson() => _$StoryToJson(this);
}

List<Story> storyListFromJson(dynamic data) {
  if (data is String) {
    final decoded = jsonDecode(data);
    if (decoded is List) {
      return decoded
          .map((e) => Story.fromJson(Map<String, dynamic>.from(e as Map)))
          .toList();
    } else {
      throw const FormatException('Expected a JSON array string for stories');
    }
  } else if (data is List) {
    return data
        .map((e) => Story.fromJson(Map<String, dynamic>.from(e as Map)))
        .toList();
  } else {
    throw const FormatException(
      'Expected a JSON array (or JSON string) for stories',
    );
  }
}

dynamic storyListToJson(List<Story> stories) =>
    stories.map((s) => s.toJson()).toList();
