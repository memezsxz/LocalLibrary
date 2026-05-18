import 'package:meta/meta.dart';

import '../../story/models/dto/part_full_info.dart';

@immutable
sealed class PartEvent {
  const PartEvent();
}

class PartFetchRequested extends PartEvent {
  final int storyId;
  final int partId;
  final List<int>? sequence;

  const PartFetchRequested(
      {required this.storyId, required this.partId, this.sequence});
}

class PartLoadNextRequested extends PartEvent {
  const PartLoadNextRequested();
}

class PartDataProvided extends PartEvent {
  final PartFullInfo info;

  const PartDataProvided(this.info);
}

class PartProgressStarted extends PartEvent {
  final int storyId;

  const PartProgressStarted({required this.storyId});
}

class PartProgressUpdated extends PartEvent {
  final int storyId;
  final int lastParagraphId;

  const PartProgressUpdated({
    required this.storyId,
    required this.lastParagraphId,
  });
}
