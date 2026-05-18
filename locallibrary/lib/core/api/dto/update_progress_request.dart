class UpdateProgressRequest {
  final int lastParagraphId;
  final DateTime readEndTime;

  UpdateProgressRequest({
    required this.lastParagraphId,
    required this.readEndTime,
  });

  Map<String, dynamic> toJson() => {
    'last_paragraph_id': lastParagraphId,
    'read_end_time': readEndTime.toUtc().toIso8601String(),
  };
}
