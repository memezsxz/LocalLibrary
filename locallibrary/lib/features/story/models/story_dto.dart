import 'package:json_annotation/json_annotation.dart';
import 'package:locallibrary/features/story/models/story_entity.dart';
import 'package:locallibrary/features/story/models/story_parsed_dto.dart';

import 'story_models.dart';

part 'story_dto.g.dart';

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

/// Represents the compound response you showed:
/// {
///   "story": {...},
///   "image": {...},
///   "genre": {...},
///   "author": {...},
///   "story_progress": {...},
///   "Parts": [ {...}, ... ]
/// }
@JsonSerializable(explicitToJson: true, fieldRename: FieldRename.snake)
class StoryBundle {
  final Story story;

  /// Optional because some stories might not have a cover.
  @JsonKey(name: 'medium')
  final Media? image;

  final Genre genre;
  final Author author;

  /// Optional because not all callers include progress.
  @JsonKey(name: 'story_progress')
  final StoryProgress storyProgress;

  @JsonKey(name: 'current_part')
  final Part? currentPart;

  /// The incoming JSON uses the capitalized key "Parts" (note the P).
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

@JsonSerializable(explicitToJson: true, fieldRename: FieldRename.snake)
class ScrapeStoryRes {
  @JsonKey(name: 'story')
  final StoryTxResult story;

  @JsonKey(name: 'part_links', defaultValue: [])
  final List<PartLink> partLinks;

  ScrapeStoryRes({required this.story, required this.partLinks});

  factory ScrapeStoryRes.fromJson(Map<String, dynamic> json) =>
      _$ScrapeStoryResFromJson(json);

  Map<String, dynamic> toJson() => _$ScrapeStoryResToJson(this);
}

