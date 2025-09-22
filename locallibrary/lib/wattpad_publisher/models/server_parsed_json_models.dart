import 'package:json_annotation/json_annotation.dart';

part 'server_parsed_json_models.g.dart';

@JsonSerializable(explicitToJson: true, fieldRename: FieldRename.snake)
class PartLink {
  @JsonKey(fromJson: _asNonEmptyString)
  final String wattId;
  final String? url;

  const PartLink({required this.wattId, this.url});

  factory PartLink.fromJson(Map<String, dynamic> json) =>
      _$PartLinkFromJson(json);

  Map<String, dynamic> toJson() => _$PartLinkToJson(this);

  static String _asNonEmptyString(Object? v) => v?.toString() ?? '';
}
