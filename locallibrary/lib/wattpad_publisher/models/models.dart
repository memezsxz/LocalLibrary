import 'dart:convert';
import 'dart:ui' as ui;

import 'package:json_annotation/json_annotation.dart';

part 'models.g.dart';

// ---------- Enums ----------

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

// ---------- Core Tables ----------

@JsonSerializable(fieldRename: FieldRename.snake, explicitToJson: true)
class Tag {
  final int tagId;
  final String name;
  final DateTime createdAt;
  final DateTime updatedAt;

  Tag({
    required this.tagId,
    required this.name,
    required this.createdAt,
    required this.updatedAt,
  });

  factory Tag.fromJson(Map<String, dynamic> json) => _$TagFromJson(json);

  Map<String, dynamic> toJson() => _$TagToJson(this);
}

/// Avoids clashing with Flutter's [Image] class.
@JsonSerializable(fieldRename: FieldRename.snake, explicitToJson: true)
class DbImage {
  final int imageId;
  final String uuid;
  final String? url;
  final String? path;

  DbImage({required this.imageId, required this.uuid, this.url, this.path});

  factory DbImage.fromJson(Map<String, dynamic> json) =>
      _$DbImageFromJson(json);

  Map<String, dynamic> toJson() => _$DbImageToJson(this);
}

@JsonSerializable(fieldRename: FieldRename.snake, explicitToJson: true)
class Author {
  final int authorId;
  final String name;
  final String profileUrl;
  final String username;
  final DateTime createdAt;
  final DateTime updatedAt;

  Author({
    required this.authorId,
    required this.name,
    required this.profileUrl,
    required this.username,
    required this.createdAt,
    required this.updatedAt,
  });

  factory Author.fromJson(Map<String, dynamic> json) => _$AuthorFromJson(json);

  Map<String, dynamic> toJson() => _$AuthorToJson(this);
}

@JsonSerializable(fieldRename: FieldRename.snake, explicitToJson: true)
class Genre {
  final int genreId;
  final String name;
  final DateTime createdAt;
  final DateTime updatedAt;

  Genre({
    required this.genreId,
    required this.name,
    required this.createdAt,
    required this.updatedAt,
  });

  factory Genre.fromJson(Map<String, dynamic> json) => _$GenreFromJson(json);

  Map<String, dynamic> toJson() => _$GenreToJson(this);
}

@JsonSerializable(fieldRename: FieldRename.snake, explicitToJson: true)
class Story {
  final int storyId;
  final String wattId;
  final int authorId;
  final String title;
  final String description;
  final int genreId;
  final int? imageId;
  final bool isDeleted;
  final bool isFamilyFriendly;
  final bool isFree;
  final String language;
  final String? url;
  final String ageRange;
  final DateTime?
  dateCreated; // SQL DATE: stored/serialized as ISO-8601 date string
  final DateTime? dateModified; // SQL DATE
  final DateTime? datePublished; // SQL DATE
  final DateTime createdAt;
  final DateTime updatedAt;

  Story({
    required this.storyId,
    required this.wattId,
    required this.authorId,
    required this.title,
    required this.description,
    required this.genreId,
    this.imageId,
    required this.isDeleted,
    required this.isFamilyFriendly,
    required this.isFree,
    required this.language,
    this.url,
    required this.ageRange,
    this.dateCreated,
    this.dateModified,
    this.datePublished,
    required this.createdAt,
    required this.updatedAt,
  });

  factory Story.fromJson(Map<String, dynamic> json) => _$StoryFromJson(json);

  Map<String, dynamic> toJson() => _$StoryToJson(this);
}

List<Story> storyListFromJson(dynamic data) {
  if (data is String) {
    final decoded = jsonDecode(data);
    if (decoded is List) {
      return decoded
          .map((e) => Story.fromJson(Map<String, dynamic>.from(e as Map)))
          .toList();
    } else {
      throw const FormatException('Expected a JSON array string for stories');
    }
  } else if (data is List) {
    return data
        .map((e) => Story.fromJson(Map<String, dynamic>.from(e as Map)))
        .toList();
  } else {
    throw const FormatException(
      'Expected a JSON array (or JSON string) for stories',
    );
  }
}

dynamic storyListToJson(List<Story> stories) =>
    stories.map((s) => s.toJson()).toList();

@JsonSerializable(fieldRename: FieldRename.snake, explicitToJson: true)
class StoryTag {
  final int storyId;
  final int tagId;

  StoryTag({required this.storyId, required this.tagId});

  factory StoryTag.fromJson(Map<String, dynamic> json) =>
      _$StoryTagFromJson(json);

  Map<String, dynamic> toJson() => _$StoryTagToJson(this);
}

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

@JsonSerializable(fieldRename: FieldRename.snake, explicitToJson: true)
class AppNotification {
  final int notificationId;
  final int storyId;
  final NotificationType notificationType;
  final String message;
  final bool isRead;
  final DateTime createdAt;
  final DateTime updatedAt;

