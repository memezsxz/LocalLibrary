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
      decoration: BoxDecoration(
        color: context.colors.background,
        border: Border(
          bottom: BorderSide(color: context.colors.primaryExtraLight),
        ),
      ),
      padding: const EdgeInsets.fromLTRB(14, 10, 14, 14),
      child: Html(
        data: p.contentType == ContentType.text
            ? "<p>${p.contentText}</p>"
            : "<p>html image or video</p>",
        style: {
          "p": AppTheme.paragraphsStyle(context).copyWith(
            fontSize: FontSize(13.5),
            direction: p.direction.toTextDirection,
          ),
        },
      ),
    );
  }
}
