import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';

import '../../../core/theme/app_theme.dart';

class StoryData extends StatelessWidget {
  StoryData({super.key, required this.image, required this.label, this.number});

  final SvgPicture image;
  final String label;
  final int? number;

  @override
  Widget build(BuildContext context) {
    final color = context.colors.primaryLight;
    return Row(
      crossAxisAlignment: CrossAxisAlignment.center,
      spacing: 10,
      children: [
        image,
        Text(
          label,
          style: Theme.of(context).textTheme.labelLarge?.copyWith(
            color: color,
            fontFamily: 'Courier New',
            fontSize: 18,
          ),
        ),
        if (number != null)
          Text(
            "$number",
            style: Theme.of(context).textTheme.labelLarge?.copyWith(
              color: color,
              fontWeight: FontWeight.bold,
              fontFamily: 'Courier New',
              fontSize: 18,
            ),
          ),
      ],
    );
  }
}
