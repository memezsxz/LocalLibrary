import 'package:json_annotation/json_annotation.dart';

part 'progress_model.g.dart';

@JsonSerializable(fieldRename: FieldRename.snake, explicitToJson: true)
class StoryProgress {
  final int storyProgressId;
  final int storyId;
  final double?
  progress; // decimal(4,3), nullable; expected in [0,1] per DB CHECK
  final int? lastParagraphId;
  final DateTime? readStartTime;
  final DateTime? readEndTime;

  /// Seconds
  final int readDuration;
  final DateTime createdAt;
  final DateTime updatedAt;

  StoryProgress({
    required this.storyProgressId,
    required this.storyId,
    this.progress,
    this.lastParagraphId,
    this.readStartTime,
    this.readEndTime,
    this.readDuration = 0,
    required this.createdAt,
    required this.updatedAt,
  });

  factory StoryProgress.fromJson(Map<String, dynamic> json) =>
      _$StoryProgressFromJson(json);

  Map<String, dynamic> toJson() => _$StoryProgressToJson(this);
}
