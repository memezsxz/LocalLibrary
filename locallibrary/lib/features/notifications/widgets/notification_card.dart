import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../core/api/dto/notification_row.dart';
import '../../../core/api/dto/notification_thread.dart';
import '../../../core/api/notifications_api_client.dart';
import '../../../core/theme/app_theme.dart';
import '../../../dependency_injection.dart';
import '../../comments/widgets/comments_paragraph_view.dart';
import '../../library/cubit/navigation_cubit.dart';
import '../../library/cubit/navigation_state.dart';
import '../../part/widgets/comment_list_item.dart';
import '../../story/models/domain/comment_model.dart';
import '../../story/models/domain/media_model.dart';
import '../../story/models/domain/story_enums.dart';
import '../bloc/notifications_bloc.dart';
import '../models/domain/notification_model.dart';

// ─── notification card ────────────────────────────────────────────────────────

class NotificationCard extends StatefulWidget {
  final NotificationRow row;
  final bool unreadOnly;

  const NotificationCard({
    super.key,
    required this.row,
    required this.unreadOnly,
  });

  @override
  State<NotificationCard> createState() => _NotificationCardState();
}

class _NotificationCardState extends State<NotificationCard> {
  bool _expanded = false;

  bool get _isExpandable =>
      widget.row.notification.notificationType ==
      NotificationType.authorComment;

  void _toggle(BuildContext context) {
    final n = widget.row.notification;
    if (!n.isRead) {
      context.read<NotificationsBloc>().add(
        NotificationMarkReadRequested(n.notificationId),
      );
    }
    if (_isExpandable) {
      setState(() => _expanded = !_expanded);
    } else {
      _navigate(context);
    }
  }

  void _navigate(BuildContext context) {
    final nav = context.read<NavigationCubit>();
    final n = widget.row.notification;
    if (n.partId != null) {
      final isComment = n.notificationType == NotificationType.authorComment;
      nav.push(
        NavigationPartState(
          storyId: n.storyId,
          partId: n.partId!,
          targetParagraphId: isComment ? n.paragraphId : null,
          targetCommentId: isComment ? n.commentId : null,
        ),
      );
    } else {
      nav.push(NavigationStoryState(storyId: n.storyId));
    }
  }

