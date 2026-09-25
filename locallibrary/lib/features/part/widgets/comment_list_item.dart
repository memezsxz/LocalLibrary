import 'package:flutter/material.dart';
import 'package:flutter_html/flutter_html.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:locallibrary/core/theme/app_palette.dart';

import '../../story/models/domain/comment_model.dart';

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
    this.isHighlighted = false,
  });

  final Comment comment;
  final int depth;
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

    return Padding(
      padding: EdgeInsetsDirectional.only(start: depth * 18.0),
      child: Container(
        decoration: BoxDecoration(
          color: isHighlighted
              ? context.colors.primaryExtraLight
              : context.colors.surfaceAlt,
          borderRadius: const BorderRadius.all(
            Radius.circular(8),
          ).copyWith(topLeft: const Radius.circular(3)),
          border: isHighlighted
              ? Border(
            left: BorderSide(color: context.colors.primary, width: 3),
                )
              : null,
        ),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 10),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text.rich(
                      TextSpan(
                        text: c.userName,
                        style: Theme.of(context).textTheme.labelMedium
                            ?.copyWith(
                          color: context.colors.primary,
                              fontWeight: FontWeight.bold,
                            ),
                        children: isByAuthor
                            ? [
                                TextSpan(
                                  text: ' (Author)',
                                  style: TextStyle(
                                    color: context.colors.primaryLight,
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
                          color: context.colors.textPrimary,
                          direction: textDirection,
                        ),
                      },
                    ),
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
                        SvgPicture.asset(
                          "assets/icons/heart_icon.svg",
                          colorFilter: ColorFilter.mode(
                            context.colors.error,
                            BlendMode.srcIn,
                          ),
                        ),
                        Text(
                          (c.likes < 1000) ? "${c.likes}" : "\u221E",
                          style: Theme.of(context).textTheme.labelMedium
                              ?.copyWith(
                            color: context.colors.error,
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
                            colorFilter: ColorFilter.mode(
                              context.colors.primary,
                              BlendMode.srcIn,
                            ),
                          ),
                        ),
                        Text(
                          (c.repliesCount < 1000)
                              ? "${c.repliesCount}"
                              : "\u221E",
                          style: Theme.of(context).textTheme.labelMedium
                              ?.copyWith(
                            color: context.colors.primary,
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
