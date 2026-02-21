import 'package:flutter/material.dart';
import 'package:locallibrary/core/exstentions/scrape_status.dart';

import '../../core/theme/app_palette.dart';
import '../bloc/base_scrape_bloc.dart';


class SecondaryAction {
  final String label;
  final IconData? icon;
  final VoidCallback onTap;

  const SecondaryAction({required this.label, required this.onTap, this.icon});
}

class SplitFilledButton extends StatelessWidget {
  const SplitFilledButton({
    super.key,
    required this.status,
    required this.onPrimaryTap, // openEventInspector / start
    required this.onSecondary, // CancelRequested (when active)
    this.secondaryActions = const [], // options when NOT active
    this.size = SplitButtonSize.medium,
    this.labelStyle,
    this.borderRadius,
  });

  final ScrapeStatus status;
  final VoidCallback onPrimaryTap;
  final VoidCallback onSecondary;
  final List<SecondaryAction> secondaryActions;

  // ---- sizing (optional; matches earlier enum in our convo) ----
  final SplitButtonSize size;
  final TextStyle? labelStyle;
  final double? borderRadius;

  bool get _isActive =>
      status == ScrapeStatus.connecting || status == ScrapeStatus.streaming;

  double get _hPad =>
      switch (size) {
        SplitButtonSize.small => 10,
        SplitButtonSize.medium => 14,
        SplitButtonSize.large => 18,
      };

  double get _vPad =>
      switch (size) {
        SplitButtonSize.small => 8,
        SplitButtonSize.medium => 10,
        SplitButtonSize.large => 14,
      };

  double get _iconSize =>
      switch (size) {
        SplitButtonSize.small => 16,
        SplitButtonSize.medium => 18,
        SplitButtonSize.large => 22,
      };

  double get _stopSize =>
      switch (size) {
        SplitButtonSize.small => 18,
        SplitButtonSize.medium => 20,
        SplitButtonSize.large => 24,
      };

  double get _dividerHeight =>
      switch (size) {
        SplitButtonSize.small => 20,
        SplitButtonSize.medium => 24,
        SplitButtonSize.large => 28,
      };

  double get _radius =>
      borderRadius ??
          switch (size) {
            SplitButtonSize.small => 10,
            SplitButtonSize.medium => 12,
            SplitButtonSize.large => 14,
          };

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final bg = AppPalette.primaryLight;
    final fg = AppPalette.primary;

    return Material(
      color: bg,
      borderRadius: BorderRadius.circular(_radius),
      child: InkWell(
        borderRadius: BorderRadius.circular(_radius),
        onTap: onPrimaryTap,
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Primary side (status + label)
            Padding(
              padding: EdgeInsets.symmetric(horizontal: _hPad, vertical: _vPad),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  AnimatedSwitcher(
                    duration: const Duration(milliseconds: 180),
                    child: IconTheme.merge(
                      data: IconThemeData(color: fg, size: _iconSize),
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
                      style: (labelStyle ??
                          theme.textTheme.labelLarge ??
                          const TextStyle(fontSize: 14))
                          .copyWith(
                          color: fg, fontWeight: FontWeight.bold, height: 1),
                    ),
                  ),
                ],
              ),
            ),

            // Divider
            Container(
              width: 1,
              height: _dividerHeight,
              margin: const EdgeInsets.symmetric(horizontal: 4),
              color: fg.withOpacity(0.16),
            ),

            // Secondary side:
            // - If active → CANCEL (stop) icon button
            // - If NOT active:
            //     • If actions provided → 3-dots popup menu
            //     • Else → disabled stop icon (keeps layout consistent)
            Padding(
              padding: EdgeInsets.symmetric(
                horizontal: (_hPad * 0.6).clamp(6, 12),
                vertical: (_vPad * 0.6).clamp(4, 10),
              ),
              child: _isActive
                  ? IconButton(
                onPressed: onSecondary,
                icon: const Icon(Icons.stop),
                iconSize: _stopSize,
                color: fg,
                tooltip: 'Cancel',
                splashRadius: _radius + 8,
              )
                  : (secondaryActions.isNotEmpty
                  ? PopupMenuButton<SecondaryAction>(
                tooltip: 'More',
                onSelected: (a) => a.onTap(),
                itemBuilder: (ctx) =>
                    secondaryActions
                        .map((a) =>
                        PopupMenuItem<SecondaryAction>(
                          value: a,
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              if (a.icon != null) ...[
                                Icon(a.icon, size: 18),
                                const SizedBox(width: 8),
                              ],
                              Flexible(child: Text(a.label)),
                            ],
                          ),
                        ))
                        .toList(),
                child: Icon(Icons.more_vert, size: _stopSize, color: fg),
              )
                  : Icon(
                  Icons.stop, size: _stopSize, color: fg.withOpacity(0.38))),
            ),
            SizedBox(width: (_hPad * 0.2).clamp(2, 6).toDouble()),
          ],
        ),
      ),
    );
  }
}

// Reuse your earlier enum if you added it
enum SplitButtonSize { small, medium, large }
