import 'package:flutter/material.dart';

import '../../../core/theme/app_palette.dart';

class ExpandableSegmentRow extends StatefulWidget {
  final IconData icon;
  final String label;
  final String currentLabel;
  final Widget segment;

  const ExpandableSegmentRow({
    super.key,
    required this.icon,
    required this.label,
    required this.currentLabel,
    required this.segment,
  });

  @override
  State<ExpandableSegmentRow> createState() => _ExpandableSegmentRowState();
}

class _ExpandableSegmentRowState extends State<ExpandableSegmentRow> {
  bool _expanded = false;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        GestureDetector(
          onTap: () => setState(() => _expanded = !_expanded),
          behavior: HitTestBehavior.opaque,
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 11),
            child: Row(
              spacing: 10,
              children: [
                Icon(widget.icon, size: 16, color: context.colors.primary),
                Text(
                  widget.label,
                  style: TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w500,
                    color: context.colors.textPrimary,
                  ),
                ),
                const Spacer(),
                AnimatedSwitcher(
                  duration: const Duration(milliseconds: 180),
                  child: _expanded
                      ? const SizedBox.shrink()
                      : Text(
                          widget.currentLabel,
                          key: ValueKey(widget.currentLabel),
                    style: TextStyle(
                            fontSize: 12,
                      color: context.colors.gray,
                          ),
                        ),
                ),
                const SizedBox(width: 2),
                AnimatedRotation(
                  turns: _expanded ? 0.5 : 0,
                  duration: const Duration(milliseconds: 200),
                  curve: Curves.easeOutCubic,
                  child: Icon(
                    Icons.expand_more_rounded,
                    size: 16,
                    color: context.colors.gray,
                  ),
                ),
              ],
            ),
          ),
        ),
        AnimatedSize(
          duration: const Duration(milliseconds: 220),
          curve: Curves.easeOutCubic,
          child: _expanded
              ? Padding(
                  padding: const EdgeInsets.fromLTRB(14, 4, 14, 14),
                  child: Center(child: widget.segment),
                )
              : const SizedBox.shrink(),
        ),
      ],
    );
  }
}
