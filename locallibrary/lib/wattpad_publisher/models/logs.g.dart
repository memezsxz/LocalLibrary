// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'logs.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

BaseLog _$BaseLogFromJson(Map<String, dynamic> json) => BaseLog(
  ts: DateTime.parse(json['ts'] as String),
  level: json['level'] as String,
  logger: json['logger'] as String,
  event: json['event'] as String?,
  spider: json['spider'] as String?,
  message: json['message'] as String?,
);

Map<String, dynamic> _$BaseLogToJson(BaseLog instance) => <String, dynamic>{
  'ts': instance.ts.toIso8601String(),
  'level': instance.level,
  'logger': instance.logger,
  'event': instance.event,
  'spider': instance.spider,
  'message': instance.message,
};

JobStartLog _$JobStartLogFromJson(Map<String, dynamic> json) => JobStartLog(
  ts: DateTime.parse(json['ts'] as String),
  level: json['level'] as String,
  logger: json['logger'] as String,
  event: json['event'] as String?,
  spider: json['spider'] as String?,
  message: json['message'] as String?,
  cmd: json['cmd'] as String,
  jobDir: json['job_dir'] as String,
  request: JobStartRequest.fromJson(json['request'] as Map<String, dynamic>),
);

Map<String, dynamic> _$JobStartLogToJson(JobStartLog instance) =>
    <String, dynamic>{
      'ts': instance.ts.toIso8601String(),
      'level': instance.level,
      'logger': instance.logger,
      'event': instance.event,
      'spider': instance.spider,
      'message': instance.message,
      'cmd': instance.cmd,
      'job_dir': instance.jobDir,
      'request': instance.request.toJson(),
    };

JobStartRequest _$JobStartRequestFromJson(Map<String, dynamic> json) =>
    JobStartRequest(
      storyUrl: json['story_url'] as String?,
      partUrl: json['part_url'] as String?,
    );

Map<String, dynamic> _$JobStartRequestToJson(JobStartRequest instance) =>
    <String, dynamic>{
      'story_url': instance.storyUrl,
      'part_url': instance.partUrl,
    };

CommentsPageLog _$CommentsPageLogFromJson(Map<String, dynamic> json) =>
    CommentsPageLog(
      ts: DateTime.parse(json['ts'] as String),
      level: json['level'] as String,
      logger: json['logger'] as String,
      event: json['event'] as String?,
      spider: json['spider'] as String?,
      message: json['message'] as String?,
      partId: json['part_id'] as String,
      pageSize: (json['page_size'] as num).toInt(),
      totalSoFar: (json['total_so_far'] as num).toInt(),
    );

Map<String, dynamic> _$CommentsPageLogToJson(CommentsPageLog instance) =>
    <String, dynamic>{
      'ts': instance.ts.toIso8601String(),
      'level': instance.level,
      'logger': instance.logger,
      'event': instance.event,
      'spider': instance.spider,
      'message': instance.message,
      'part_id': instance.partId,
      'page_size': instance.pageSize,
      'total_so_far': instance.totalSoFar,
    };

JobEndLog _$JobEndLogFromJson(Map<String, dynamic> json) => JobEndLog(
  ts: DateTime.parse(json['ts'] as String),
  level: json['level'] as String,
  logger: json['logger'] as String,
  event: json['event'] as String?,
  spider: json['spider'] as String?,
  message: json['message'] as String?,
  cmd: json['cmd'] as String,
  jobDir: json['job_dir'] as String,
);

Map<String, dynamic> _$JobEndLogToJson(JobEndLog instance) => <String, dynamic>{
  'ts': instance.ts.toIso8601String(),
  'level': instance.level,
  'logger': instance.logger,
  'event': instance.event,
  'spider': instance.spider,
  'message': instance.message,
  'cmd': instance.cmd,
  'job_dir': instance.jobDir,
};

SpiderOpenedLog _$SpiderOpenedLogFromJson(Map<String, dynamic> json) =>
    SpiderOpenedLog(
      ts: DateTime.parse(json['ts'] as String),
      level: json['level'] as String,
      logger: json['logger'] as String,
      event: json['event'] as String?,
      spider: json['spider'] as String?,
      message: json['message'] as String?,
      spiderName: json['spider_name'] as String,
      currentUrl: json['current_url'] as String?,
      outputDir: json['output_dir'] as String?,
      limit: (json['limit'] as num?)?.toInt(),
      offset: (json['offset'] as num?)?.toInt(),
      useStoryDetailsFile: json['use_story_details_file'] as bool?,
      startUrlsCount: (json['start_urls_count'] as num?)?.toInt(),
    );

Map<String, dynamic> _$SpiderOpenedLogToJson(SpiderOpenedLog instance) =>
    <String, dynamic>{
      'ts': instance.ts.toIso8601String(),
      'level': instance.level,
      'logger': instance.logger,
      'event': instance.event,
      'spider': instance.spider,
      'message': instance.message,
      'spider_name': instance.spiderName,
      'current_url': instance.currentUrl,
      'output_dir': instance.outputDir,
      'limit': instance.limit,
      'offset': instance.offset,
      'use_story_details_file': instance.useStoryDetailsFile,
      'start_urls_count': instance.startUrlsCount,
    };

