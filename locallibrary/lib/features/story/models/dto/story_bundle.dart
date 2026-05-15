import 'package:json_annotation/json_annotation.dart';

import '../domain/author_model.dart';
import '../domain/media_model.dart';
import '../domain/part_model.dart';
import '../domain/progress_model.dart';
import '../domain/story_model.dart';

part 'story_bundle.g.dart';

/// Represents the compound response:
/// { "story": {...}, "image": {...}, "genre": {...}, "author": {...},
///   "story_progress": {...}, "Parts": [{...}, ...] }
@JsonSerializable(explicitToJson: true, fieldRename: FieldRename.snake)
class StoryBundle {
  final Story story;

  @JsonKey(name: 'medium')
  final Media? image;

  final Genre genre;
  final Author author;

  @JsonKey(name: 'story_progress')
  final StoryProgress storyProgress;

  @JsonKey(name: 'current_part')
  final Part? currentPart;

  @JsonKey(name: 'parts')
  final List<Part> parts;

  @JsonKey(name: 'tags')
  final List<Tag> tags;

  StoryBundle({
    required this.story,
    this.image,
    required this.genre,
    required this.author,
    required this.storyProgress,
    this.currentPart,
    required this.parts,
    required this.tags,
  });

  factory StoryBundle.fromJson(Map<String, dynamic> json) =>
      _$StoryBundleFromJson(json);

  Map<String, dynamic> toJson() => _$StoryBundleToJson(this);

  StoryBundle copyWith({Part? currentPart}) {
    return StoryBundle(
      story: story,
      image: image,
      genre: genre,
      author: author,
      storyProgress: storyProgress,
      currentPart: currentPart ?? this.currentPart,
      parts: parts,
      tags: tags,
    );
  }
}
