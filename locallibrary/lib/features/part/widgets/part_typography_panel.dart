import 'dart:io' show Platform;

import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/material.dart';

import '../../../core/theme/app_palette.dart';

bool get _isMobile => !kIsWeb && (Platform.isAndroid || Platform.isIOS);

bool get _isDesktop =>
    !kIsWeb && (Platform.isMacOS || Platform.isWindows || Platform.isLinux);

class PartTypographyPanel extends StatefulWidget {
  const PartTypographyPanel({super.key});

  @override
  State<PartTypographyPanel> createState() => _PartTypographyPanelState();
}

class _PartTypographyPanelState extends State<PartTypographyPanel> {
  // ── state ─────────────────────────────────────────────────────────────────
  double _brightness = 0.8;
  _ReadingTheme _theme = _ReadingTheme.light;
  _Orientation _orientation = _Orientation.auto;
  String _font = 'Default';
  _Spacing _spacing = _Spacing.normal;
  _Indent _indent = _Indent.none;
  _ReadingMode _mode = _ReadingMode.scrolling;
  bool _inlineComments = true;
  bool _statusBar = false;
  bool _volumeNav = true;
  bool _arrowNav = true;

  static const _fonts = [
    'Default',
    'Georgia',
    'Merriweather',
    'Open Sans',
    'Lato',
    'Roboto Slab',
  ];

  ButtonStyle get _segStyle => ButtonStyle(
    backgroundColor: WidgetStateProperty.resolveWith((states) {
      if (states.contains(WidgetState.selected)) return AppPalette.primary;
      return AppPalette.background;
    }),
    foregroundColor: WidgetStateProperty.resolveWith((states) {
      if (states.contains(WidgetState.selected)) return AppPalette.textOnLight;
      return AppPalette.textPrimary;
    }),
    side: const WidgetStatePropertyAll(
      BorderSide(color: AppPalette.primaryLight),
    ),
    tapTargetSize: MaterialTapTargetSize.shrinkWrap,
    visualDensity: VisualDensity.compact,
  );

