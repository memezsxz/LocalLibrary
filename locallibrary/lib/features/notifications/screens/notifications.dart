import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../core/api/dto/notification_row.dart';
import '../../../core/api/dto/notification_thread.dart';
import '../../../core/api/notifications_api_client.dart';
import '../../../core/theme/app_palette.dart';
import '../../../dependency_injection.dart';
import '../../comments/widgets/comments_paragraph_view.dart';
import '../../library/cubit/navigation_cubit.dart';
import '../../library/cubit/navigation_state.dart';
import '../../part/widgets/comment_list_item.dart';
import '../../story/models/domain/media_model.dart';
import '../../story/models/domain/story_enums.dart';
import '../bloc/notifications_bloc.dart';
import '../models/domain/notification_model.dart';

// ─── list item union ──────────────────────────────────────────────────────────

sealed class _ListItem {}

class _HeaderItem extends _ListItem {
  final String label;

  _HeaderItem(this.label);
}

class _NotifItem extends _ListItem {
  final NotificationRow row;

  _NotifItem(this.row);
}

// ─── grouping helpers ─────────────────────────────────────────────────────────

String _dateBucket(DateTime dt) {
  final now = DateTime.now();
  final today = DateTime(now.year, now.month, now.day);
  final d = DateTime(dt.year, dt.month, dt.day);
  final diff = today.difference(d).inDays;
  if (diff == 0) return 'TODAY';
  if (diff == 1) return 'YESTERDAY';
  if (diff < 7) return 'THIS WEEK';
  return 'EARLIER';
}

List<_ListItem> _buildGrouped(List<NotificationRow> items) {
  final result = <_ListItem>[];
  String? lastBucket;
  for (final row in items) {
    final bucket = _dateBucket(row.notification.createdAt);
    if (bucket != lastBucket) {
      result.add(_HeaderItem(bucket));
      lastBucket = bucket;
    }
    result.add(_NotifItem(row));
  }
  return result;
}

// ─── screen ──────────────────────────────────────────────────────────────────

class Notifications extends StatelessWidget {
  const Notifications({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => sl<NotificationsBloc>()..add(NotificationsLoadRequested()),
      child: const _NotificationsView(),
    );
  }
}

class _NotificationsView extends StatefulWidget {
  const _NotificationsView();

  @override
  State<_NotificationsView> createState() => _NotificationsViewState();
}

class _NotificationsViewState extends State<_NotificationsView> {
  final _scroll = ScrollController();
  bool _unreadOnly = false;

  @override
  void initState() {
    super.initState();
    _scroll.addListener(_onScroll);
  }

  @override
  void dispose() {
    _scroll.dispose();
    super.dispose();
  }

  void _onScroll() {
    if (_scroll.position.extentAfter < 400) {
      context.read<NotificationsBloc>().add(NotificationsLoadMoreRequested());
    }
  }

