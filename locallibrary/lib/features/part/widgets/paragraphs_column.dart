import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_html/flutter_html.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../../core/extensions/image.dart';
import '../../../core/secrets/app_secrets.dart';
import '../../../core/theme/app_theme.dart';
import '../../comments/widgets/comment_icon.dart';
import '../../story/bloc/story_bloc.dart';
import '../../story/models/domain/story_enums.dart';
import '../../story/models/dto/part_full_info.dart';
import '../bloc/part_bloc.dart';
import '../cubit/part_side_panel_cubit.dart';

typedef ProgressRecord = ({int paragraphId});

class ParagraphsColumn extends StatefulWidget {
  const ParagraphsColumn({
    super.key,
    required this.info,
    required this.storyId,
    required this.scrollController,
    required this.progressNotifier,
    this.targetParagraphId,
    this.targetCommentId,
  });

  final PartFullInfo info;
  final int storyId;
  final ScrollController scrollController;
  final ValueNotifier<ProgressRecord?> progressNotifier;
  final int? targetParagraphId;
  final int? targetCommentId;

  @override
  State<ParagraphsColumn> createState() => _ParagraphsColumnState();
}

class _ParagraphsColumnState extends State<ParagraphsColumn> {
  final Map<String, GlobalKey> _paraKeys = {};
  Timer? _progressDebounce;

  GlobalKey _keyFor(String id) => _paraKeys.putIfAbsent(id, () => GlobalKey());

  void _scrollToParagraph(int paragraphId) {
    void attempt() {
      if (!mounted) return;
      final ctx = _keyFor('$paragraphId').currentContext;
      if (ctx == null) return;
      Scrollable.ensureVisible(
        ctx,
        duration: const Duration(milliseconds: 300),
        alignment: 0.1,
      );
    }

    // Header media (images/video) above the paragraphs can still be
    // decoding on the first frame, which shifts paragraph positions
    // after this runs. Re-run a couple of times to correct for that.
    attempt();
    Future.delayed(const Duration(milliseconds: 400), attempt);
    Future.delayed(const Duration(milliseconds: 900), attempt);
  }

  void _onScrollDebounce() {
    _progressDebounce?.cancel();
    _progressDebounce = Timer(
      const Duration(milliseconds: 600),
      _reportProgress,
    );
  }

  void _reportProgress() {
    if (!mounted) return;
    final paragraphs = widget.info.paragraphs;
    if (paragraphs.isEmpty) return;

    final screenH = MediaQuery
        .of(context)
        .size
        .height;
    int lastVisibleIndex = -1;
    int? lastVisibleId;

    for (var i = 0; i < paragraphs.length; i++) {
      final key = _paraKeys['${paragraphs[i].paragraphId}'];
      final ctx = key?.currentContext;
      if (ctx == null) continue;
      final box = ctx.findRenderObject() as RenderBox?;
      if (box == null) continue;
      final dy = box
          .localToGlobal(Offset.zero)
          .dy;
      if (dy < screenH * 0.75) {
        lastVisibleIndex = i;
        lastVisibleId = paragraphs[i].paragraphId;
      }
    }

    if (lastVisibleId == null) return;
    widget.progressNotifier.value = (paragraphId: lastVisibleId);
    context.read<PartBloc>().add(
      PartProgressUpdated(
        storyId: widget.storyId,
        lastParagraphId: lastVisibleId,
      ),
    );
  }

  @override
  void dispose() {
    widget.scrollController.removeListener(_onScrollDebounce);
    _progressDebounce?.cancel();
    super.dispose();
  }

  @override
  void initState() {
    super.initState();
    widget.scrollController.addListener(_onScrollDebounce);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;

      // Deep-link from notification: takes priority
      if (widget.targetParagraphId != null) {
        final para = widget.info.paragraphs
            .where((p) => p.paragraphId == widget.targetParagraphId)
            .firstOrNull;
        if (para != null) {
          _scrollToParagraph(para.paragraphId);
          context.read<PartSidePanelCubit>().changeContent(
            PartSidePanelCommentsCubit(
              storyId: widget.storyId,
              paragraph: para,
              targetCommentId: widget.targetCommentId,
            ),
          );
        }
        return;
      }

      // Default: restore reading progress
      final b = context.read<StoryBloc>().state.bundles[widget.storyId];
      if (b == null) return;
      if (b.currentPart?.partId != widget.info.part.partId) return;

      final targetId = b.storyProgress.lastParagraphId;
      if (targetId == null) return;

      _scrollToParagraph(targetId);
    });
  }

  @override
  Widget build(BuildContext context) {
    final info = widget.info;
    final b = context.read<StoryBloc>().state.bundles[widget.storyId];
    if (b == null) return const SizedBox.shrink();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: List.generate(info.paragraphs.length, (i) {
        final p = info.paragraphs[i];
        final hasComments = p.commentsCount > 0;

        Widget content = Html(
          data: p.content,
          style: {
            'p': AppTheme.paragraphsStyle(
              context,
            ).copyWith(direction: p.direction.toTextDirection),
          },
        );

        if (p.contentType == ContentType.image && p.media?.path != null) {
          content = ConstrainedBox(
            constraints: BoxConstraints(
              maxHeight: MediaQuery.of(context).size.height * 0.7,
            ),
            child: LocalImage.relative(
              storageRoot: AppSecrets.storageRoot,
              storyWattId: b.story.wattId,
              relativePath: p.media!.path!,
              width: double.infinity,
            ),
          );
        }

        if (p.contentType == ContentType.link ||
            p.contentType == ContentType.video ||
            (p.contentType == ContentType.image && p.media?.path == null)) {
          content = GestureDetector(
            onTap: () async {
              final url = Uri.parse('https://www.google.de/');
              if (await canLaunchUrl(url)) {
                await launchUrl(url, mode: LaunchMode.externalApplication);
              }
            },
            child: Text(
              'Open',
              style: TextStyle(color: context.colors.primary),
            ),
          );
        }

        return KeyedSubtree(
          key: _keyFor('${p.paragraphId}'),
          child: Padding(
            padding: const EdgeInsets.only(bottom: 16),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(child: content),
                // Wider on desktop — reads as a detached margin gutter
                // rather than crowding the text, like on phone.
                SizedBox(
                  width: MediaQuery
                      .of(context)
                      .size
                      .width >= 900 ? 20 : 8,
                ),
                CommentIcon(
                  count: p.commentsCount,
                  visible: hasComments,
                  onTap: () => context.read<PartSidePanelCubit>().changeContent(
                    PartSidePanelCommentsCubit(
                      storyId: widget.storyId,
                      paragraph: p,
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      }),
    );
  }
}
