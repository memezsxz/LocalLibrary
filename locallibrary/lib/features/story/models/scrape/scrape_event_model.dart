import 'package:json_annotation/json_annotation.dart';

part 'scrape_event_model.g.dart';

@JsonSerializable(fieldRename: FieldRename.snake, explicitToJson: true)
class ScrapeEvent {
  final String name;
  final String payload;
  final DateTime receivedAt;

  ScrapeEvent(this.name, this.payload, {DateTime? receivedAt})
    : receivedAt = receivedAt ?? DateTime.now();

  factory ScrapeEvent.fromJson(Map<String, dynamic> json) =>
      _$ScrapeEventFromJson(json);

  Map<String, dynamic> toJson() => _$ScrapeEventToJson(this);

  @override
  String toString() {
    return '{name: $name, payload: $payload, receivedAt: ${receivedAt.toString()}}';
  }
}
