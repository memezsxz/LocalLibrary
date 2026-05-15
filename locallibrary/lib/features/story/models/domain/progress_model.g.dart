// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'progress_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

StoryProgress _$StoryProgressFromJson(Map<String, dynamic> json) =>
    StoryProgress(
      storyProgressId: (json['story_progress_id'] as num).toInt(),
      storyId: (json['story_id'] as num).toInt(),
      progress: (json['progress'] as num?)?.toDouble(),
      lastParagraphId: (json['last_paragraph_id'] as num?)?.toInt(),
      readStartTime: json['read_start_time'] == null
          ? null
          : DateTime.parse(json['read_start_time'] as String),
      readEndTime: json['read_end_time'] == null
          ? null
          : DateTime.parse(json['read_end_time'] as String),
      readDuration: (json['read_duration'] as num?)?.toInt() ?? 0,
      createdAt: DateTime.parse(json['created_at'] as String),
      updatedAt: DateTime.parse(json['updated_at'] as String),
    );

Map<String, dynamic> _$StoryProgressToJson(StoryProgress instance) =>
    <String, dynamic>{
      'story_progress_id': instance.storyProgressId,
      'story_id': instance.storyId,
      'progress': instance.progress,
      'last_paragraph_id': instance.lastParagraphId,
      'read_start_time': instance.readStartTime?.toIso8601String(),
      'read_end_time': instance.readEndTime?.toIso8601String(),
      'read_duration': instance.readDuration,
      'created_at': instance.createdAt.toIso8601String(),
      'updated_at': instance.updatedAt.toIso8601String(),
    };
