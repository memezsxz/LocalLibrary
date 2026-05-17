import 'package:bloc/bloc.dart';

import '../../../core/api/dto/notification_row.dart';
import '../../../core/api/notifications_api_client.dart';

part 'notifications_event.dart';
part 'notifications_state.dart';

class NotificationsBloc extends Bloc<NotificationsEvent, NotificationsState> {
  final NotificationsApiClient api;
  static const int _pageSize = 20;

  NotificationsBloc({required this.api}) : super(NotificationsInitial()) {
    on<NotificationsLoadRequested>(_onLoad);
    on<NotificationsLoadMoreRequested>(_onLoadMore);
    on<NotificationMarkReadRequested>(_onMarkRead);
    on<NotificationsMarkAllReadRequested>(_onMarkAllRead);
  }

  Future<void> _onLoad(
    NotificationsLoadRequested e,
    Emitter<NotificationsState> emit,
  ) async {
    emit(NotificationsLoading());
    try {
      final items = e.unreadOnly
          ? await api.listUnreadNotifications(limit: _pageSize, offset: 0)
          : await api.listNotifications(limit: _pageSize, offset: 0);
      emit(
        NotificationsData(
          items: items,
          hasMore: items.length == _pageSize,
          unreadOnly: e.unreadOnly,
        ),
      );
    } catch (err) {
      emit(NotificationsError(err.toString()));
    }
  }

  Future<void> _onLoadMore(
    NotificationsLoadMoreRequested e,
    Emitter<NotificationsState> emit,
  ) async {
    final s = state;
    if (s is! NotificationsData || s.loadingMore || !s.hasMore) return;

    emit(s.copyWith(loadingMore: true));
    try {
      final next = s.unreadOnly
          ? await api.listUnreadNotifications(
              limit: _pageSize,
              offset: s.items.length,
            )
          : await api.listNotifications(
              limit: _pageSize,
              offset: s.items.length,
            );
      emit(
        s.copyWith(
          items: [...s.items, ...next],
          hasMore: next.length == _pageSize,
          loadingMore: false,
        ),
      );
    } catch (err) {
      emit(s.copyWith(loadingMore: false, error: err.toString()));
    }
  }

  Future<void> _onMarkRead(
    NotificationMarkReadRequested e,
    Emitter<NotificationsState> emit,
  ) async {
    final s = state;
    if (s is! NotificationsData) return;

    emit(
      s.copyWith(
        items: s.items
            .map(
              (row) => row.notification.notificationId == e.notificationId
                  ? row.copyWith(
                      notification: row.notification.copyWith(isRead: true),
                    )
                  : row,
            )
            .toList(),
      ),
    );

    try {
      await api.markAsRead(e.notificationId);
    } catch (_) {
      emit(s);
    }
  }

  Future<void> _onMarkAllRead(
    NotificationsMarkAllReadRequested e,
    Emitter<NotificationsState> emit,
  ) async {
    final s = state;
    if (s is! NotificationsData) return;

    final unread = s.items.where((r) => !r.notification.isRead).toList();
    if (unread.isEmpty) return;

    emit(
      s.copyWith(
        items: s.items
            .map(
              (r) => r.notification.isRead
                  ? r
                  : r.copyWith(
                      notification: r.notification.copyWith(isRead: true),
                    ),
            )
            .toList(),
      ),
    );

    for (final row in unread) {
      api.markAsRead(row.notification.notificationId).catchError((_) {});
    }
  }
}