  AppNotification({
    required this.notificationId,
    required this.storyId,
    required this.notificationType,
    required this.message,
    required this.isRead,
    required this.createdAt,
    required this.updatedAt,
  });

  factory AppNotification.fromJson(Map<String, dynamic> json) =>
      _$AppNotificationFromJson(json);

  Map<String, dynamic> toJson() => _$AppNotificationToJson(this);
}

// ---------- Log Tables ----------

@JsonSerializable(fieldRename: FieldRename.snake, explicitToJson: true)
class ErrorLog {
  final int errorLogId;
  final DateTime timesTamp; // note: column name is 'times_tamp' (kept as-is)
  final String source;
  final String message;
  final String context;

  ErrorLog({
    required this.errorLogId,
    required this.timesTamp,
    required this.source,
    required this.message,
    required this.context,
  });

  factory ErrorLog.fromJson(Map<String, dynamic> json) =>
      _$ErrorLogFromJson(json);

  Map<String, dynamic> toJson() => _$ErrorLogToJson(this);
}

@JsonSerializable(fieldRename: FieldRename.snake, explicitToJson: true)
class ActionLog {
  final int actionLogId;
  final String dataBefore;
  final String dataAfter;
  final int effectedKey;
  final String effectedTable;
  final OperationType operation;
  final DateTime timesTamp; // note: column name is 'times_tamp' (kept as-is)

  ActionLog({
    required this.actionLogId,
    required this.dataBefore,
    required this.dataAfter,
    required this.effectedKey,
    required this.effectedTable,
    required this.operation,
    required this.timesTamp,
  });

  factory ActionLog.fromJson(Map<String, dynamic> json) =>
      _$ActionLogFromJson(json);

  Map<String, dynamic> toJson() => _$ActionLogToJson(this);
}

// ---------- Enums (from 000003_enums.up.sql) ----------

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

// ---------- Tables (from 000005_core_tables.up.sql) ----------

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

@JsonSerializable(fieldRename: FieldRename.snake, explicitToJson: true)
class Part {
  final int partId;
  final String wattId;
  final int? idx; // smallint in DB
  final String title;
  final DateTime datePublished; // SQL DATE
  final int? imageId; // FK to media
  final int? videoId; // FK to media (YouTube)
  final bool isDeleted;
  final String href;
  final int votes; // bigint
  final DateTime createdAt;
  final DateTime updatedAt;

  Part({
    required this.partId,
    required this.wattId,
    this.idx,
    required this.title,
    required this.datePublished,
    this.imageId,
    this.videoId,
    required this.isDeleted,
    required this.href,
    required this.votes,
    required this.createdAt,
    required this.updatedAt,
  });

  factory Part.fromJson(Map<String, dynamic> json) => _$PartFromJson(json);

  Map<String, dynamic> toJson() => _$PartToJson(this);
}

@JsonSerializable(fieldRename: FieldRename.snake, explicitToJson: true)
class Paragraph {
  final int paragraphId;
  final String? wattId;
  final int idx; // bigint
  final int partId;
  final Direction direction;
  final ContentType contentType;
  final String? content;
  final String? contentText; // generated column in DB
  final int? mediaId;
  final Media? media;
  final int commentsCount;

  Paragraph({
    required this.paragraphId,
    this.wattId,
    required this.idx,
    required this.partId,
    required this.direction,
    required this.contentType,
    this.content,
    this.contentText,
    this.mediaId,
    this.media,
    this.commentsCount = 0,
  });

  factory Paragraph.fromJson(Map<String, dynamic> json) =>
      _$ParagraphFromJson(json);

  Map<String, dynamic> toJson() => _$ParagraphToJson(this);
}

@JsonSerializable(fieldRename: FieldRename.snake, explicitToJson: true)
class Comment {
  final int commentId;
  final String wattId;
  final String text;
  final String userName;
  final int likes;
  final int partId;
  final int? paragraphId;
  final int? parentCommentId;
  final int? depth; // smallint
  final ParentType parentType;
  final String? wattParentId;
  final bool isDeleted;
  final String? link;
  final DateTime? dateCreated;
  final DateTime? dateModified;
  final int repliesCount;
  final DateTime createdAt;
  final DateTime updatedAt;

  Comment({
    required this.commentId,
    required this.wattId,
    required this.text,
    required this.userName,
    required this.likes,
    required this.partId,
    this.paragraphId,
    this.parentCommentId,
    this.depth,
    required this.parentType,
    this.wattParentId,
    required this.isDeleted,
    this.link,
    this.dateCreated,
    this.dateModified,
    this.repliesCount = 0,
    required this.createdAt,
    required this.updatedAt,
  });

  factory Comment.fromJson(Map<String, dynamic> json) =>
      _$CommentFromJson(json);

  Map<String, dynamic> toJson() => _$CommentToJson(this);
}
