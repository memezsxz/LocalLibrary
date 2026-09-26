import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:locallibrary/core/theme/app_theme.dart';
import 'package:locallibrary/features/story/models/domain/story_enums.dart';

import '../../comments/bloc/comments_bloc.dart';
import '../../comments/widgets/comments_paragraph_view.dart';
import '../../story/bloc/story_bloc.dart';
import '../../story/models/domain/comment_model.dart';
import '../../story/models/domain/part_model.dart';
import '../bloc/part_bloc.dart';
import 'comment_list_item.dart';
import 'comments_paragraph_nav_arrow.dart';

export 'comment_list_item.dart';
export 'comments_paragraph_nav_arrow.dart';

class CommentsPanel extends StatefulWidget {
  const CommentsPanel({
    super.key,
    required this.storyId,
    this.paragraph,
    this.targetCommentId,
  });

  final int storyId;
  final Paragraph? paragraph;
  final int? targetCommentId;

  @override
  State<CommentsPanel> createState() => _CommentsPanelState();
}

class _CommentsPanelState extends State<CommentsPanel> {
  final _expanded = <int>{};
  final _scrollCtrl = ScrollController();
  final _commentKeys = <int, GlobalKey>{};
  bool _scrolledToTarget = false;
  bool _loadedRepliesForTarget = false;

  GlobalKey _keyForComment(int id) =>
      _commentKeys.putIfAbsent(id, () => GlobalKey());

  @override
  void dispose() {
    _scrollCtrl.dispose();
    super.dispose();
  }

  @override
  void initState() {
    super.initState();
    debugPrint(
      '[CommentsPanel] initState storyId=${widget.storyId} paragraph=${widget.paragraph?.paragraphId}',
    );
    // Loading is primed by SidePanelScaffold listener now.
  }

  @override
  void didUpdateWidget(covariant CommentsPanel oldWidget) {
    super.didUpdateWidget(oldWidget);
    // debugPrint(
    //   '[CommentsPanel] didUpdateWidget oldStory=${oldWidget.storyId} oldPara=${oldWidget.paragraph?.paragraphId} -> newStory=${widget.storyId} newPara=${widget.paragraph?.paragraphId}',
    // );
    if (oldWidget.storyId != widget.storyId ||
        oldWidget.paragraph?.paragraphId != widget.paragraph?.paragraphId) {
      _expanded.clear();
      _scrolledToTarget = false;
      _loadedRepliesForTarget = false;
      _commentKeys.clear();
      // debugPrint(
      //   '[CommentsPanel] didUpdateWidget -> load is primed by SidePanelScaffold',
      // );
    }
  }

  void _kick() {}

