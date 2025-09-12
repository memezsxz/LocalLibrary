import 'package:flutter_html/flutter_html.dart';
import 'package:json_annotation/json_annotation.dart';

import 'models.dart';

part 'server_models.g.dart';

class BookMinimal {
  DbImage image;
  int storyId;
  String title;
  final String wattId;

  BookMinimal({ required this.storyId, required this.wattId, required this.title, required this.image, });

  factory BookMinimal.fromJson(Map<String, dynamic> json) {
    return BookMinimal(
      image: DbImage.fromJson(json['image']),
      storyId: json['story_id'],
      title: json['title'],
      wattId: json['watt_id']
    );
  }

  Map<String, dynamic> toJson() {
    final data = <String, dynamic>{};
    data['image'] = image;
    data['story_id'] = storyId;
    data['title'] = title;
    data['watt_id'] = wattId;
    return data;
  }
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
  final DbImage? image;

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
    required  this.storyProgress,
    this.currentPart,
    required this.parts,
    required this.tags
  });

  factory StoryBundle.fromJson(Map<String, dynamic> json) =>
      _$StoryBundleFromJson(json);

  Map<String, dynamic> toJson() => _$StoryBundleToJson(this);
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
    this.video
  });

  factory PartFullInfo.fromJson(Map<String, dynamic> json) =>
      _$PartFullInfoFromJson(json);

  Map<String, dynamic> toJson() => _$PartFullInfoToJson(this);
}
