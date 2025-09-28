import 'package:flutter/material.dart';
import 'package:locallibrary/core/exstentions/scrape_status.dart';

import '../../core/theme/app_palette.dart';
import '../bloc/base_scrape_bloc.dart';

class SplitFilledButton extends StatelessWidget {
  const SplitFilledButton({
    super.key,
    required this.status,
    required this.onPrimaryTap, // openEventInspector
    required this.onSecondary, // dispatch CancelRequested
  });

  final ScrapeStatus status;
  final VoidCallback onPrimaryTap;
  final VoidCallback onSecondary;

  bool get activeSecondary =>
      status == ScrapeStatus.connecting || status == ScrapeStatus.streaming;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final bg = AppPalette.primaryLight;
    final fg = AppPalette.primary;

    return Material(
      color: bg,
      borderRadius: BorderRadius.circular(12),
      child: InkWell(
        // Enable ink on the whole pill (primary action area still gets its own handler)
        borderRadius: BorderRadius.circular(12),
        onTap: onPrimaryTap,
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Primary side (status + label)
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  // status indicator (your extension getter)
                  AnimatedSwitcher(
                    duration: const Duration(milliseconds: 180),
                    child: IconTheme.merge(
                      data: IconThemeData(color: fg, size: 18),
                      child: KeyedSubtree(
                        key: ValueKey(status),
                        child: status.indicator,
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  AnimatedSwitcher(
                    duration: const Duration(milliseconds: 180),
                    child: Text(
                      status.title,
                      key: ValueKey(status.title),
                      style: theme.textTheme.labelLarge?.copyWith(
                        color: fg,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ],
              ),
            ),

            // Divider between primary/secondary
            Container(
              width: 1,
              height: 24,
              margin: const EdgeInsets.symmetric(horizontal: 4),
              color: fg.withOpacity(0.16),
            ),

            // Secondary side (Stop)
            InkResponse(
              onTap: activeSecondary ? onSecondary : null,
              radius: 24,
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
                child: Icon(
                  Icons.stop,
                  size: 20,
                  color: activeSecondary ? fg : fg.withOpacity(0.38),
                ),
              ),
            ),
            const SizedBox(width: 2),
          ],
        ),
      ),
    );
  }
}
