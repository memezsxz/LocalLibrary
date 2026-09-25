import 'package:flutter/material.dart';
import 'package:flutter_html/flutter_html.dart';

import '../../../core/theme/app_theme.dart';
import '../../story/models/domain/part_model.dart';
import '../../story/models/domain/story_enums.dart';

class CommentsParagraphView extends StatelessWidget {
  const CommentsParagraphView({super.key, required this.p});

  final Paragraph p;

  @override
  Widget build(BuildContext context) {
    return Container(
      color: context.colors.surfaceAlt,
      child: Container(
        color: context.colors.background,
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 0, horizontal: 20),
          child: Html(
            data: p.contentType == ContentType.text
                ? "<p>${p.contentText}</p>"
                : "html image or video",
            style: {
              "p": Style(
                margin: Margins.zero,
                padding: HtmlPaddings.zero,
                lineHeight: LineHeight.rem(1.4),
                fontSize: FontSize.medium,
                color: context.colors.textPrimary,
                direction: p.direction.toTextDirection,
              ),
            },
          ),
        ),
      ),
    );
  }
}
