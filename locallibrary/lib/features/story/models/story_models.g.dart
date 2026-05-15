// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'story_models.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

Tag _$TagFromJson(Map<String, dynamic> json) => Tag(
  tagId: (json['tag_id'] as num).toInt(),
  name: json['name'] as String,
  createdAt: DateTime.parse(json['created_at'] as String),
  updatedAt: DateTime.parse(json['updated_at'] as String),
);

Map<String, dynamic> _$TagToJson(Tag instance) => <String, dynamic>{
  'tag_id': instance.tagId,
  'name': instance.name,
  'created_at': instance.createdAt.toIso8601String(),
  'updated_at': instance.updatedAt.toIso8601String(),
};

Author _$AuthorFromJson(Map<String, dynamic> json) => Author(
  authorId: (json['author_id'] as num).toInt(),
  name: json['name'] as String,
  profileUrl: json['profile_url'] as String,
  username: json['username'] as String,
  createdAt: DateTime.parse(json['created_at'] as String),
  updatedAt: DateTime.parse(json['updated_at'] as String),
);

Map<String, dynamic> _$AuthorToJson(Author instance) => <String, dynamic>{
  'author_id': instance.authorId,
  'name': instance.name,
  'profile_url': instance.profileUrl,
  'username': instance.username,
  'created_at': instance.createdAt.toIso8601String(),
  'updated_at': instance.updatedAt.toIso8601String(),
};

Genre _$GenreFromJson(Map<String, dynamic> json) => Genre(
  genreId: (json['genre_id'] as num).toInt(),
  name: json['name'] as String,
  createdAt: DateTime.parse(json['created_at'] as String),
  updatedAt: DateTime.parse(json['updated_at'] as String),
);

Map<String, dynamic> _$GenreToJson(Genre instance) => <String, dynamic>{
  'genre_id': instance.genreId,
  'name': instance.name,
  'created_at': instance.createdAt.toIso8601String(),
  'updated_at': instance.updatedAt.toIso8601String(),
};

Story _$StoryFromJson(Map<String, dynamic> json) => Story(
  storyId: (json['story_id'] as num).toInt(),
  wattId: json['watt_id'] as String,
  authorId: (json['author_id'] as num).toInt(),
  title: json['title'] as String,
  description: json['description'] as String,
  genreId: (json['genre_id'] as num).toInt(),
  imageId: (json['image_id'] as num?)?.toInt(),
  isDeleted: json['is_deleted'] as bool,
  isFamilyFriendly: json['is_family_friendly'] as bool,
  isFree: json['is_free'] as bool,
  language: json['language'] as String,
  url: json['url'] as String?,
  ageRange: json['age_range'] as String,
  dateCreated: json['date_created'] == null
      ? null
      : DateTime.parse(json['date_created'] as String),
  dateModified: json['date_modified'] == null
      ? null
      : DateTime.parse(json['date_modified'] as String),
  datePublished: json['date_published'] == null
      ? null
      : DateTime.parse(json['date_published'] as String),
  createdAt: DateTime.parse(json['created_at'] as String),
  updatedAt: DateTime.parse(json['updated_at'] as String),
);

Map<String, dynamic> _$StoryToJson(Story instance) => <String, dynamic>{
  'story_id': instance.storyId,
  'watt_id': instance.wattId,
  'author_id': instance.authorId,
  'title': instance.title,
  'description': instance.description,
  'genre_id': instance.genreId,
  'image_id': instance.imageId,
  'is_deleted': instance.isDeleted,
  'is_family_friendly': instance.isFamilyFriendly,
  'is_free': instance.isFree,
  'language': instance.language,
  'url': instance.url,
  'age_range': instance.ageRange,
  'date_created': instance.dateCreated?.toIso8601String(),
  'date_modified': instance.dateModified?.toIso8601String(),
  'date_published': instance.datePublished?.toIso8601String(),
  'created_at': instance.createdAt.toIso8601String(),
  'updated_at': instance.updatedAt.toIso8601String(),
};

StoryTag _$StoryTagFromJson(Map<String, dynamic> json) => StoryTag(
  storyId: (json['story_id'] as num).toInt(),
  tagId: (json['tag_id'] as num).toInt(),
);

Map<String, dynamic> _$StoryTagToJson(StoryTag instance) => <String, dynamic>{
  'story_id': instance.storyId,
  'tag_id': instance.tagId,
};

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

