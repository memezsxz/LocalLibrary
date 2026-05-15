import 'package:json_annotation/json_annotation.dart';

part 'part_link.g.dart';

@JsonSerializable(explicitToJson: true, fieldRename: FieldRename.snake)
class PartLink {
  @JsonKey(fromJson: _asNonEmptyString)
  final String wattId;
  final String? url;
  final String? title;

  const PartLink({required this.wattId, this.url, this.title});

  factory PartLink.fromJson(Map<String, dynamic> json) =>
      _$PartLinkFromJson(json);

  Map<String, dynamic> toJson() => _$PartLinkToJson(this);

  static String _asNonEmptyString(Object? v) => v?.toString() ?? '';
}
