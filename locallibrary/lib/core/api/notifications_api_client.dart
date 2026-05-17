import 'package:dio/dio.dart';
import 'package:retrofit/retrofit.dart';

import '../../features/notifications/models/domain/notification_model.dart';
import '../../features/story/models/domain/story_enums.dart';
import 'dto/notification_row.dart';
import 'dto/notification_thread.dart';

part 'notifications_api_client.g.dart';

@RestApi()
abstract class NotificationsApiClient {
  factory NotificationsApiClient(Dio dio, {String baseUrl}) =
      _NotificationsApiClient;

  @GET('/notifications')
  Future<List<NotificationRow>> listNotifications({
    @Query('limit') int? limit,
    @Query('offset') int? offset,
  });

  @GET('/notifications/unread')
  Future<List<NotificationRow>> listUnreadNotifications({
    @Query('limit') int? limit,
    @Query('offset') int? offset,
  });

  @GET('/notifications/type')
  Future<List<NotificationRow>> listNotificationsByType(
    @Query('type') NotificationType type, {
    @Query('limit') int? limit,
    @Query('offset') int? offset,
  });

  @GET('/notifications/{notificationId}')
  Future<NotificationRow> getNotification(
    @Path('notificationId') int notificationId,
  );

  @PATCH('/notifications/{notificationId}/read')
  Future<AppNotification> markAsRead(
    @Path('notificationId') int notificationId,
  );

  @GET('/notifications/{notificationId}/comment_thread')
  Future<NotificationThread> getCommentsThread(
    @Path('notificationId') int notificationId,
  );
}
