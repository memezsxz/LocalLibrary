import 'package:flutter/material.dart';
import 'package:flutter_html/flutter_html.dart';
import 'package:locallibrary/core/theme/app_theme.dart';

import '../../story/models/domain/comment_model.dart';

class CommentListItem extends StatelessWidget {
  const CommentListItem({
    super.key,
    required this.comment,
    required this.isRoot,
    required this.isExpanded,
    required this.loadingChildren,
    required this.textDirection,
    required this.onToggleReplies,
    this.isByAuthor = false,
    this.isHighlighted = false,
  });

  final Comment comment;
  final bool isRoot;
  final bool isExpanded;
  final bool loadingChildren;
  final TextDirection textDirection;
  final VoidCallback onToggleReplies;
  final bool isByAuthor;
  final bool isHighlighted;

  @override
  Widget build(BuildContext context) {
    final c = comment;

    return Container(
      decoration: BoxDecoration(
        color: isHighlighted
            ? context.colors.primaryExtraLight
            : context.colors.background,
        borderRadius: BorderRadius.circular(10),
        border: isHighlighted
            ? Border(left: BorderSide(color: context.colors.primary, width: 3))
            : null,
      ),
      padding: const EdgeInsets.symmetric(horizontal: 11, vertical: 10),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Text(
                c.userName,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w700,
                  color: context.colors.primary,
                ),
              ),
              if (isByAuthor)
                Padding(
                  padding: const EdgeInsets.only(left: 6),
                  child: Text(
                    'AUTHOR',
                    style: TextStyle(
                      fontSize: 9.5,
                      fontWeight: FontWeight.w700,
                      letterSpacing: 0.4,
                      color: context.colors.primaryLight,
                    ),
                  ),
                ),
              const Spacer(),
              if (c.likes > 0)
                Row(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(Icons.favorite, size: 13, color: context.colors.error),
                    const SizedBox(width: 3),
                    Text(
                      c.likes < 1000 ? '${c.likes}' : '∞',
                      style: TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.w600,
                        color: context.colors.gray,
                      ),
                    ),
                  ],
                ),
            ],
          ),
          const SizedBox(height: 3),
          Html(
            data: "<p>${c.text}</p>",
            style: {
              "p": Style(
                margin: Margins.zero,
                padding: HtmlPaddings.zero,
                lineHeight: LineHeight.rem(1.35),
                fontSize: FontSize.medium,
                color: context.colors.textPrimary,
                direction: textDirection,
              ),
            },
          ),
          if (isRoot && isExpanded && loadingChildren)
            const Padding(
              padding: EdgeInsets.only(top: 6),
              child: SizedBox(
                width: 16,
                height: 16,
                child: CircularProgressIndicator(strokeWidth: 2),
              ),
            ),
        ],
      ),
    );
  }
}

/// A root comment plus its replies, replies nested under a left rail —
/// the one shared shape for a comment thread, used by both the reading
/// screen's Comments panel and a notification's expanded thread preview.
/// Callers own how each [Comment] renders (highlight, author badge, tap
/// handling) via [buildItem]; this widget only owns the root/rail layout.
class CommentThreadGroup extends StatelessWidget {
  const CommentThreadGroup({
    super.key,
    required this.root,
    required this.replies,
    required this.buildItem,
    this.trailing,
  });

  final Comment root;
  final List<Comment> replies;
  final Widget Function(Comment comment) buildItem;
  final Widget? trailing;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        buildItem(root),
        if (replies.isNotEmpty)
          Container(
            margin: const EdgeInsets.only(left: 14, top: 6),
            padding: const EdgeInsets.only(left: 12),
            decoration: BoxDecoration(
              border: Border(
                left: BorderSide(color: context.colors.primaryLight, width: 2),
              ),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                for (final r in replies) ...[
                  buildItem(r),
                  const SizedBox(height: 6),
                ],
              ],
            ),
          ),
        if (trailing != null) trailing!,
      ],
    );
  }
}
