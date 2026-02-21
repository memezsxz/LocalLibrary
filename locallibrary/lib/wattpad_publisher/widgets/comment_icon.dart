import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';

import '../../core/theme/app_palette.dart';

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

    final overlaid = Padding(
      padding: const EdgeInsets.only(top: 5),
      child: (count >= 1000)
          ? Icon(
        Icons.all_inclusive, // ∞
        size: size * 0.5,
        color: AppPalette.primary,
      )
          : Text(
        '$count',
        textAlign: TextAlign.center,
        style: TextStyle(
          fontSize: size * 0.4,
          height: 1.0,
          fontWeight: FontWeight.w700,
          color: AppPalette.primary,
          shadows: [
            Shadow(blurRadius: 2, color: Colors.black.withOpacity(0.35)),
          ],
        ),
      ),
    );

    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(size / 2),
      child: SizedBox(
        width: size,
        height: size,
        child: Stack(
          alignment: Alignment.topCenter,
          children: [
            SvgPicture.asset(
              'assets/icons/comment_icon.svg',
              width: size,
              height: size,
            ),
            overlaid,
          ],
        ),
      ),
    );
  }
}