  @override
  Widget build(BuildContext context) {
    final n = widget.row.notification;
    final isUnread = !n.isRead;
    final preview = widget.row.preview;

    return Dismissible(
      key: ValueKey('dismiss_${n.notificationId}'),
      direction: DismissDirection.startToEnd,
      confirmDismiss: (_) async {
        if (!isUnread) return false;
        context.read<NotificationsBloc>().add(
          NotificationMarkReadRequested(n.notificationId),
        );
        return widget.unreadOnly;
      },
      background: Container(
        margin: const EdgeInsets.symmetric(horizontal: 10, vertical: 3),
        decoration: BoxDecoration(
          color: context.colors.success,
          borderRadius: BorderRadius.circular(12),
        ),
        alignment: Alignment.centerLeft,
        padding: const EdgeInsets.only(left: 20),
        child: Row(
          children: [
            Icon(
              Icons.check_circle_outline,
              color: context.colors.onSuccess,
              size: 20,
            ),
            const SizedBox(width: 8),
            Text(
              'Mark as read',
              style: TextStyle(
                color: context.colors.onSuccess,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
      ),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 250),
        curve: Curves.easeOutCubic,
        margin: const EdgeInsets.symmetric(horizontal: 10, vertical: 3),
        clipBehavior: Clip.hardEdge,
        decoration: BoxDecoration(
          color: isUnread ? context.colors.surfaceAlt : context.colors.surface,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: context.colors.primaryExtraLight),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            GestureDetector(
              onTap: () => _toggle(context),
              behavior: HitTestBehavior.opaque,
              child: Padding(
                padding: const EdgeInsets.all(10),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  spacing: 11,
                  children: [
                    _CoverThumbnail(medium: widget.row.medium),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        spacing: 5,
                        children: [
                          Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Expanded(
                                child: Text(
                                  n.message,
                                  style: TextStyle(
                                    fontWeight: isUnread
                                        ? FontWeight.w600
                                        : FontWeight.w400,
                                    fontSize: 13,
                                    color: context.colors.textPrimary,
                                  ),
                                  maxLines: 2,
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ),
                              if (isUnread)
                                Container(
                                  width: 7,
                                  height: 7,
                                  margin: const EdgeInsets.only(
                                    left: 6,
                                    top: 4,
                                  ),
                                  decoration: BoxDecoration(
                                    color: context.colors.primary,
                                    shape: BoxShape.circle,
                                  ),
                                ),
                            ],
                          ),
                          Row(
                            spacing: 5,
                            children: [
                              Icon(
                                _typeIcon(n.notificationType),
                                size: 13,
                                color: context.colors.gray,
                              ),
                              Text(
                                _formatTime(n.createdAt),
                                style: TextStyle(
                                  fontSize: 11,
                                  color: context.colors.gray,
                                ),
                              ),
                            ],
                          ),
                          if (preview != null && !_expanded)
                            Text(
                              preview,
                              style: TextStyle(
                                fontSize: 12,
                                color: context.colors.gray,
                              ),
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis,
                            ),
                        ],
                      ),
                    ),
                    if (_isExpandable)
                      AnimatedRotation(
                        turns: _expanded ? 0.5 : 0,
                        duration: const Duration(milliseconds: 200),
                        child: Icon(
                          Icons.expand_more,
                          size: 18,
                          color: context.colors.gray,
                        ),
                      )
                    else
                      Icon(
                        Icons.arrow_forward_ios,
                        size: 14,
                        color: context.colors.gray,
                      ),
                  ],
                ),
              ),
            ),
            AnimatedSize(
              duration: const Duration(milliseconds: 280),
              curve: Curves.easeOutCubic,
              child: _expanded
                  ? _ExpandedBody(
                notification: n,
                onNavigate: () => _navigate(context),
              )
                  : const SizedBox.shrink(),
            ),
          ],
        ),
      ),
    );
  }

  String _formatTime(DateTime dt) {
    final diff = DateTime.now().difference(dt);
    if (diff.inMinutes < 1) return 'just now';
    if (diff.inMinutes < 60) return '${diff.inMinutes}m ago';
    if (diff.inHours < 24) return '${diff.inHours}h ago';
    if (diff.inDays < 7) return '${diff.inDays}d ago';
    return '${dt.day}/${dt.month}/${dt.year}';
  }
}

// ─── expanded body ────────────────────────────────────────────────────────────

class _ExpandedBody extends StatelessWidget {
  final AppNotification notification;
  final VoidCallback onNavigate;

