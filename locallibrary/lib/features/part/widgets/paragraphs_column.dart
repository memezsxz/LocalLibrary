import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_html/flutter_html.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../../core/extensions/image.dart';
import '../../../core/theme/theme.dart';
import '../../comments/widgets/comment_icon.dart';
import '../../story/bloc/story_bloc.dart';
import '../../story/models/domain/story_enums.dart';
import '../../story/models/dto/part_full_info.dart';
import '../cubit/part_side_panel_cubit.dart';

class ParagraphsColumn extends StatefulWidget {
  const ParagraphsColumn({
    super.key,
    required this.info,
    required this.storyId,
    this.targetParagraphId,
    this.targetCommentId,
  });

  final PartFullInfo info;
  final int storyId;
  final int? targetParagraphId;
  final int? targetCommentId;

  @override
  State<ParagraphsColumn> createState() => _ParagraphsColumnState();
}

class _ParagraphsColumnState extends State<ParagraphsColumn> {
  final Map<String, GlobalKey> _paraKeys = {};

  GlobalKey _keyFor(String id) => _paraKeys.putIfAbsent(id, () => GlobalKey());

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;

      // Deep-link from notification: takes priority
      if (widget.targetParagraphId != null) {
        final para = widget.info.paragraphs
            .where((p) => p.paragraphId == widget.targetParagraphId)
            .firstOrNull;
        if (para != null) {
          final ctx = _keyFor('${para.paragraphId}').currentContext;
          if (ctx != null) {
            Scrollable.ensureVisible(
              ctx,
              duration: const Duration(milliseconds: 500),
              alignment: 0.1,
            );
          }
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

      final ctx = _keyFor('$targetId').currentContext;
      if (ctx != null) {
        Scrollable.ensureVisible(
          ctx,
          duration: const Duration(milliseconds: 500),
          alignment: 0.1,
        );
      }
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
            'p': AppTheme.paragraphsStyle.copyWith(
              direction: p.direction.toTextDirection,
            ),
          },
        );

        if (p.contentType == ContentType.image && p.media?.path != null) {
          content = ConstrainedBox(
            constraints: BoxConstraints(
              maxHeight: MediaQuery.of(context).size.height * 0.7,
            ),
            child: LocalImage.relative(
              storageRoot: '/Users/meme/Desktop/storage',
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
            child: const Text('Open', style: TextStyle(color: Colors.blue)),
          );
        }

        return KeyedSubtree(
          key: _keyFor('${p.paragraphId}'),
          child: Padding(
            padding: const EdgeInsets.only(bottom: 16),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
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
                const SizedBox(width: 8),
                Expanded(child: content),
              ],
            ),
          ),
        );
      }),
    );
  }
}