  void _setFilter(bool unreadOnly) {
    if (_unreadOnly == unreadOnly) return;
    setState(() => _unreadOnly = unreadOnly);
    context.read<NotificationsBloc>().add(
      NotificationsLoadRequested(unreadOnly: unreadOnly),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 12, 16, 8),
          child: Row(
            children: [
              SegmentedButton<bool>(
                segments: const [
                  ButtonSegment(value: false, label: Text('All')),
                  ButtonSegment(value: true, label: Text('Unread')),
                ],
                selected: {_unreadOnly},
                onSelectionChanged: (s) => _setFilter(s.first),
                style: ButtonStyle(
                  backgroundColor: WidgetStateProperty.resolveWith((states) {
                    if (states.contains(WidgetState.selected)) {
                      return AppPalette.primary;
                    }
                    return AppPalette.surfaceAlt;
                  }),
                  foregroundColor: WidgetStateProperty.resolveWith((states) {
                    if (states.contains(WidgetState.selected)) {
                      return AppPalette.textOnLight;
                    }
                    return AppPalette.textPrimary;
                  }),
                  side: const WidgetStatePropertyAll(
                    BorderSide(color: AppPalette.primaryLight),
                  ),
                ),
              ),
              const Spacer(),
              BlocBuilder<NotificationsBloc, NotificationsState>(
                builder: (context, state) {
                  if (state is! NotificationsData)
                    return const SizedBox.shrink();
                  final hasUnread = state.items.any(
                    (r) => !r.notification.isRead,
                  );
                  if (!hasUnread) return const SizedBox.shrink();
                  return TextButton(
                    onPressed: () => context.read<NotificationsBloc>().add(
                      NotificationsMarkAllReadRequested(),
                    ),
                    style: TextButton.styleFrom(
                      foregroundColor: AppPalette.primary,
                      textStyle: const TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    child: const Text('Mark all read'),
                  );
                },
              ),
            ],
          ),
        ),
        Expanded(
          child: BlocBuilder<NotificationsBloc, NotificationsState>(
            builder: (context, state) {
              if (state is NotificationsLoading) {
                return const Center(child: CircularProgressIndicator());
              }

              if (state is NotificationsError) {
                return Center(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    spacing: 12,
                    children: [
                      Text(
                        state.message,
                        style: const TextStyle(color: AppPalette.error),
                      ),
                      TextButton(
                        onPressed: () => context.read<NotificationsBloc>().add(
                          NotificationsLoadRequested(unreadOnly: _unreadOnly),
                        ),
                        child: const Text('Retry'),
                      ),
                    ],
                  ),
                );
              }

              if (state is NotificationsData) {
                if (state.items.isEmpty) {
                  return Center(
                    child: Text(
                      _unreadOnly
                          ? 'No unread notifications'
                          : 'No notifications',
                      style: const TextStyle(color: AppPalette.gray),
                    ),
                  );
                }

                final grouped = _buildGrouped(state.items);

                return RefreshIndicator(
                  color: AppPalette.primary,
                  onRefresh: () async => context.read<NotificationsBloc>().add(
                    NotificationsLoadRequested(unreadOnly: _unreadOnly),
                  ),
                  child: ListView.builder(
                    controller: _scroll,
                    padding: const EdgeInsets.only(bottom: 24),
                    itemCount: grouped.length + (state.loadingMore ? 1 : 0),
                    itemBuilder: (context, i) {
                      if (i >= grouped.length) {
                        return const Padding(
                          padding: EdgeInsets.all(16),
                          child: Center(child: CircularProgressIndicator()),
                        );
                      }
                      return switch (grouped[i]) {
                        _HeaderItem h => _DateHeader(label: h.label),
                        _NotifItem n => _NotificationCard(
                          key: ValueKey(n.row.notification.notificationId),
                          row: n.row,
                          unreadOnly: _unreadOnly,
                        ),
                      };
                    },
                  ),
                );
              }

              return const SizedBox.shrink();
            },
          ),
        ),
      ],
    );
  }
}

// ─── date header ─────────────────────────────────────────────────────────────

class _DateHeader extends StatelessWidget {
  final String label;

  const _DateHeader({required this.label});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 18, 16, 6),
      child: Text(
        label,
        style: const TextStyle(
          fontSize: 11,
          fontWeight: FontWeight.w600,
          letterSpacing: 1.4,
          color: AppPalette.gray,
        ),
      ),
    );
  }
}

// ─── notification card ────────────────────────────────────────────────────────

class _NotificationCard extends StatefulWidget {
  final NotificationRow row;
  final bool unreadOnly;

  const _NotificationCard({
    super.key,
    required this.row,
    required this.unreadOnly,
  });

  @override
  State<_NotificationCard> createState() => _NotificationCardState();
}