  // ── build ─────────────────────────────────────────────────────────────────
  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.fromLTRB(14, 20, 14, 32),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // ── title ──
          const Padding(
            padding: EdgeInsets.only(left: 2, bottom: 20),
            child: Text(
              'Reading',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.w700,
                color: AppPalette.textPrimary,
                letterSpacing: -0.4,
              ),
            ),
          ),

          // ── DISPLAY ───────────────────────────────────────────────────────
          _SectionHeader('DISPLAY'),
          _PanelCard(
            children: [
              // Brightness
              Padding(
                padding: const EdgeInsets.fromLTRB(14, 12, 14, 4),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      spacing: 8,
                      children: [
                        const Icon(
                          Icons.brightness_6_rounded,
                          size: 16,
                          color: AppPalette.primary,
                        ),
                        const Text(
                          'Brightness',
                          style: TextStyle(
                            fontSize: 13,
                            fontWeight: FontWeight.w500,
                            color: AppPalette.textPrimary,
                          ),
                        ),
                        const Spacer(),
                        Text(
                          '${(_brightness * 100).toInt()}%',
                          style: const TextStyle(
                            fontSize: 12,
                            color: AppPalette.gray,
                          ),
                        ),
                      ],
                    ),
                    SliderTheme(
                      data: SliderTheme.of(context).copyWith(
                        trackHeight: 2,
                        thumbShape: const RoundSliderThumbShape(
                          enabledThumbRadius: 7,
                        ),
                        overlayShape: const RoundSliderOverlayShape(
                          overlayRadius: 14,
                        ),
                        activeTrackColor: AppPalette.primary,
                        inactiveTrackColor: AppPalette.primaryExtraLight,
                        thumbColor: AppPalette.primary,
                        overlayColor: AppPalette.primary.withOpacity(0.12),
                      ),
                      child: Slider(
                        value: _brightness,
                        onChanged: (v) => setState(() => _brightness = v),
                      ),
                    ),
                  ],
                ),
              ),
              const _RowDivider(),
              // Theme
              _ExpandableSegmentRow(
                icon: Icons.contrast_rounded,
                label: 'Theme',
                currentLabel: _theme == _ReadingTheme.light ? 'Light' : 'Dark',
                segment: SegmentedButton<_ReadingTheme>(
                  segments: const [
                    ButtonSegment(
                      value: _ReadingTheme.light,
                      icon: Icon(Icons.wb_sunny_rounded, size: 14),
                      label: Text('Light'),
                    ),
                    ButtonSegment(
                      value: _ReadingTheme.dark,
                      icon: Icon(Icons.nightlight_round, size: 14),
                      label: Text('Dark'),
                    ),
                  ],
                  selected: {_theme},
                  onSelectionChanged: (s) => setState(() => _theme = s.first),
                  style: _segStyle,
                ),
              ),
              const _RowDivider(),
              // Orientation
              _ExpandableSegmentRow(
                icon: Icons.screen_rotation_rounded,
                label: 'Orientation',
                currentLabel: switch (_orientation) {
                  _Orientation.portrait => 'Portrait',
                  _Orientation.auto => 'Auto',
                  _Orientation.landscape => 'Landscape',
                },
                segment: SegmentedButton<_Orientation>(
                  segments: const [
                    ButtonSegment(
                      value: _Orientation.portrait,
                      icon: Icon(Icons.stay_current_portrait_rounded, size: 18),
                      tooltip: 'Portrait',
                    ),
                    ButtonSegment(
                      value: _Orientation.auto,
                      icon: Icon(Icons.screen_rotation_rounded, size: 18),
                      tooltip: 'Auto',
                    ),
                    ButtonSegment(
                      value: _Orientation.landscape,
                      icon: Icon(
                        Icons.stay_current_landscape_rounded,
                        size: 18,
                      ),
                      tooltip: 'Landscape',
                    ),
                  ],
                  selected: {_orientation},
                  onSelectionChanged: (s) =>
                      setState(() => _orientation = s.first),
                  style: _segStyle,
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),

          // ── TYPOGRAPHY ────────────────────────────────────────────────────
          _SectionHeader('TYPOGRAPHY'),
          _PanelCard(
            children: [
              // Font
              _PanelRow(
                icon: Icons.font_download_rounded,
                label: 'Font',
                trailing: _FontDropdown(
                  value: _font,
                  fonts: _fonts,
                  onChanged: (v) => setState(() => _font = v!),
                ),
              ),
              const _RowDivider(),
              // Line spacing
              _ExpandableSegmentRow(
                icon: Icons.format_line_spacing_rounded,
                label: 'Line spacing',
                currentLabel: switch (_spacing) {
                  _Spacing.compact => '1×',
                  _Spacing.normal => '1.5×',
                  _Spacing.relaxed => '2×',
                },
                segment: SegmentedButton<_Spacing>(
                  segments: const [
                    ButtonSegment(value: _Spacing.compact, label: Text('1×')),
                    ButtonSegment(value: _Spacing.normal, label: Text('1.5×')),
                    ButtonSegment(value: _Spacing.relaxed, label: Text('2×')),
                  ],
                  selected: {_spacing},
                  onSelectionChanged: (s) => setState(() => _spacing = s.first),
                  style: _segStyle,
                ),
              ),
              const _RowDivider(),
              // Indent
              _ExpandableSegmentRow(
                icon: Icons.format_indent_increase_rounded,
                label: 'Indent',
                currentLabel: switch (_indent) {
                  _Indent.none => 'None',
                  _Indent.small => 'Small',
                  _Indent.large => 'Large',
                },
                segment: SegmentedButton<_Indent>(
                  segments: const [
                    ButtonSegment(value: _Indent.none, label: Text('None')),
                    ButtonSegment(value: _Indent.small, label: Text('Small')),
                    ButtonSegment(value: _Indent.large, label: Text('Large')),
                  ],
                  selected: {_indent},
                  onSelectionChanged: (s) => setState(() => _indent = s.first),
                  style: _segStyle,
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),

          // ── READING ───────────────────────────────────────────────────────
          _SectionHeader('READING'),
          _PanelCard(
            children: [
              // Mode
              _ExpandableSegmentRow(
                icon: Icons.import_contacts_rounded,
                label: 'Mode',
                currentLabel: _mode == _ReadingMode.scrolling
                    ? 'Scrolling'
                    : 'Paging',
                segment: SegmentedButton<_ReadingMode>(
                  segments: const [
                    ButtonSegment(
                      value: _ReadingMode.scrolling,
                      icon: Icon(Icons.swap_vert_rounded, size: 14),
                      label: Text('Scrolling'),
                    ),
                    ButtonSegment(
                      value: _ReadingMode.paging,
                      icon: Icon(Icons.auto_stories_rounded, size: 14),
                      label: Text('Paging'),
                    ),
                  ],
                  selected: {_mode},
                  onSelectionChanged: (s) => setState(() => _mode = s.first),
                  style: _segStyle,
                ),
              ),
              const _RowDivider(),
              // Inline comments
              _PanelSwitchRow(
                icon: Icons.chat_bubble_outline_rounded,
                label: 'Inline comments',
                value: _inlineComments,
                onChanged: (v) => setState(() => _inlineComments = v),
              ),
            ],
          ),
          const SizedBox(height: 20),

          // ── CONTROLS ─────────────────────────────────────────────────────
          _SectionHeader('CONTROLS'),
          _PanelCard(
            children: [
              _PanelSwitchRow(
                icon: Icons.web_asset_rounded,
                label: 'Status bar',
                value: _statusBar,
                onChanged: (v) => setState(() => _statusBar = v),
              ),
              if (_isMobile) ...[
                const _RowDivider(),
                _PanelSwitchRow(
                  icon: Icons.volume_up_rounded,
                  label: 'Vol. keys',
                  value: _volumeNav,
                  onChanged: (v) => setState(() => _volumeNav = v),
                ),
              ] else if (_isDesktop) ...[
                const _RowDivider(),
                _PanelSwitchRow(
                  icon: Icons.keyboard_rounded,
                  label: 'Arrow keys',
                  value: _arrowNav,
                  onChanged: (v) => setState(() => _arrowNav = v),
                ),
              ],
            ],
          ),
        ],
      ),
    );
  }
}

