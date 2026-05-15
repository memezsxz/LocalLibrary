import 'package:json_annotation/json_annotation.dart';

import '../domain/story_enums.dart';

part 'log_models.g.dart';

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