SpiderClosedLog _$SpiderClosedLogFromJson(Map<String, dynamic> json) =>
    SpiderClosedLog(
      ts: DateTime.parse(json['ts'] as String),
      level: json['level'] as String,
      logger: json['logger'] as String,
      event: json['event'] as String?,
      spider: json['spider'] as String?,
      message: json['message'] as String?,
      spiderName: json['spider_name'] as String,
      reason: json['reason'] as String,
      stats: json['stats'] as Map<String, dynamic>,
    );

Map<String, dynamic> _$SpiderClosedLogToJson(SpiderClosedLog instance) =>
    <String, dynamic>{
      'ts': instance.ts.toIso8601String(),
      'level': instance.level,
      'logger': instance.logger,
      'event': instance.event,
      'spider': instance.spider,
      'message': instance.message,
      'spider_name': instance.spiderName,
      'reason': instance.reason,
      'stats': instance.stats,
    };

CommentsBatchingStartLog _$CommentsBatchingStartLogFromJson(
  Map<String, dynamic> json,
) => CommentsBatchingStartLog(
  ts: DateTime.parse(json['ts'] as String),
  level: json['level'] as String,
  logger: json['logger'] as String,
  event: json['event'] as String?,
  spider: json['spider'] as String?,
  message: json['message'] as String?,
  partId: json['part_id'] as String,
  totalComments: (json['total_comments'] as num).toInt(),
  batchSize: (json['batch_size'] as num).toInt(),
  batches: (json['batches'] as num).toInt(),
  pathBase: json['path_base'] as String,
);

Map<String, dynamic> _$CommentsBatchingStartLogToJson(
  CommentsBatchingStartLog instance,
) => <String, dynamic>{
  'ts': instance.ts.toIso8601String(),
  'level': instance.level,
  'logger': instance.logger,
  'event': instance.event,
  'spider': instance.spider,
  'message': instance.message,
  'part_id': instance.partId,
  'total_comments': instance.totalComments,
  'batch_size': instance.batchSize,
  'batches': instance.batches,
  'path_base': instance.pathBase,
};

CommentsBatchSavedLog _$CommentsBatchSavedLogFromJson(
  Map<String, dynamic> json,
) => CommentsBatchSavedLog(
  ts: DateTime.parse(json['ts'] as String),
  level: json['level'] as String,
  logger: json['logger'] as String,
  event: json['event'] as String?,
  spider: json['spider'] as String?,
  message: json['message'] as String?,
  partId: json['part_id'] as String,
  batchIndex: (json['batch_index'] as num).toInt(),
  batches: (json['batches'] as num).toInt(),
  start: (json['start'] as num).toInt(),
  end: (json['end'] as num).toInt(),
  count: (json['count'] as num).toInt(),
  filename: json['filename'] as String,
  path: json['path'] as String,
);

Map<String, dynamic> _$CommentsBatchSavedLogToJson(
  CommentsBatchSavedLog instance,
) => <String, dynamic>{
  'ts': instance.ts.toIso8601String(),
  'level': instance.level,
  'logger': instance.logger,
  'event': instance.event,
  'spider': instance.spider,
  'message': instance.message,
  'part_id': instance.partId,
  'batch_index': instance.batchIndex,
  'batches': instance.batches,
  'start': instance.start,
  'end': instance.end,
  'count': instance.count,
  'filename': instance.filename,
  'path': instance.path,
};

ItemScrapedLog _$ItemScrapedLogFromJson(Map<String, dynamic> json) =>
    ItemScrapedLog(
      ts: DateTime.parse(json['ts'] as String),
      level: json['level'] as String,
      logger: json['logger'] as String,
      event: json['event'] as String?,
      spider: json['spider'] as String?,
      message: json['message'] as String?,
      itemType: json['item_type'] as String,
      spiderName: json['spider_name'] as String,
      partId: json['part_id'] as String?,
      wattId: json['watt_id'] as String?,
      url: json['url'] as String?,
      responseUrl: json['response_url'] as String?,
      commentsCount: (json['comments_count'] as num?)?.toInt(),
    );

Map<String, dynamic> _$ItemScrapedLogToJson(ItemScrapedLog instance) =>
    <String, dynamic>{
      'ts': instance.ts.toIso8601String(),
      'level': instance.level,
      'logger': instance.logger,
      'event': instance.event,
      'spider': instance.spider,
      'message': instance.message,
      'item_type': instance.itemType,
      'spider_name': instance.spiderName,
      'part_id': instance.partId,
      'watt_id': instance.wattId,
      'url': instance.url,
      'response_url': instance.responseUrl,
      'comments_count': instance.commentsCount,
    };

GenericLog _$GenericLogFromJson(Map<String, dynamic> json) => GenericLog(
  ts: DateTime.parse(json['ts'] as String),
  level: json['level'] as String,
  logger: json['logger'] as String,
  event: json['event'] as String?,
  spider: json['spider'] as String?,
  message: json['message'] as String?,
  extra: json['extra'] as Map<String, dynamic>?,
);

Map<String, dynamic> _$GenericLogToJson(GenericLog instance) =>
    <String, dynamic>{
      'ts': instance.ts.toIso8601String(),
      'level': instance.level,
      'logger': instance.logger,
      'event': instance.event,
      'spider': instance.spider,
      'message': instance.message,
      'extra': instance.extra,
    };
