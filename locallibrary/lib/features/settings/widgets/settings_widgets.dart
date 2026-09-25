import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../../core/theme/app_palette.dart';

// ─── section header ───────────────────────────────────────────────────────────

class SettingsSectionHeader extends StatelessWidget {
  final String label;

  const SettingsSectionHeader(this.label, {super.key});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(left: 4, bottom: 8),
      child: Text(
        label,
        style: TextStyle(
          fontSize: 11,
          fontWeight: FontWeight.w600,
          letterSpacing: 1.4,
          color: context.colors.gray,
        ),
      ),
    );
  }
}

// ─── settings card ────────────────────────────────────────────────────────────

class SettingsCard extends StatelessWidget {
  final List<Widget> children;

  const SettingsCard({super.key, required this.children});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: context.colors.surface,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: context.colors.primaryExtraLight, width: 1),
      ),
      clipBehavior: Clip.hardEdge,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: children,
      ),
    );
  }
}

// ─── settings row ─────────────────────────────────────────────────────────────

class SettingsRow extends StatelessWidget {
  final IconData icon;
  final String label;
  final Widget trailing;

  const SettingsRow({
    super.key,
    required this.icon,
    required this.label,
    required this.trailing,
  });

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final narrow = constraints.maxWidth < 360;
        return Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          child: narrow
              ? Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  spacing: 10,
                  children: [
                    Row(
                      spacing: 12,
                      children: [
                        Icon(icon, size: 18, color: context.colors.primary),
                        Text(
                          label,
                          style: TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w500,
                            color: context.colors.textPrimary,
                          ),
                        ),
                      ],
                    ),
                    Center(child: trailing),
                  ],
                )
              : Row(
                  spacing: 12,
                  children: [
                    Icon(icon, size: 18, color: context.colors.primary),
                    Text(
                      label,
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w500,
                        color: context.colors.textPrimary,
                      ),
                    ),
                    const Spacer(),
                    trailing,
                  ],
                ),
        );
      },
    );
  }
}

// ─── row divider ─────────────────────────────────────────────────────────────

class SettingsRowDivider extends StatelessWidget {
  const SettingsRowDivider({super.key});

  @override
  Widget build(BuildContext context) {
    return Divider(
      height: 1,
      indent: 48,
      endIndent: 0,
      color: context.colors.primaryExtraLight,
    );
  }
}

// ─── api url display ──────────────────────────────────────────────────────────

class ApiUrlDisplay extends StatefulWidget {
  final String url;

  const ApiUrlDisplay({super.key, required this.url});

  @override
  State<ApiUrlDisplay> createState() => _ApiUrlDisplayState();
}

class _ApiUrlDisplayState extends State<ApiUrlDisplay> {
  bool _copied = false;

  Future<void> _copy() async {
    await Clipboard.setData(ClipboardData(text: widget.url));
    setState(() => _copied = true);
    await Future.delayed(const Duration(seconds: 2));
    if (mounted) setState(() => _copied = false);
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: _copy,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
        decoration: BoxDecoration(
          color: _copied
              ? context.colors.success.withOpacity(0.15)
              : context.colors.primaryExtraLight,
          borderRadius: BorderRadius.circular(8),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          spacing: 6,
          children: [
            Text(
              widget.url,
              style: TextStyle(
                fontSize: 12,
                color: _copied
                    ? context.colors.success
                    : context.colors.primary,
                fontWeight: FontWeight.w500,
                fontFamily: 'monospace',
              ),
            ),
            Icon(
              _copied ? Icons.check_rounded : Icons.copy_rounded,
              size: 13,
              color: _copied
                  ? context.colors.success
                  : context.colors.primaryLight,
            ),
          ],
        ),
      ),
    );
  }
}
