import 'dart:ui' as ui;

import 'package:json_annotation/json_annotation.dart';

part 'story_enums.g.dart';

@JsonEnum(alwaysCreate: true)
enum NotificationType {
  @JsonValue('part_added')
  partAdded,
  @JsonValue('part_deleted')
  partDeleted,
  @JsonValue('story_added')
  storyAdded,
  @JsonValue('story_deleted')
  storyDeleted,
  @JsonValue('author_comment')
  authorComment,
}

@JsonEnum(alwaysCreate: true)
enum OperationType {
  @JsonValue('insert')
  insert,
  @JsonValue('update')
  update,
  @JsonValue('delete')
  delete,
}

@JsonEnum(alwaysCreate: true)
enum Direction {
  @JsonValue('RTL')
  rtl,
  @JsonValue('LTR')
  ltr,
}

extension ExtDirection on Direction {
  ui.TextDirection get toTextDirection {
    return switch (this) {
      Direction.rtl => ui.TextDirection.rtl,
      Direction.ltr => ui.TextDirection.ltr,
    };
  }
}

@JsonEnum(alwaysCreate: true)
enum ContentType {
  @JsonValue('text')
  text,
  @JsonValue('image')
  image,
  @JsonValue('video')
  video,
  @JsonValue('link')
  link,
}

@JsonEnum(alwaysCreate: true)
enum MediaType {
  @JsonValue('video')
  video,
  @JsonValue('audio')
  audio,
  @JsonValue('image')
  image,
  @JsonValue('link')
  link,
}

@JsonEnum(alwaysCreate: true)
enum ParentType {
  @JsonValue('paragraph')
  paragraph,
  @JsonValue('comment')
  comment,
  @JsonValue('part')
  part,
}
