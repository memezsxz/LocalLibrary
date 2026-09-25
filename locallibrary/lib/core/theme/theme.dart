import 'package:flutter/material.dart';
import 'package:flutter_html/flutter_html.dart';
import 'app_palette.dart';

class AppTheme {
  static Style paragraphsStyle(BuildContext context) =>
      Style(
    margin: Margins.zero,
    padding: HtmlPaddings.zero,
    lineHeight: LineHeight.rem(1.4),
    fontSize: FontSize.larger,
        color: context.colors.textPrimary,
        textDecorationColor: context.colors.textPrimary,
  );
}
