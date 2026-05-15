import 'package:json_annotation/json_annotation.dart';

part 'count_response.g.dart';

@JsonSerializable()
class CountResponse {
  final int count;

  const CountResponse({required this.count});

  factory CountResponse.fromJson(Map<String, dynamic> json) =>
      _$CountResponseFromJson(json);

  Map<String, dynamic> toJson() => _$CountResponseToJson(this);
}
