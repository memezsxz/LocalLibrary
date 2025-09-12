import 'package:json_annotation/json_annotation.dart';

part 'logs.g.dart';

@JsonSerializable(fieldRename: FieldRename.snake, explicitToJson: true)
class BaseLog {
  final DateTime ts;
  final String level;
  final String logger;
  final String? event;
  final String? spider;
  final String? message; // for generic logs

  BaseLog({
    required this.ts,
    required this.level,
    required this.logger,
    this.event,
    this.spider,
    this.message,
  });

  factory BaseLog.fromJson(Map<String, dynamic> json) => _$BaseLogFromJson(json);
  Map<String, dynamic> toJson() => _$BaseLogToJson(this);
}

@JsonSerializable(fieldRename: FieldRename.snake, explicitToJson: true)
class JobStartLog extends BaseLog {
  final String cmd;
  final String jobDir;
  final JobStartRequest request;

  JobStartLog({
    required super.ts,
    required super.level,
    required super.logger,
    super.event,
    super.spider,
    super.message,
    required this.cmd,
    required this.jobDir,
    required this.request,
  });

  factory JobStartLog.fromJson(Map<String, dynamic> json) =>
      _$JobStartLogFromJson(json);

  @override
  Map<String, dynamic> toJson() => _$JobStartLogToJson(this);
}

@JsonSerializable(fieldRename: FieldRename.snake, explicitToJson: true)
class JobStartRequest {
  final String? storyUrl;
  final String? partUrl;

  JobStartRequest({this.storyUrl, this.partUrl});

  factory JobStartRequest.fromJson(Map<String, dynamic> json) =>
      _$JobStartRequestFromJson(json);
  Map<String, dynamic> toJson() => _$JobStartRequestToJson(this);
}

@JsonSerializable(fieldRename: FieldRename.snake, explicitToJson: true)
class CommentsPageLog extends BaseLog {
  final String partId;
  final int pageSize;
  final int totalSoFar;

  CommentsPageLog({
    required super.ts,
    required super.level,
    required super.logger,
    super.event,
    super.spider,
    super.message,
    required this.partId,
    required this.pageSize,
    required this.totalSoFar,
  });

  factory CommentsPageLog.fromJson(Map<String, dynamic> json) =>
      _$CommentsPageLogFromJson(json);

  @override
  Map<String, dynamic> toJson() => _$CommentsPageLogToJson(this);
}

@JsonSerializable(fieldRename: FieldRename.snake, explicitToJson: true)
class JobEndLog extends BaseLog {
  final String cmd;
  final String jobDir;

  JobEndLog({
    required super.ts,
    required super.level,
    required super.logger,
    super.event,
    super.spider,
    super.message,
    required this.cmd,
    required this.jobDir,
  });

  factory JobEndLog.fromJson(Map<String, dynamic> json) =>
      _$JobEndLogFromJson(json);
  @override
  Map<String, dynamic> toJson() => _$JobEndLogToJson(this);
}

@JsonSerializable(fieldRename: FieldRename.snake, explicitToJson: true)
class SpiderOpenedLog extends BaseLog {
  final String spiderName;
  final String? currentUrl;
  final String? outputDir;
  final int? limit;
  final int? offset;
  final bool? useStoryDetailsFile;
  final int? startUrlsCount;

  SpiderOpenedLog({
    required super.ts,
    required super.level,
    required super.logger,
    super.event,
    super.spider,
    super.message,
    required this.spiderName,
    this.currentUrl,
    this.outputDir,
    this.limit,
    this.offset,
    this.useStoryDetailsFile,
    this.startUrlsCount,
  });

  factory SpiderOpenedLog.fromJson(Map<String, dynamic> json) =>
      _$SpiderOpenedLogFromJson(json);
  @override
  Map<String, dynamic> toJson() => _$SpiderOpenedLogToJson(this);
}

@JsonSerializable(fieldRename: FieldRename.snake, explicitToJson: true)
class SpiderClosedLog extends BaseLog {
  final String spiderName;
  final String reason;
  final Map<String, dynamic> stats;

  SpiderClosedLog({
    required super.ts,
    required super.level,
    required super.logger,
    super.event,
    super.spider,
    super.message,
    required this.spiderName,
    required this.reason,
    required this.stats,
  });

  factory SpiderClosedLog.fromJson(Map<String, dynamic> json) =>
      _$SpiderClosedLogFromJson(json);
  @override
  Map<String, dynamic> toJson() => _$SpiderClosedLogToJson(this);
}

