import 'package:json_annotation/json_annotation.dart';
import 'package:locallibrary/features/story/models/dto/story_tx_result.dart';

import 'part_link.dart';

part 'scrape_story_res.g.dart';

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
