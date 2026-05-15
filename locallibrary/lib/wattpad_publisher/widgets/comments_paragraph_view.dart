import 'package:flutter/material.dart';
import 'package:flutter_html/flutter_html.dart';

import '../../core/theme/app_palette.dart';
import '../models/models.dart';

class CommentsParagraphView extends StatelessWidget {
  const CommentsParagraphView({super.key, required this.p});

  final Paragraph p;

  @override
  Widget build(BuildContext context) {
    return Container(
      color: AppPalette.surfaceAlt,
      child: Container(
        color: Colors.white.withOpacity(0.7),
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
                color: Colors.black,
                direction: p.direction.toTextDirection,
              ),
            },
          ),
        ),
      ),
    );
  }
}
