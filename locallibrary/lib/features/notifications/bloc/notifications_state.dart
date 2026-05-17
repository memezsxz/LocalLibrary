part of 'notifications_bloc.dart';

abstract class NotificationsState {}

class NotificationsInitial extends NotificationsState {}

class NotificationsLoading extends NotificationsState {}

class NotificationsData extends NotificationsState {
  final List<NotificationRow> items;
  final bool hasMore;
  final bool unreadOnly;
  final bool loadingMore;
  final String? error;

  NotificationsData({
    required this.items,
    required this.hasMore,
    required this.unreadOnly,
    this.loadingMore = false,
    this.error,
  });

  NotificationsData copyWith({
    List<NotificationRow>? items,
    bool? hasMore,
    bool? unreadOnly,
    bool? loadingMore,
    String? error,
  }) => NotificationsData(
    items: items ?? this.items,
    hasMore: hasMore ?? this.hasMore,
    unreadOnly: unreadOnly ?? this.unreadOnly,
    loadingMore: loadingMore ?? this.loadingMore,
    error: error,
  );
}

class NotificationsError extends NotificationsState {
  final String message;

  NotificationsError(this.message);
}
