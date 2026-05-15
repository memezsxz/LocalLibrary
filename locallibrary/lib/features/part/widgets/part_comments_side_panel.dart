import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_html/flutter_html.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:locallibrary/core/theme/app_palette.dart';

import '../../comments/bloc/comments_bloc.dart';
import '../../comments/widgets/comments_paragraph_view.dart';
import '../../story/bloc/story_bloc.dart';
import '../../story/models/story_models.dart';
import '../bloc/part_bloc.dart';
import '../cubit/part_side_panel_cubit.dart';

class CommentsPanel extends StatefulWidget {
  const CommentsPanel({super.key, required this.storyId, this.paragraph});

  final int storyId;
  final Paragraph? paragraph;

  @override
  State<CommentsPanel> createState() => _CommentsPanelState();
}

class _CommentsPanelState extends State<CommentsPanel> {
  final _expanded = <int>{};
  final _scrollCtrl = ScrollController();

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
            const SizedBox(height: 30),
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 20),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                mainAxisSize: MainAxisSize.max,
                children: [
                  if (p != null)
                    CommentsParagraphNavArrow(
                      dir: NavDir.prev,
                      storyId: widget.storyId,
                      current: p,
                      iconAsset: "assets/icons/arrow_icon_left.svg",
                    ),
                  Builder(
                    builder: (context) {
                      if (p != null) {
                        return Text(
                          "Comments # ${p.commentsCount}",
                          style: Theme.of(
                            context,
                          ).textTheme.titleSmall?.copyWith(color: Colors.black),
                        );
                      }
                      final ps = context.read<PartBloc>().state;
                      final count = (ps is PartLoaded)
                          ? ps.info.commentsCount
                          : null;
                      final label = (count == null)
                          ? 'Comments'
                          : 'Comments # $count';
                      return Text(
                        label,
                        style: Theme.of(
                          context,
                        ).textTheme.titleSmall?.copyWith(color: Colors.black),
                      );
                    },
                  ),
                  if (p != null)
                    CommentsParagraphNavArrow(
                      dir: NavDir.next,
                      storyId: widget.storyId,
                      current: p,
                      iconAsset: "assets/icons/arrow_icon_right.svg",
                    ),
                ],
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

                  // flatten rows (roots + expanded replies)
                  final rows = <({Comment c, int depth})>[];
                  for (final root in s.roots) {
                    rows.add((c: root, depth: 0));
                    if (_expanded.contains(root.commentId)) {
                      for (final r
                          in (s.replies[root.commentId] ?? const <Comment>[])) {
                        rows.add((c: r, depth: 1));
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
                          thumbColor: AppPalette.primaryLight,
                          // thumb color
                          trackColor: AppPalette.transparent,
                          // track fill
                          // trackBorderColor: AppPalette.primary.withOpacity(0.25), // track border
                          interactive: true,

                          // draggable
                          child: ListView.separated(
                            controller: _scrollCtrl,
                            padding: const EdgeInsets.all(10),
                            itemCount: rows.length,
                            separatorBuilder: (_, __) =>
                                const SizedBox(height: 5),
                            itemBuilder: (context, i) {
                              final row = rows[i];
                              final c = row.c;
                              final depth = row.depth;
                              final id = c.commentId;
                              final isRoot = depth == 0;
                              final isExpanded = _expanded.contains(id);
                              final loadingChildren = s.repliesLoading.contains(
                                id,
                              );

                              final textDir =
                                  p?.direction.toTextDirection ??
                                  TextDirection.ltr;
                              return CommentListItem(
                                comment: c,
                                depth: depth,
                                isRoot: isRoot,
                                isExpanded: isExpanded,
                                loadingChildren: loadingChildren,
                                textDirection: textDir,
                                isByAuthor: c.userName == authorUsername,
                                onToggleReplies: () {
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
                                },
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
                        // color: Colors.white, // change to AppPalette.surfaceAlt if you prefer
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

class CommentListItem extends StatelessWidget {
  const CommentListItem({
    super.key,
    required this.comment,
    required this.depth,
    required this.isRoot,
    required this.isExpanded,
    required this.loadingChildren,
    required this.textDirection,
    required this.onToggleReplies,
    this.isByAuthor = false,
  });

  final Comment comment;
  final int depth;
  final bool isRoot;
  final bool isExpanded;
  final bool loadingChildren;
  final TextDirection textDirection;
  final VoidCallback onToggleReplies;
  final bool isByAuthor;

  @override
  Widget build(BuildContext context) {
    final c = comment;

    return Padding(
      // indent children to show hierarchy
      padding: EdgeInsetsDirectional.only(start: depth * 18.0),
      child: Container(
        decoration: BoxDecoration(
          color: const Color(0xFF2D2D2D).withOpacity(0.1),
          borderRadius: const BorderRadius.all(
            Radius.circular(8),
          ).copyWith(topLeft: const Radius.circular(3)),
        ),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 10),
          child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // comment
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text.rich(
                        TextSpan(
                          text: c.userName,
                          style: Theme.of(context).textTheme.labelMedium
                              ?.copyWith(
                                color: AppPalette.primary,
                                fontWeight: FontWeight.bold,
                              ),
                          children: isByAuthor
                              ? [
                                  TextSpan(
                                    text: ' (Author)',
                                    style: TextStyle(
                                      color: AppPalette.primaryLight,
                                      fontWeight: FontWeight.w600,
                                      fontSize: 10,
                                    ),
                                  ),
                                ]
                              : const [],
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        textDirection: TextDirection.ltr,
                      ),
                      Html(
                        data: "<p>${c.text}</p>",
                        style: {
                          "p": Style(
                            margin: Margins.zero,
                            padding: HtmlPaddings.zero,
                            lineHeight: LineHeight.rem(1.4),
                            fontSize: FontSize.medium,
                            color: Colors.black,
                            direction: textDirection,
                          ),
                        },
                      ),

                      // tiny loader under a root while its replies load
                      if (isRoot && isExpanded && loadingChildren)
                        const Padding(
                          padding: EdgeInsets.only(top: 6),
                          child: SizedBox(
                            width: 18,
                            height: 18,
                            child: CircularProgressIndicator(strokeWidth: 2),
                          ),
                        ),
                    ],
                  ),
                ),

                const SizedBox(width: 10),

                //  likes + replies icon
                Column(
                  mainAxisAlignment: MainAxisAlignment.start,
                  children: [
                    Visibility(
                      visible: c.likes > 0,
                      maintainSize: true,
                      maintainAnimation: true,
                      maintainState: true,
                      child: Column(
                        children: [
                          SvgPicture.asset("assets/icons/heart_icon.svg"),
                          Text(
                            (c.likes < 1000) ? "${c.likes}" : "\u221E",
                            style: Theme.of(context).textTheme.labelMedium
                                ?.copyWith(
                                  color: const Color(0xFFDB2F2F),
                                  fontWeight: FontWeight.bold,
                                ),
                            textAlign: TextAlign.center,
                          ),
                        ],
                      ),
                    ),
                    if (isRoot && (c.repliesCount) > 0 && (c.likes) > 0)
                      const SizedBox(height: 10),
                    if (isRoot && (c.repliesCount) > 0)
                      Column(
                        children: [
                          InkWell(
                            onTap: onToggleReplies,
                            child: SvgPicture.asset(
                              "assets/icons/commet_replies_icon.svg",
                            ),
                          ),
                          Text(
                            (c.repliesCount < 1000)
                                ? "${c.repliesCount}"
                                : "\u221E",
                            style: Theme.of(context).textTheme.labelMedium
                                ?.copyWith(
                                  color: AppPalette.primary,
                                  fontWeight: FontWeight.bold,
                                ),
                            textAlign: TextAlign.center,
                          ),
                        ],
                      ),
                  ],
                ),
              ],
            ),
        ),
      ),
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

enum NavDir { prev, next }

class CommentsParagraphNavArrow extends StatelessWidget {
  const CommentsParagraphNavArrow({
    super.key,
    required this.dir,
    required this.storyId,
    required this.current,
    required this.iconAsset,
    this.disabledOpacity = 0.35,
  });

  final NavDir dir;
  final int storyId;
  final Paragraph current;
  final String iconAsset;
  final double disabledOpacity;

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<PartBloc, PartState>(
      builder: (context, state) {
        if (state is! PartLoaded) {
          return const SizedBox.shrink();
        }

        final paragraphs = state.info.paragraphs;
        final currIdx = paragraphs.indexWhere(
              (x) => x.paragraphId == current.paragraphId,
        );

        Paragraph? target;
        if (dir == NavDir.prev) {
          for (int i = (currIdx < 0 ? paragraphs.length - 1 : currIdx - 1);
          i >= 0;
          i--) {
            final q = paragraphs[i];
            if ((q.commentsCount ?? 0) > 0) {
              target = q;
              break;
            }
          }
        } else {
          for (int i = (currIdx < 0 ? 0 : currIdx + 1);
          i < paragraphs.length;
          i++) {
            final q = paragraphs[i];
            if ((q.commentsCount ?? 0) > 0) {
              target = q;
              break;
            }
          }
        }

        final hasTarget = target != null;

        return IgnorePointer(
          ignoring: !hasTarget,
          child: Opacity(
            opacity: hasTarget ? 1.0 : disabledOpacity,
            child: GestureDetector(
              onTap: () {
                final next = target;
                if (next == null) return;
                context.read<PartSidePanelCubit>().changeContent(
                  PartSidePanelCommentsCubit(
                    storyId: storyId,
                    paragraph: next,
                  ),
                );
              },
              child: SvgPicture.asset(iconAsset),
            ),
          ),
        );
      },
    );
  }
}

