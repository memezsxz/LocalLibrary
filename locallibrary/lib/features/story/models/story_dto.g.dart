// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'story_dto.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

PartLink _$PartLinkFromJson(Map<String, dynamic> json) => PartLink(
  wattId: PartLink._asNonEmptyString(json['watt_id']),
  url: json['url'] as String?,
  title: json['title'] as String?,
);

Map<String, dynamic> _$PartLinkToJson(PartLink instance) => <String, dynamic>{
  'watt_id': instance.wattId,
  'url': instance.url,
  'title': instance.title,
};

StoryBundle _$StoryBundleFromJson(Map<String, dynamic> json) => StoryBundle(
  story: Story.fromJson(json['story'] as Map<String, dynamic>),
  image: json['medium'] == null
      ? null
      : Media.fromJson(json['medium'] as Map<String, dynamic>),
  genre: Genre.fromJson(json['genre'] as Map<String, dynamic>),
  author: Author.fromJson(json['author'] as Map<String, dynamic>),
  storyProgress: StoryProgress.fromJson(
    json['story_progress'] as Map<String, dynamic>,
  ),
  currentPart: json['current_part'] == null
      ? null
      : Part.fromJson(json['current_part'] as Map<String, dynamic>),
  parts: (json['parts'] as List<dynamic>)
      .map((e) => Part.fromJson(e as Map<String, dynamic>))
      .toList(),
  tags: (json['tags'] as List<dynamic>)
      .map((e) => Tag.fromJson(e as Map<String, dynamic>))
      .toList(),
);

Map<String, dynamic> _$StoryBundleToJson(StoryBundle instance) =>
    <String, dynamic>{
      'story': instance.story.toJson(),
      'medium': instance.image?.toJson(),
      'genre': instance.genre.toJson(),
      'author': instance.author.toJson(),
      'story_progress': instance.storyProgress.toJson(),
      'current_part': instance.currentPart?.toJson(),
      'parts': instance.parts.map((e) => e.toJson()).toList(),
      'tags': instance.tags.map((e) => e.toJson()).toList(),
    };

PartFullInfo _$PartFullInfoFromJson(Map<String, dynamic> json) => PartFullInfo(
  part: Part.fromJson(json['part'] as Map<String, dynamic>),
  paragraphs: (json['paragraphs'] as List<dynamic>)
      .map((e) => Paragraph.fromJson(e as Map<String, dynamic>))
      .toList(),
  commentsCount: (json['comments_count'] as num).toInt(),
  image: json['image'] == null
      ? null
      : Media.fromJson(json['image'] as Map<String, dynamic>),
  video: json['video'] == null
      ? null
      : Media.fromJson(json['video'] as Map<String, dynamic>),
);

Map<String, dynamic> _$PartFullInfoToJson(PartFullInfo instance) =>
    <String, dynamic>{
      'part': instance.part.toJson(),
      'paragraphs': instance.paragraphs.map((e) => e.toJson()).toList(),
      'image': instance.image?.toJson(),
      'video': instance.video?.toJson(),
      'comments_count': instance.commentsCount,
    };

ScrapeStoryRes _$ScrapeStoryResFromJson(Map<String, dynamic> json) =>
    ScrapeStoryRes(
      story: StoryTxResult.fromJson(json['story'] as Map<String, dynamic>),
      partLinks:
          (json['part_links'] as List<dynamic>?)
              ?.map((e) => PartLink.fromJson(e as Map<String, dynamic>))
              .toList() ??
          [],
    );

Map<String, dynamic> _$ScrapeStoryResToJson(ScrapeStoryRes instance) =>
    <String, dynamic>{
      'story': instance.story.toJson(),
      'part_links': instance.partLinks.map((e) => e.toJson()).toList(),
    };
