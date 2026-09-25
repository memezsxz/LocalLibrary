import 'package:flutter/material.dart';

import '../../../core/theme/app_theme.dart';

enum PeekDirection { top, bottom }

class PartPeekBar extends StatelessWidget {
  const PartPeekBar({
    super.key,
    required this.overscroll,
    required this.threshold,
    required this.title,
    required this.loading,
    required this.direction,
  });

  final ValueNotifier<double> overscroll;
  final double threshold;
  final String title;
  final bool loading;
  final PeekDirection direction;

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<double>(
      valueListenable: overscroll,
      builder: (context, os, _) {
        final h = (os * 0.5).clamp(0.0, 72.0);
        if (h < 8) return const SizedBox.shrink();
        final progress = (os / threshold).clamp(0.0, 1.0);
        final isTop = direction == PeekDirection.top;

        final row = Row(
          children: [
            Icon(
              isTop ? Icons.arrow_upward : Icons.arrow_downward,
              color: context.colors.primary,
              size: 14,
            ),
            const SizedBox(width: 8),
            Expanded(
              child: Text(
                title,
                style: Theme.of(context).textTheme.labelSmall?.copyWith(
                  color: context.colors.primary,
                  fontFamily: 'Courier New',
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ),
            if (loading)
              const SizedBox(
                width: 12,
                height: 12,
                child: CircularProgressIndicator(strokeWidth: 1.5),
              ),
          ],
        );

        final bar = LinearProgressIndicator(
          value: progress,
          backgroundColor: context.colors.primaryLight.withOpacity(0.15),
          color: context.colors.primary,
          minHeight: 2,
        );

        return ClipRect(
          child: SizedBox(
            height: h,
            child: OverflowBox(
              minHeight: 0,
              maxHeight: double.infinity,
              alignment: isTop ? Alignment.bottomCenter : Alignment.topCenter,
              child: Container(
                color: context.colors.surfaceAlt.withOpacity(0.95),
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 6,
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: isTop
                      ? [row, const SizedBox(height: 4), bar]
                      : [bar, const SizedBox(height: 4), row],
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}
