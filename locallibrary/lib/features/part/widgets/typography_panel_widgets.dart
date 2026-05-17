import 'package:flutter/material.dart';

import '../../../core/theme/app_palette.dart';

// ─── section header ───────────────────────────────────────────────────────────

class TypographySectionHeader extends StatelessWidget {
  final String label;

  const TypographySectionHeader(this.label, {super.key});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(left: 4, bottom: 8),
      child: Text(
        label,
        style: const TextStyle(
          fontSize: 10,
          fontWeight: FontWeight.w600,
          letterSpacing: 1.4,
          color: AppPalette.gray,
        ),
      ),
    );
  }
}

// ─── panel card ───────────────────────────────────────────────────────────────

class TypographyPanelCard extends StatelessWidget {
  final List<Widget> children;

  const TypographyPanelCard({super.key, required this.children});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: AppPalette.background,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppPalette.primaryExtraLight, width: 1),
      ),
      clipBehavior: Clip.hardEdge,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: children,
      ),
    );
  }
}

// ─── panel row ────────────────────────────────────────────────────────────────

class TypographyPanelRow extends StatelessWidget {
  final IconData icon;
  final String label;
  final Widget trailing;

  const TypographyPanelRow({
    super.key,
    required this.icon,
    required this.label,
    required this.trailing,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 11),
      child: Row(
        spacing: 10,
        children: [
          Icon(icon, size: 16, color: AppPalette.primary),
          Text(
            label,
            style: const TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w500,
              color: AppPalette.textPrimary,
            ),
          ),
          const Spacer(),
          trailing,
        ],
      ),
    );
  }
}

// ─── panel switch row ─────────────────────────────────────────────────────────

class TypographyPanelSwitchRow extends StatelessWidget {
  final IconData icon;
  final String label;
  final bool value;
  final ValueChanged<bool> onChanged;

  const TypographyPanelSwitchRow({
    super.key,
    required this.icon,
    required this.label,
    required this.value,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
      child: Row(
        spacing: 10,
        children: [
          Icon(icon, size: 16, color: AppPalette.primary),
          Text(
            label,
            style: const TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w500,
              color: AppPalette.textPrimary,
            ),
          ),
          const Spacer(),
          Switch(
            value: value,
            onChanged: onChanged,
            activeColor: AppPalette.primary,
            activeTrackColor: AppPalette.primaryLight,
            inactiveThumbColor: AppPalette.gray,
            inactiveTrackColor: AppPalette.primaryExtraLight,
            materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
          ),
        ],
      ),
    );
  }
}

// ─── row divider ─────────────────────────────────────────────────────────────

class TypographyRowDivider extends StatelessWidget {
  const TypographyRowDivider({super.key});

  @override
  Widget build(BuildContext context) {
    return const Divider(
      height: 1,
      indent: 40,
      color: AppPalette.primaryExtraLight,
    );
  }
}

// ─── font dropdown ────────────────────────────────────────────────────────────

class TypographyFontDropdown extends StatelessWidget {
  final String value;
  final List<String> fonts;
  final ValueChanged<String?> onChanged;

  const TypographyFontDropdown({
    super.key,
    required this.value,
    required this.fonts,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 2),
      decoration: BoxDecoration(
        color: AppPalette.primaryExtraLight,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: AppPalette.primaryLight, width: 0.8),
      ),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<String>(
          value: value,
          isDense: true,
          style: const TextStyle(
            fontSize: 13,
            color: AppPalette.textPrimary,
            fontWeight: FontWeight.w500,
          ),
          icon: const Icon(
            Icons.expand_more_rounded,
            size: 16,
            color: AppPalette.primary,
          ),
          dropdownColor: AppPalette.surface,
          borderRadius: BorderRadius.circular(10),
          items: fonts
              .map((f) => DropdownMenuItem(value: f, child: Text(f)))
              .toList(),
          onChanged: onChanged,
        ),
      ),
    );
  }
}
