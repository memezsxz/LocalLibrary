import 'package:meta/meta.dart';

import '../../story/models/dto/part_full_info.dart';

@immutable
sealed class PartState {
  const PartState();
}

class PartInitial extends PartState {
  const PartInitial();
}

class PartLoading extends PartState {
  const PartLoading();
}

class PartLoaded extends PartState {
  final PartFullInfo info;

  const PartLoaded(this.info);
}

class PartError extends PartState {
  final String message;

  const PartError(this.message);
}