  @override
  Widget build(BuildContext context) {
    final authorUsername = context
        .read<StoryBloc>()
        .state
        .getBundle(widget.storyId)
        ?.author
        .username;
    final p = widget.paragraph;
    // debugPrint('[CommentsPanel] build paragraph=${p?.paragraphId}');

    return LayoutBuilder(
      builder: (context, constraints) {
        // debugPrint(
        //   '[CommentsPanel] Layout constraints: minW=${constraints.minWidth}, maxW=${constraints.maxWidth}, minH=${constraints.minHeight}, maxH=${constraints.maxHeight}',
        // );
        if (constraints.minWidth > constraints.maxWidth ||
            constraints.minHeight > constraints.maxHeight) {
          // debugPrint(
          //   '[CommentsPanel][WARN] NON-NORMALIZED constraints in CommentsPanel build',
          // );
        }
        return Column(
          children: [
            Container(
              decoration: BoxDecoration(
                border: Border(
                  bottom: BorderSide(color: context.colors.primaryExtraLight),
                ),
              ),
              child: Padding(
                padding: const EdgeInsets.fromLTRB(14, 14, 14, 12),
                child: Row(
                  mainAxisSize: MainAxisSize.max,
                  children: [
                    if (p != null)
                      CommentsParagraphNavArrow(
                        dir: NavDir.prev,
                        storyId: widget.storyId,
                        current: p,
                      )
                    else
                      const SizedBox(width: 18),
                    Expanded(
                      child: Center(
                        child: Builder(
                          builder: (context) {
                            final labelStyle = TextStyle(
                              fontSize: 13,
                              fontWeight: FontWeight.w700,
                              color: context.colors.textPrimary,
                            );
                            if (p != null) {
                              return Text(
                                "Comments · ${p.commentsCount}",
                                style: labelStyle,
                              );
                            }
                            final ps = context
                                .read<PartBloc>()
                                .state;
                            final count = (ps is PartLoaded)
                                ? ps.info.commentsCount
                                : null;
                            final label = (count == null)
                                ? 'Comments'
                                : 'Comments · $count';
                            return Text(label, style: labelStyle);
                          },
                        ),
                      ),
                    ),
                    if (p != null)
                      CommentsParagraphNavArrow(
                        dir: NavDir.next,
                        storyId: widget.storyId,
                        current: p,
                      )
                    else
                      const SizedBox(width: 18),
                  ],
                ),
              ),
            ),

            // show the paragraph preview/snippet only in paragraph mode
            if (p != null) CommentsParagraphView(p: p),

            // body
            Expanded(
              child: BlocBuilder<CommentsBloc, CommentsState>(
                builder: (context, state) {
                  debugPrint(
                    '[CommentsPanel] BlocBuilder state=${state.runtimeType}',
                  );
                  if (state is! CommentsData) {
                    return const Center(child: CircularProgressIndicator());
                  }

                  final s = state;
                  debugPrint(
                    '[CommentsPanel] mode=${s.isParagraphMode
                        ? 'paragraph'
                        : s.isPartMode
                        ? 'part'
                        : 'none'} roots=${s.roots.length} loadingRoot=${s.loadingRoot} rootEnded=${s.rootEnded}',
                  );
                  final isInitialLoading = s.roots.isEmpty && s.loadingRoot;
                  final isEmptyAndEnded = s.roots.isEmpty && s.rootEnded;
                  final isEmptyPending = s.roots.isEmpty && !s.rootEnded;

                  // ── deep-link: scroll to target comment ──
                  final target = widget.targetCommentId;
                  if (target != null && !_scrolledToTarget && !s.loadingRoot) {
                    final inRoots = s.roots.any((c) => c.commentId == target);
                    if (inRoots) {
                      WidgetsBinding.instance.addPostFrameCallback((_) {
                        if (!mounted) return;
                        final ctx = _keyForComment(target).currentContext;
                        if (ctx != null) {
                          Scrollable.ensureVisible(
                            ctx,
                            duration: const Duration(milliseconds: 400),
                            alignment: 0.1,
                          );
                          setState(() => _scrolledToTarget = true);
                        }
                      });
                    } else if (!_loadedRepliesForTarget && s.roots.isNotEmpty) {
                      _loadedRepliesForTarget = true;
                      WidgetsBinding.instance.addPostFrameCallback((_) {
                        if (!mounted) return;
                        for (final root in s.roots) {
                          if (root.repliesCount > 0 &&
                              !(s.repliesEnded[root.commentId] ?? false) &&
                              !s.repliesLoading.contains(root.commentId)) {
                            setState(() => _expanded.add(root.commentId));
                            context.read<CommentsBloc>().add(
                              LoadReplies(root.commentId),
                            );
                          }
                        }
                      });
                    } else if (_loadedRepliesForTarget) {
                      final foundInReplies = s.replies.values.any(
                            (list) => list.any((c) => c.commentId == target),
                      );
                      if (foundInReplies) {
                        WidgetsBinding.instance.addPostFrameCallback((_) {
                          if (!mounted) return;
                          final ctx = _keyForComment(target).currentContext;
                          if (ctx != null) {
                            Scrollable.ensureVisible(
                              ctx,
                              duration: const Duration(milliseconds: 400),
                              alignment: 0.1,
                            );
                            setState(() => _scrolledToTarget = true);
                          }
                        });
                      }
                    }
                  }

                  Widget listChild;
                  if (isEmptyAndEnded) {
                    // clearly show "no comments"
                    listChild = ListView(
                      padding: const EdgeInsets.all(12),
                      children: const [
                        SizedBox(height: 12),
                        Center(child: Text('No comments yet')),
                      ],
                    );
                  } else if (isEmptyPending) {
                    // lightweight placeholder while waiting (prevents transparent look)
                    listChild = ListView(
                      padding: const EdgeInsets.all(12),
                      children: const [
                        SizedBox(height: 12),
                        Center(child: Text('Loading comments...')),
                      ],
                    );
                  } else {
                    listChild = NotificationListener<ScrollNotification>(
                      onNotification: (sn) {
                        if (sn.metrics.axis == Axis.vertical &&
                            sn.metrics.pixels >=
                                sn.metrics.maxScrollExtent - 240) {
                          final st = context.read<CommentsBloc>().state;
                          if (st is CommentsData &&
                              !st.rootEnded &&
                              !st.loadingMoreRoot) {
                            debugPrint(
                              '[CommentsPanel] near end -> request LoadMoreRootComments',
                            );
                            context.read<CommentsBloc>().add(
                              LoadMoreRootComments(),
                            );
                          }
                        }
                        return false;
                      },
                      child: ScrollConfiguration(
                        behavior: const _NoScrollbarBehavior(),

                        child: RawScrollbar(
                          controller: _scrollCtrl,
                          // thumbVisibility: true,                 // always show
                          // trackVisibility: true,                 // show the track too
                          thickness: 4,
                          // width of the thumb
                          radius: const Radius.circular(8),
                          scrollbarOrientation: ScrollbarOrientation.left,
                          thumbColor: context.colors.primaryLight,
                          // thumb color
                          trackColor: Colors.transparent,
                          // track fill
                          // trackBorderColor: context.colors.primary.withOpacity(0.25), // track border
                          interactive: true,

                          // draggable
                          child: ListView.separated(
                            controller: _scrollCtrl,
                            padding: const EdgeInsets.symmetric(
                              horizontal: 14,
                              vertical: 10,
                            ),
                            itemCount: s.roots.length,
                            separatorBuilder: (_, __) =>
                            const SizedBox(height: 8),
                            itemBuilder: (context, i) {
                              final root = s.roots[i];
                              final id = root.commentId;
                              final isExpanded = _expanded.contains(id);
                              final loadingChildren = s.repliesLoading.contains(
                                id,
                              );
                              final textDir =
                                  p?.direction.toTextDirection ??
                                  TextDirection.ltr;

                              void toggle() {
                                setState(() {
                                  if (isExpanded) {
                                    _expanded.remove(id);
                                  } else {
                                    _expanded.add(id);
                                    final already =
                                    (s.replies[id]?.isNotEmpty ?? false);
                                    final loading = s.repliesLoading.contains(
                                      id,
                                    );
                                    final done = s.repliesEnded[id] ?? false;
                                    if (!already && !loading && !done) {
                                      context.read<CommentsBloc>().add(
                                        LoadReplies(id),
                                      );
                                    }
                                  }
                                });
                              }

                              Widget commentTile(Comment c) {
                                final isTarget =
                                    target != null && c.commentId == target;
                                Widget item = CommentListItem(
                                  comment: c,
                                  isRoot: c.commentId == id,
                                  isExpanded: isExpanded,
                                  loadingChildren: loadingChildren,
                                  textDirection: textDir,
                                  isByAuthor: c.userName == authorUsername,
                                  isHighlighted: isTarget,
                                  onToggleReplies: toggle,
                                );
                                if (isTarget) {
                                  item = KeyedSubtree(
                                    key: _keyForComment(c.commentId),
                                    child: item,
                                  );
                                }
                                return item;
                              }

                              final replies = isExpanded
                                  ? (s.replies[id] ?? const <Comment>[])
                                  : const <Comment>[];

                              Widget? trailing;
                              if (root.repliesCount > 0) {
                                if (isExpanded && loadingChildren) {
                                  trailing = const Padding(
                                    padding: EdgeInsets.only(left: 14, top: 6),
                                    child: SizedBox(
                                      width: 16,
                                      height: 16,
                                      child: CircularProgressIndicator(
                                        strokeWidth: 2,
                                      ),
                                    ),
                                  );
                                } else if (!isExpanded) {
                                  trailing = Padding(
                                    padding: const EdgeInsets.only(
                                      left: 14,
                                      top: 4,
                                    ),
                                    child: InkWell(
                                      onTap: toggle,
                                      borderRadius: BorderRadius.circular(8),
                                      child: Row(
                                        mainAxisSize: MainAxisSize.min,
                                        children: [
                                          Icon(
                                            Icons.expand_more,
                                            size: 15,
                                            color: context.colors.primary,
                                          ),
                                          const SizedBox(width: 4),
                                          Text(
                                            '${root.repliesCount} repl${root
                                                .repliesCount > 1
                                                ? 'ies'
                                                : 'y'}',
                                            style: TextStyle(
                                              fontSize: 11,
                                              fontWeight: FontWeight.w700,
                                              color: context.colors.primary,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  );
                                }
                              }

                              return CommentThreadGroup(
                                root: root,
                                replies: replies,
                                buildItem: commentTile,
                                trailing: trailing,
                              );
                            },
                          ),
                        ),
                      ),
                    );
                  }

                  return Stack(
                    children: [
                      // always paint a surface so it never appears transparent
                      Container(
                        color: context.colors.surfaceAlt,
                        child: listChild,
                      ),

                      // top spinner while initial page loads
                      if (isInitialLoading)
                        const Positioned(
                          left: 0,
                          right: 0,
                          top: 8,
                          child: Center(
                            child: SizedBox(
                              width: 20,
                              height: 20,
                              child: CircularProgressIndicator(strokeWidth: 2),
                            ),
                          ),
                        ),

                      // bottom spinner while paginating
                      if (s.loadingMoreRoot)
                        const Positioned(
                          left: 0,
                          right: 0,
                          bottom: 8,
                          child: Center(
                            child: SizedBox(
                              width: 20,
                              height: 20,
                              child: CircularProgressIndicator(strokeWidth: 2),
                            ),
                          ),
                        ),
                    ],
                  );
                },
              ),
            ),
          ],
        );
      },
    );
  }
}

class _NoScrollbarBehavior extends MaterialScrollBehavior {
  const _NoScrollbarBehavior();

  @override
  Widget buildScrollbar(
    BuildContext context,
    Widget child,
    ScrollableDetails details,
  ) {
    // Do NOT wrap with the default Scrollbar
    return child;
  }
}
