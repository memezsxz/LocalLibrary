import 'package:json_annotation/json_annotation.dart';

import 'story_enums.dart';

part 'media_model.g.dart';

@JsonSerializable(fieldRename: FieldRename.snake, explicitToJson: true)
class Media {
  final int mediaId;
  final String uuid;
  final MediaType type;
  final String? url;
  final String? path;

  Media({
    required this.mediaId,
    required this.uuid,
    required this.type,
    this.url,
    this.path,
  });

  factory Media.fromJson(Map<String, dynamic> json) => _$MediaFromJson(json);

  Map<String, dynamic> toJson() => _$MediaToJson(this);
}