AppNotification _$AppNotificationFromJson(Map<String, dynamic> json) =>
    AppNotification(
      notificationId: (json['notification_id'] as num).toInt(),
      storyId: (json['story_id'] as num).toInt(),
      notificationType: $enumDecode(
        _$NotificationTypeEnumMap,
        json['notification_type'],
      ),
      message: json['message'] as String,
      isRead: json['is_read'] as bool,
      createdAt: DateTime.parse(json['created_at'] as String),
      updatedAt: DateTime.parse(json['updated_at'] as String),
    );

Map<String, dynamic> _$AppNotificationToJson(
  AppNotification instance,
) => <String, dynamic>{
  'notification_id': instance.notificationId,
  'story_id': instance.storyId,
  'notification_type': _$NotificationTypeEnumMap[instance.notificationType]!,
  'message': instance.message,
  'is_read': instance.isRead,
  'created_at': instance.createdAt.toIso8601String(),
  'updated_at': instance.updatedAt.toIso8601String(),
};

const _$NotificationTypeEnumMap = {
  NotificationType.partAdded: 'part_added',
  NotificationType.partDeleted: 'part_deleted',
  NotificationType.storyAdded: 'story_added',
  NotificationType.storyDeleted: 'story_deleted',
  NotificationType.authorComment: 'author_comment',
};

ErrorLog _$ErrorLogFromJson(Map<String, dynamic> json) => ErrorLog(
  errorLogId: (json['error_log_id'] as num).toInt(),
  timesTamp: DateTime.parse(json['times_tamp'] as String),
  source: json['source'] as String,
  message: json['message'] as String,
  context: json['context'] as String,
);

Map<String, dynamic> _$ErrorLogToJson(ErrorLog instance) => <String, dynamic>{
  'error_log_id': instance.errorLogId,
  'times_tamp': instance.timesTamp.toIso8601String(),
  'source': instance.source,
  'message': instance.message,
  'context': instance.context,
};

ActionLog _$ActionLogFromJson(Map<String, dynamic> json) => ActionLog(
  actionLogId: (json['action_log_id'] as num).toInt(),
  dataBefore: json['data_before'] as String,
  dataAfter: json['data_after'] as String,
  effectedKey: (json['effected_key'] as num).toInt(),
  effectedTable: json['effected_table'] as String,
  operation: $enumDecode(_$OperationTypeEnumMap, json['operation']),
  timesTamp: DateTime.parse(json['times_tamp'] as String),
);

Map<String, dynamic> _$ActionLogToJson(ActionLog instance) => <String, dynamic>{
  'action_log_id': instance.actionLogId,
  'data_before': instance.dataBefore,
  'data_after': instance.dataAfter,
  'effected_key': instance.effectedKey,
  'effected_table': instance.effectedTable,
  'operation': _$OperationTypeEnumMap[instance.operation]!,
  'times_tamp': instance.timesTamp.toIso8601String(),
};

const _$OperationTypeEnumMap = {
  OperationType.insert: 'insert',
  OperationType.update: 'update',
  OperationType.delete: 'delete',
};

Media _$MediaFromJson(Map<String, dynamic> json) => Media(
  mediaId: (json['media_id'] as num).toInt(),
  uuid: json['uuid'] as String,
  type: $enumDecode(_$MediaTypeEnumMap, json['type']),
  url: json['url'] as String?,
  path: json['path'] as String?,
);

Map<String, dynamic> _$MediaToJson(Media instance) => <String, dynamic>{
  'media_id': instance.mediaId,
  'uuid': instance.uuid,
  'type': _$MediaTypeEnumMap[instance.type]!,
  'url': instance.url,
  'path': instance.path,
};

const _$MediaTypeEnumMap = {
  MediaType.video: 'video',
  MediaType.audio: 'audio',
  MediaType.image: 'image',
  MediaType.link: 'link',
};

Part _$PartFromJson(Map<String, dynamic> json) => Part(
  partId: (json['part_id'] as num).toInt(),
  wattId: json['watt_id'] as String,
  idx: (json['idx'] as num?)?.toInt(),
  title: json['title'] as String,
  datePublished: DateTime.parse(json['date_published'] as String),
  imageId: (json['image_id'] as num?)?.toInt(),
  videoId: (json['video_id'] as num?)?.toInt(),
  isDeleted: json['is_deleted'] as bool,
  href: json['href'] as String,
  votes: (json['votes'] as num).toInt(),
  createdAt: DateTime.parse(json['created_at'] as String),
  updatedAt: DateTime.parse(json['updated_at'] as String),
);

