// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'scrape_story_res.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

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