class _NotificationCardState extends State<_NotificationCard> {
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
        margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
        decoration: BoxDecoration(
          color: Colors.green.shade600,
          borderRadius: BorderRadius.circular(10),
        ),
        alignment: Alignment.centerLeft,
        padding: const EdgeInsets.only(left: 20),
        child: const Row(
          children: [
            Icon(Icons.check_circle_outline, color: Colors.white, size: 20),
            SizedBox(width: 8),
            Text(
              'Mark as read',
              style: TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
      ),
      child: GestureDetector(
        onTap: () => _toggle(context),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 250),
          curve: Curves.easeOutCubic,
          margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
          decoration: BoxDecoration(
            color: isUnread ? AppPalette.surfaceAlt : AppPalette.background,
            borderRadius: BorderRadius.circular(10),
            border: Border(
              left: BorderSide(
                color: isUnread ? AppPalette.primary : Colors.transparent,
                width: 3,
              ),
            ),
            boxShadow: _expanded
                ? [
                    BoxShadow(
                      color: AppPalette.primary.withOpacity(0.08),
                      blurRadius: 12,
                      offset: const Offset(0, 4),
                    ),
                  ]
                : null,
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // ── header ──
              Padding(
                padding: const EdgeInsets.all(10),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  spacing: 12,
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
                                  style: const TextStyle(
                                    fontWeight: FontWeight.w600,
                                    fontSize: 13,
                                    color: AppPalette.textPrimary,
                                  ),
                                  maxLines: 2,
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ),
                              if (isUnread)
                                Container(
                                  width: 8,
                                  height: 8,
                                  margin: const EdgeInsets.only(
                                    left: 6,
                                    top: 3,
                                  ),
                                  decoration: const BoxDecoration(
                                    color: AppPalette.primary,
                                    shape: BoxShape.circle,
                                  ),
                                ),
                            ],
                          ),
                          Row(
                            spacing: 8,
                            children: [
                              _TypeBadge(type: n.notificationType),
                              Text(
                                _formatTime(n.createdAt),
                                style: const TextStyle(
                                  fontSize: 11,
                                  color: AppPalette.gray,
                                ),
                              ),
                            ],
                          ),
                          if (preview != null && !_expanded)
                            Text(
                              '"$preview"',
                              style: const TextStyle(
                                fontSize: 12,
                                color: AppPalette.gray,
                                fontStyle: FontStyle.italic,
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
                        child: const Icon(
                          Icons.expand_more,
                          size: 18,
                          color: AppPalette.gray,
                        ),
                      )
                    else
                      const Icon(
                        Icons.arrow_forward_ios,
                        size: 14,
                        color: AppPalette.gray,
                      ),
                  ],
                ),
              ),

              // ── expanded body ──
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
        const Divider(height: 1, color: AppPalette.primaryExtraLight),
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
                foregroundColor: AppPalette.primary,
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
              style: const TextStyle(color: AppPalette.error, fontSize: 13),
            ),
          );
        }

        final thread = snapshot.data!;
        final comments = thread.comments;

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (thread.paragraph != null)
              CommentsParagraphView(p: thread.paragraph!),
            if (comments.isEmpty)
              const Padding(
                padding: EdgeInsets.all(12),
                child: Text(
                  'No comments',
                  style: TextStyle(color: AppPalette.gray, fontSize: 13),
                ),
              )
            else
              ListView.separated(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                padding: const EdgeInsets.fromLTRB(10, 10, 10, 4),
                itemCount: comments.length,
                separatorBuilder: (_, __) => const SizedBox(height: 5),
                itemBuilder: (context, i) {
                  final c = comments[i];
                  final depth = c.depth ?? (c.parentCommentId == null ? 0 : 1);
                  final isRoot = depth == 0;
                  return CommentListItem(
                    comment: c,
                    depth: depth,
                    isRoot: isRoot,
                    isExpanded: false,
                    loadingChildren: false,
                    textDirection: TextDirection.ltr,
                    isByAuthor: false,
                    isHighlighted: targetId != null && c.commentId == targetId,
                    onToggleReplies: () {},
                  );
                },
              ),
          ],
        );
      },
    );
  }
}

// ─── type badge ───────────────────────────────────────────────────────────────

class _TypeBadge extends StatelessWidget {
  final NotificationType type;

  const _TypeBadge({required this.type});

  (IconData, String) get _info => switch (type) {
    NotificationType.storyAdded => (Icons.menu_book_rounded, 'Story Added'),
    NotificationType.storyDeleted => (Icons.menu_book_rounded, 'Story Removed'),
    NotificationType.partAdded => (Icons.article_rounded, 'Part Added'),
    NotificationType.partDeleted => (Icons.article_rounded, 'Part Removed'),
    NotificationType.authorComment => (Icons.chat_bubble_rounded, 'Comment'),
  };

  @override
  Widget build(BuildContext context) {
    final (icon, label) = _info;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(
        color: AppPalette.primaryExtraLight,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        spacing: 4,
        children: [
          Icon(icon, size: 11, color: AppPalette.primary),
          Text(
            label,
            style: const TextStyle(
              fontSize: 11,
              color: AppPalette.primary,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }
}

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
        width: 48,
        height: 68,
        child: url != null
            ? Image.network(
                url,
                fit: BoxFit.cover,
                errorBuilder: (_, __, ___) => _placeholder,
              )
            : _placeholder,
      ),
    );
  }

  Widget get _placeholder => Container(
    color: AppPalette.primaryExtraLight,
    child: const Icon(
      Icons.menu_book_rounded,
      color: AppPalette.primary,
      size: 24,
    ),
  );
}
