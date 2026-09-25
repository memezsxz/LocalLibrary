import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../core/api/dto/notification_row.dart';
import '../../../core/theme/app_theme.dart';
import '../../../dependency_injection.dart';
import '../bloc/notifications_bloc.dart';
import '../widgets/notification_card.dart';

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
                      return context.colors.primary;
                    }
                    return context.colors.surfaceAlt;
                  }),
                  foregroundColor: WidgetStateProperty.resolveWith((states) {
                    if (states.contains(WidgetState.selected)) {
                      return context.colors.textOnLight;
                    }
                    return context.colors.textPrimary;
                  }),
                  side: WidgetStatePropertyAll(
                    BorderSide(color: context.colors.primaryLight),
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
                      foregroundColor: context.colors.primary,
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
                        style: TextStyle(color: context.colors.error),
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
                      style: TextStyle(color: context.colors.gray),
                    ),
                  );
                }

                final grouped = _buildGrouped(state.items);

                return RefreshIndicator(
                  color: context.colors.primary,
                  backgroundColor: context.colors.surface,
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
                        _NotifItem n => NotificationCard(
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
        style: TextStyle(
          fontSize: 11,
          fontWeight: FontWeight.w600,
          letterSpacing: 1.4,
          color: context.colors.gray,
        ),
      ),
    );
  }
}