  const _ExpandedBody({required this.notification, required this.onNavigate});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Divider(height: 1, color: context.colors.primaryExtraLight),
        if (notification.notificationType == NotificationType.authorComment &&
            (notification.paragraphId != null || notification.partId != null))
          _NotificationCommentsView(notification: notification),
        Padding(
          padding: const EdgeInsets.fromLTRB(12, 4, 12, 8),
          child: Align(
            alignment: Alignment.centerRight,
            child: TextButton.icon(
              onPressed: onNavigate,
              icon: const Icon(Icons.arrow_forward_rounded, size: 16),
              label: Text(
                notification.partId != null ? 'Open Part' : 'Open Story',
              ),
              style: TextButton.styleFrom(
                foregroundColor: context.colors.primary,
                textStyle: const TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }
}

// ─── comments thread view ─────────────────────────────────────────────────────

class _NotificationCommentsView extends StatefulWidget {
  final AppNotification notification;

  const _NotificationCommentsView({required this.notification});

  @override
  State<_NotificationCommentsView> createState() =>
      _NotificationCommentsViewState();
}

class _NotificationCommentsViewState extends State<_NotificationCommentsView> {
  late final Future<NotificationThread> _future;

  @override
  void initState() {
    super.initState();
    _future = sl<NotificationsApiClient>()
        .getCommentsThread(widget.notification.notificationId)
        .catchError((e, st) {
          debugPrint('[NotificationThread] ERROR: $e\n$st');
          throw e;
        });
  }

  @override
  Widget build(BuildContext context) {
    final targetId = widget.notification.commentId;

    return FutureBuilder<NotificationThread>(
      future: _future,
      builder: (context, snapshot) {
        if (snapshot.connectionState != ConnectionState.done) {
          return const Padding(
            padding: EdgeInsets.all(16),
            child: Center(
              child: SizedBox(
                width: 20,
                height: 20,
                child: CircularProgressIndicator(strokeWidth: 2),
              ),
            ),
          );
        }

        if (snapshot.hasError || snapshot.data == null) {
          return Padding(
            padding: const EdgeInsets.all(12),
            child: Text(
              'Failed to load thread: ${snapshot.error}',
              style: TextStyle(color: context.colors.error, fontSize: 13),
            ),
          );
        }

        final thread = snapshot.data!;
        final comments = thread.comments;

        // Group the flat list into roots + their replies, same shape
        // CommentThreadGroup expects from the Comments panel.
        final roots = comments
            .where((c) => (c.depth ?? (c.parentCommentId == null ? 0 : 1)) == 0)
            .toList();
        final repliesByRoot = <int, List<Comment>>{};
        for (final c in comments) {
          final depth = c.depth ?? (c.parentCommentId == null ? 0 : 1);
          if (depth == 0) continue;
          final rootId = c.parentCommentId;
          if (rootId == null) continue;
          repliesByRoot.putIfAbsent(rootId, () => []).add(c);
        }

        Widget commentTile(Comment c) =>
            CommentListItem(
              comment: c,
              isRoot: c.parentCommentId == null,
              isExpanded: true,
              loadingChildren: false,
              textDirection: TextDirection.ltr,
              isByAuthor: false,
              isHighlighted: targetId != null && c.commentId == targetId,
              onToggleReplies: () {},
            );

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (thread.paragraph != null)
              CommentsParagraphView(p: thread.paragraph!),
            if (comments.isEmpty)
              Padding(
                padding: const EdgeInsets.all(12),
                child: Text(
                  'No comments',
                  style: TextStyle(color: context.colors.gray, fontSize: 13),
                ),
              )
            else
              Padding(
                padding: const EdgeInsets.fromLTRB(10, 10, 10, 4),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    for (final root in roots) ...[
                      CommentThreadGroup(
                        root: root,
                        replies: repliesByRoot[root.commentId] ?? const [],
                        buildItem: commentTile,
                      ),
                      const SizedBox(height: 5),
                    ],
                  ],
                ),
              ),
          ],
        );
      },
    );
  }
}

// ─── type icon ────────────────────────────────────────────────────────────────

IconData _typeIcon(NotificationType type) =>
    switch (type) {
      NotificationType.storyAdded => Icons.menu_book_rounded,
      NotificationType.storyDeleted => Icons.menu_book_rounded,
      NotificationType.partAdded => Icons.article_rounded,
      NotificationType.partDeleted => Icons.article_rounded,
      NotificationType.authorComment => Icons.chat_bubble_rounded,
    };

// ─── cover thumbnail ──────────────────────────────────────────────────────────

class _CoverThumbnail extends StatelessWidget {
  final Media? medium;

  const _CoverThumbnail({required this.medium});

  @override
  Widget build(BuildContext context) {
    final url = medium?.url;
    return ClipRRect(
      borderRadius: BorderRadius.circular(6),
      child: SizedBox(
        width: 40,
        height: 56,
        child: url != null
            ? Image.network(
                url,
                fit: BoxFit.cover,
          errorBuilder: (context, __, ___) => _placeholder(context),
              )
            : _placeholder(context),
      ),
    );
  }

  Widget _placeholder(BuildContext context) =>
      Container(
        color: context.colors.primaryExtraLight,
        child: Icon(
      Icons.menu_book_rounded,
          color: context.colors.primary,
          size: 20,
    ),
  );
}
