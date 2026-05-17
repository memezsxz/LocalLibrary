part of 'notifications_bloc.dart';

abstract class NotificationsEvent {}

class NotificationsLoadRequested extends NotificationsEvent {
  final bool unreadOnly;

  NotificationsLoadRequested({this.unreadOnly = false});
}

class NotificationsLoadMoreRequested extends NotificationsEvent {}

class NotificationMarkReadRequested extends NotificationsEvent {
  final int notificationId;

  NotificationMarkReadRequested(this.notificationId);
}
