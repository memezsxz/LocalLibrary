import 'package:json_annotation/json_annotation.dart';

part 'part_info.g.dart';

@JsonSerializable(fieldRename: FieldRename.snake)
class PartInfo {
  final int partId;
  final String title;
  final int votes;
  final String wattId;
  final DateTime datePublished;
  final bool isDeleted;
  final int? imageMediaId;
  final String? imageFilePath;
  final int? videoMediaId;
  final String? videoFilePath;
  final int paragraphCount;
  final int commentCount;

  const PartInfo({
    required this.partId,
    required this.title,
    required this.votes,
    required this.wattId,
    required this.datePublished,
    required this.isDeleted,
    this.imageMediaId,
    this.imageFilePath,
    this.videoMediaId,
    this.videoFilePath,
    required this.paragraphCount,
    required this.commentCount,
  });

  factory PartInfo.fromJson(Map<String, dynamic> json) =>
      _$PartInfoFromJson(json);

  Map<String, dynamic> toJson() => _$PartInfoToJson(this);
}
