class StartReadTimeRequest {
  final DateTime readStartTime;

  StartReadTimeRequest({required this.readStartTime});

  Map<String, dynamic> toJson() => {
    'read_start_time': readStartTime.toUtc().toIso8601String(),
  };
}
