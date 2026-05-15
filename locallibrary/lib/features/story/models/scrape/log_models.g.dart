// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'log_models.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

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
