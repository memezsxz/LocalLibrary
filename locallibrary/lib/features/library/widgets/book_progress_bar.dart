import 'package:flutter/material.dart';
import 'package:flutter_inner_shadow/flutter_inner_shadow.dart';
import 'package:locallibrary/core/theme/app_theme.dart';

class BookProgressBar extends StatelessWidget {
  final double progress;

  const BookProgressBar({super.key, this.progress = 0});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      height: 5,
      child: InnerShadow(
        shadows: [
          Shadow(
            color: Colors.black.withOpacity(0.25),
            blurRadius: 2,
            offset: Offset(0, 1),
          ),
        ],
        child: LinearProgressIndicator(
          color: context.colors.primaryLight,
          value: progress,
          backgroundColor: context.colors.primaryExtraLight,
          borderRadius: BorderRadius.all(Radius.circular(2)),
        ),
      ),
    );
  }
}
