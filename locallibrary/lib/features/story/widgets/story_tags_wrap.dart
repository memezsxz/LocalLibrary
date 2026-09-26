import 'package:flutter/material.dart';

import '../../../core/theme/app_theme.dart';
import '../models/domain/story_model.dart';

class StoryTagsWrap extends StatelessWidget {
  const StoryTagsWrap({
    super.key,
    required this.tags,
    this.fontSize = 16,
    this.onTagTap,
    this.alignment = WrapAlignment.start,
  });

  final List<Tag> tags;
  final double fontSize;
  final ValueChanged<Tag>? onTagTap;
  final WrapAlignment alignment;

  static const _maxRows = 2;
  static const _spacing = 6.0;

  double _chipWidth(String label) {
    final painter = TextPainter(
      text: TextSpan(
        text: label,
        style: TextStyle(fontSize: fontSize, fontWeight: FontWeight.w600),
      ),
      textDirection: TextDirection.ltr,
    )
      ..layout();
    return painter.width + 2 * (fontSize - 2);
  }

  /// Greedily fits as many tags as possible into [_maxRows] rows at the
  /// given [maxWidth], reserving room on the last row for the "+N" chip if
  /// not everything fits — so the visible count adapts to the actual space
  /// instead of a fixed number, and tags are free to wrap onto a 2nd row.
  ({List<Tag> visible, int overflow}) _fit(double maxWidth) {
    double rowWidth = 0;
    int row = 0;
    int visibleCount = 0;

    for (final t in tags) {
      final w = _chipWidth(t.name);
      final needed = rowWidth == 0 ? w : rowWidth + _spacing + w;
      if (needed <= maxWidth) {
        rowWidth = needed;
        visibleCount++;
      } else {
        row++;
        if (row >= _maxRows) break;
        rowWidth = w > maxWidth ? maxWidth : w;
        visibleCount++;
      }
    }

    int overflow = tags.length - visibleCount;
    if (overflow > 0 && visibleCount > 0) {
      final plusWidth = _chipWidth('+$overflow');
      if (rowWidth + _spacing + plusWidth > maxWidth) {
        visibleCount--;
        overflow = tags.length - visibleCount;
      }
    }

    return (visible: tags.take(visibleCount).toList(), overflow: overflow);
  }

  Widget _chip(BuildContext context,
      String label, {
        required Color background,
        required Color color,
        Border? border,
        VoidCallback? onTap,
      }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: EdgeInsets.symmetric(
          vertical: fontSize / 3,
          horizontal: fontSize - 2,
        ),
        decoration: BoxDecoration(
          borderRadius: const BorderRadius.all(Radius.circular(100)),
          color: background,
          border: border,
        ),
        child: Text(
          label,
          style: TextStyle(
            fontSize: fontSize,
            fontWeight: FontWeight.w600,
            color: color,
          ),
        ),
      ),
    );
  }

  void _openAllTags(BuildContext context) {
    final isMobile = MediaQuery
        .of(context)
        .size
        .width < 600;
    final content = Padding(
      padding: const EdgeInsets.all(16),
      child: SingleChildScrollView(
        child: Wrap(
          spacing: 6,
          runSpacing: 6,
          alignment: alignment,
          children: [
            for (final t in tags)
              _chip(
                context,
                t.name,
                background: context.colors.primaryExtraLight,
                color: context.colors.primary,
                onTap: onTagTap != null
                    ? () {
                  Navigator.of(context).pop();
                  onTagTap!(t);
                }
                    : null,
              ),
          ],
        ),
      ),
    );

    if (isMobile) {
      showModalBottomSheet<void>(
        context: context,
        isScrollControlled: true,
        useSafeArea: true,
        builder: (_) =>
            DraggableScrollableSheet(
              initialChildSize: 0.5,
              minChildSize: 0.3,
              maxChildSize: 0.9,
              expand: false,
              builder: (_, scrollController) =>
                  SingleChildScrollView(
                    controller: scrollController,
                    child: content,
                  ),
            ),
      );
    } else {
      showDialog<void>(
        context: context,
        builder: (_) =>
            Dialog(
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
              ),
              child: ConstrainedBox(
                constraints: const BoxConstraints(
                    maxWidth: 480, maxHeight: 480),
                child: content,
              ),
            ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final fit = _fit(constraints.maxWidth);

        return Wrap(
          spacing: _spacing,
          runSpacing: _spacing,
          alignment: alignment,
          crossAxisAlignment: WrapCrossAlignment.start,
          children: [
            for (final t in fit.visible)
              _chip(
                context,
                t.name,
                background: context.colors.primaryExtraLight,
                color: context.colors.primary,
                onTap: onTagTap != null ? () => onTagTap!(t) : null,
              ),
            if (fit.overflow > 0)
              _chip(
                context,
                '+${fit.overflow}',
                background: Colors.transparent,
                color: context.colors.gray,
                border: Border.all(color: context.colors.primaryExtraLight),
                onTap: () => _openAllTags(context),
              ),
          ],
        );
      },
    );
  }
}