@JsonSerializable(fieldRename: FieldRename.snake, explicitToJson: true)
class CommentsBatchingStartLog extends BaseLog {
  final String partId;
  final int totalComments;
  final int batchSize;
  final int batches;
  final String pathBase;

  CommentsBatchingStartLog({
    required super.ts,
    required super.level,
    required super.logger,
    super.event,
    super.spider,
    super.message,
    required this.partId,
    required this.totalComments,
    required this.batchSize,
    required this.batches,
    required this.pathBase,
  });

  factory CommentsBatchingStartLog.fromJson(Map<String, dynamic> json) =>
      _$CommentsBatchingStartLogFromJson(json);
  @override
  Map<String, dynamic> toJson() => _$CommentsBatchingStartLogToJson(this);
}

@JsonSerializable(fieldRename: FieldRename.snake, explicitToJson: true)
class CommentsBatchSavedLog extends BaseLog {
  final String partId;
  final int batchIndex;
  final int batches;
  final int start;
  final int end;
  final int count;
  final String filename;
  final String path;

  CommentsBatchSavedLog({
    required super.ts,
    required super.level,
    required super.logger,
    super.event,
    super.spider,
    super.message,
    required this.partId,
    required this.batchIndex,
    required this.batches,
    required this.start,
    required this.end,
    required this.count,
    required this.filename,
    required this.path,
  });

  factory CommentsBatchSavedLog.fromJson(Map<String, dynamic> json) =>
      _$CommentsBatchSavedLogFromJson(json);
  @override
  Map<String, dynamic> toJson() => _$CommentsBatchSavedLogToJson(this);
}

@JsonSerializable(fieldRename: FieldRename.snake, explicitToJson: true)
class ItemScrapedLog extends BaseLog {
  final String itemType;
  final String spiderName;
  final String? partId;        // comments/part
  final String? wattId;        // story
  final String? url;           // story
  final String? responseUrl;   // comments/part
  final int? commentsCount;    // comments

  ItemScrapedLog({
    required super.ts,
    required super.level,
    required super.logger,
    super.event,
    super.spider,
    super.message,
    required this.itemType,
    required this.spiderName,
    this.partId,
    this.wattId,
    this.url,
    this.responseUrl,
    this.commentsCount,
  });

  factory ItemScrapedLog.fromJson(Map<String, dynamic> json) =>
      _$ItemScrapedLogFromJson(json);
  @override
  Map<String, dynamic> toJson() => _$ItemScrapedLogToJson(this);
}

// ===== Optional: generic log for unknown events (keeps original map) =====

@JsonSerializable(fieldRename: FieldRename.snake, explicitToJson: true)
class GenericLog extends BaseLog {
  final Map<String, dynamic>? extra; // anything else

  GenericLog({
    required super.ts,
    required super.level,
    required super.logger,
    super.event,
    super.spider,
    super.message,
    this.extra,
  });

  factory GenericLog.fromJson(Map<String, dynamic> json) =>
      _$GenericLogFromJson(json);
  @override
  Map<String, dynamic> toJson() => _$GenericLogToJson(this);
}

// ===== Helper: parse to the right model by `event` =====

BaseLog parseAnyLog(Map<String, dynamic> json) {
  final ev = json['event'] as String?;
  switch (ev) {
    case 'job.start':
      return JobStartLog.fromJson(json);
    case 'job.end':
      return JobEndLog.fromJson(json);
    case 'spider.opened':
      return SpiderOpenedLog.fromJson(json);
    case 'spider.closed':
      return SpiderClosedLog.fromJson(json);
    case 'comments.page':
      return CommentsPageLog.fromJson(json);
    case 'comments.batching.start':
      return CommentsBatchingStartLog.fromJson(json);
    case 'comments.batch.saved':
      return CommentsBatchSavedLog.fromJson(json);
    case 'item.scraped':
      return ItemScrapedLog.fromJson(json);
    default:
    // falls back to a generic entry; you can also return BaseLog.fromJson(json)
    // if you don't need to carry unknown fields.
      final base = BaseLog.fromJson(json);
      return GenericLog(
        ts: base.ts,
        level: base.level,
        logger: base.logger,
        event: base.event,
        spider: base.spider,
        message: base.message,
        extra: Map<String, dynamic>.from(json),
      );
  }
}