// ─── enums ────────────────────────────────────────────────────────────────────

enum _ReadingTheme { light, dark }

enum _Orientation { portrait, auto, landscape }

enum _Spacing { compact, normal, relaxed }

enum _Indent { none, small, large }

enum _ReadingMode { scrolling, paging }

// ─── expandable segment row ───────────────────────────────────────────────────

class _ExpandableSegmentRow extends StatefulWidget {
  final IconData icon;
  final String label;
  final String currentLabel;
  final Widget segment;

  const _ExpandableSegmentRow({
    required this.icon,
    required this.label,
    required this.currentLabel,
    required this.segment,
  });

  @override
  State<_ExpandableSegmentRow> createState() => _ExpandableSegmentRowState();
}

class _ExpandableSegmentRowState extends State<_ExpandableSegmentRow> {
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
                Icon(widget.icon, size: 16, color: AppPalette.primary),
                Text(
                  widget.label,
                  style: const TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w500,
                    color: AppPalette.textPrimary,
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
                          style: const TextStyle(
                            fontSize: 12,
                            color: AppPalette.gray,
                          ),
                        ),
                ),
                const SizedBox(width: 2),
                AnimatedRotation(
                  turns: _expanded ? 0.5 : 0,
                  duration: const Duration(milliseconds: 200),
                  curve: Curves.easeOutCubic,
                  child: const Icon(
                    Icons.expand_more_rounded,
                    size: 16,
                    color: AppPalette.gray,
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

// ─── section header ───────────────────────────────────────────────────────────

class _SectionHeader extends StatelessWidget {
  final String label;

  const _SectionHeader(this.label);

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

class _PanelCard extends StatelessWidget {
  final List<Widget> children;

  const _PanelCard({required this.children});

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

class _PanelRow extends StatelessWidget {
  final IconData icon;
  final String label;
  final Widget trailing;

  const _PanelRow({
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

class _PanelSwitchRow extends StatelessWidget {
  final IconData icon;
  final String label;
  final bool value;
  final ValueChanged<bool> onChanged;

  const _PanelSwitchRow({
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

class _RowDivider extends StatelessWidget {
  const _RowDivider();

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

class _FontDropdown extends StatelessWidget {
  final String value;
  final List<String> fonts;
  final ValueChanged<String?> onChanged;

  const _FontDropdown({
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