Map<String, dynamic> _$PartToJson(Part instance) => <String, dynamic>{
  'part_id': instance.partId,
  'watt_id': instance.wattId,
  'idx': instance.idx,
  'title': instance.title,
  'date_published': instance.datePublished.toIso8601String(),
  'image_id': instance.imageId,
  'video_id': instance.videoId,
  'is_deleted': instance.isDeleted,
  'href': instance.href,
  'votes': instance.votes,
  'created_at': instance.createdAt.toIso8601String(),
  'updated_at': instance.updatedAt.toIso8601String(),
};

Paragraph _$ParagraphFromJson(Map<String, dynamic> json) => Paragraph(
  paragraphId: (json['paragraph_id'] as num).toInt(),
  wattId: json['watt_id'] as String?,
  idx: (json['idx'] as num).toInt(),
  partId: (json['part_id'] as num).toInt(),
  direction: $enumDecode(_$DirectionEnumMap, json['direction']),
  contentType: $enumDecode(_$ContentTypeEnumMap, json['content_type']),
  content: json['content'] as String?,
  contentText: json['content_text'] as String?,
  mediaId: (json['media_id'] as num?)?.toInt(),
  media: json['media'] == null
      ? null
      : Media.fromJson(json['media'] as Map<String, dynamic>),
  commentsCount: (json['comments_count'] as num?)?.toInt() ?? 0,
);

Map<String, dynamic> _$ParagraphToJson(Paragraph instance) => <String, dynamic>{
  'paragraph_id': instance.paragraphId,
  'watt_id': instance.wattId,
  'idx': instance.idx,
  'part_id': instance.partId,
  'direction': _$DirectionEnumMap[instance.direction]!,
  'content_type': _$ContentTypeEnumMap[instance.contentType]!,
  'content': instance.content,
  'content_text': instance.contentText,
  'media_id': instance.mediaId,
  'media': instance.media?.toJson(),
  'comments_count': instance.commentsCount,
};

const _$DirectionEnumMap = {Direction.rtl: 'RTL', Direction.ltr: 'LTR'};

const _$ContentTypeEnumMap = {
  ContentType.text: 'text',
  ContentType.image: 'image',
  ContentType.video: 'video',
  ContentType.link: 'link',
};

Comment _$CommentFromJson(Map<String, dynamic> json) => Comment(
  commentId: (json['comment_id'] as num).toInt(),
  wattId: json['watt_id'] as String,
  text: json['text'] as String,
  userName: json['user_name'] as String,
  likes: (json['likes'] as num).toInt(),
  partId: (json['part_id'] as num).toInt(),
  paragraphId: (json['paragraph_id'] as num?)?.toInt(),
  parentCommentId: (json['parent_comment_id'] as num?)?.toInt(),
  depth: (json['depth'] as num?)?.toInt(),
  parentType: $enumDecode(_$ParentTypeEnumMap, json['parent_type']),
  wattParentId: json['watt_parent_id'] as String?,
  isDeleted: json['is_deleted'] as bool,
  link: json['link'] as String?,
  dateCreated: json['date_created'] == null
      ? null
      : DateTime.parse(json['date_created'] as String),
  dateModified: json['date_modified'] == null
      ? null
      : DateTime.parse(json['date_modified'] as String),
  repliesCount: (json['replies_count'] as num?)?.toInt() ?? 0,
  createdAt: DateTime.parse(json['created_at'] as String),
  updatedAt: DateTime.parse(json['updated_at'] as String),
);

Map<String, dynamic> _$CommentToJson(Comment instance) => <String, dynamic>{
  'comment_id': instance.commentId,
  'watt_id': instance.wattId,
  'text': instance.text,
  'user_name': instance.userName,
  'likes': instance.likes,
  'part_id': instance.partId,
  'paragraph_id': instance.paragraphId,
  'parent_comment_id': instance.parentCommentId,
  'depth': instance.depth,
  'parent_type': _$ParentTypeEnumMap[instance.parentType]!,
  'watt_parent_id': instance.wattParentId,
  'is_deleted': instance.isDeleted,
  'link': instance.link,
  'date_created': instance.dateCreated?.toIso8601String(),
  'date_modified': instance.dateModified?.toIso8601String(),
  'replies_count': instance.repliesCount,
  'created_at': instance.createdAt.toIso8601String(),
  'updated_at': instance.updatedAt.toIso8601String(),
};

const _$ParentTypeEnumMap = {
  ParentType.paragraph: 'paragraph',
  ParentType.comment: 'comment',
  ParentType.part: 'part',
};
