import 'package:flutter/material.dart';

import '../../../core/theme/app_palette.dart';
import '../models/domain/story_model.dart';

class StoryTagsWrap extends StatelessWidget {
  const StoryTagsWrap({
    super.key,
    required this.tags,
    this.fontSize = 16,
    this.onTagTap,
  });

  final List<Tag> tags;
  final double fontSize;
  final ValueChanged<Tag>? onTagTap;

  @override
  Widget build(BuildContext context) {
    return Wrap(
      spacing: 10,
      runSpacing: 10,
      runAlignment: WrapAlignment.start,
      alignment: WrapAlignment.start,
      crossAxisAlignment: WrapCrossAlignment.start,
      children: [
        for (var t in tags)
          GestureDetector(
            onTap: onTagTap != null ? () => onTagTap!(t) : null,
            child: Container(
              padding: EdgeInsets.symmetric(
                vertical: fontSize / 3,
                horizontal: fontSize - 2,
              ),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.all(Radius.circular(50)),
                color: AppPalette.primaryLight,
              ),
              child: Text(
                t.name,
                style: Theme.of(
                  context,
                ).textTheme.labelMedium?.copyWith(fontSize: fontSize),
              ),
            ),
          ),
      ],
    );
  }
}
