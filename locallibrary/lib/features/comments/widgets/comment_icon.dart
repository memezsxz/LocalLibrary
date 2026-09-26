import 'package:flutter/material.dart';

import '../../../core/theme/app_theme.dart';

class CommentIcon extends StatelessWidget {
  const CommentIcon({
    super.key,
    required this.count,
    required this.visible,
    this.onTap,
    this.size = 28,
  });

  final int count;
  final bool visible;
  final VoidCallback? onTap;
  final double size;

  @override
  Widget build(BuildContext context) {
    if (!visible) return SizedBox(width: size, height: size);

    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(100),
      child: SizedBox(
        width: size,
        height: size,
        child: Center(
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
            decoration: BoxDecoration(
              color: context.colors.primaryExtraLight,
              borderRadius: BorderRadius.circular(100),
            ),
            child: Text(
              count >= 1000 ? '999+' : '$count',
              style: TextStyle(
                fontSize: 10,
                height: 1.3,
                fontWeight: FontWeight.w700,
                color: context.colors.primary,
              ),
            ),
          ),
        ),
      ),
    );
  }
}
