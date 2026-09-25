import 'dart:io' show Platform;

import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../core/theme/app_theme.dart';
import '../../../dependency_injection.dart';
import '../cubit/reading_settings_cubit.dart';
import '../models/enum/reading_enums.dart';
import 'expandable_segment_row.dart';
import 'typography_panel_widgets.dart';

bool get _isMobile => !kIsWeb && (Platform.isAndroid || Platform.isIOS);

bool get _isDesktop =>
    !kIsWeb && (Platform.isMacOS || Platform.isWindows || Platform.isLinux);

const _fonts = [
  'Default',
  'Georgia',
  'Merriweather',
  'Open Sans',
  'Lato',
  'Roboto Slab',
];

class PartTypographyPanel extends StatelessWidget {
  const PartTypographyPanel({super.key});

  ButtonStyle _segStyle(BuildContext context) =>
      ButtonStyle(
    backgroundColor: WidgetStateProperty.resolveWith((states) {
      if (states.contains(WidgetState.selected)) return context.colors.primary;
      return context.colors.background;
    }),
    foregroundColor: WidgetStateProperty.resolveWith((states) {
      if (states.contains(WidgetState.selected))
        return context.colors.textOnLight;
      return context.colors.textPrimary;
    }),
        side: WidgetStatePropertyAll(
          BorderSide(color: context.colors.primaryLight),
    ),
    tapTargetSize: MaterialTapTargetSize.shrinkWrap,
    visualDensity: VisualDensity.compact,
  );

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<ReadingSettingsCubit, ReadingSettingsState>(
      bloc: sl<ReadingSettingsCubit>(),
      builder: (context, state) {
        final cubit = sl<ReadingSettingsCubit>();

        return SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(14, 20, 14, 32),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Padding(
                padding: const EdgeInsets.only(left: 2, bottom: 20),
                child: Text(
                  'Reading',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.w700,
                    color: context.colors.textPrimary,
                    letterSpacing: -0.4,
                  ),
                ),
              ),

              // ── DISPLAY ─────────────────────────────────────────────────
              TypographySectionHeader('DISPLAY'),
              TypographyPanelCard(
                children: [
                  Padding(
                    padding: const EdgeInsets.fromLTRB(14, 12, 14, 4),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          spacing: 8,
                          children: [
                            Icon(
                              Icons.brightness_6_rounded,
                              size: 16,
                              color: context.colors.primary,
                            ),
                            Text(
                              'Brightness',
                              style: TextStyle(
                                fontSize: 13,
                                fontWeight: FontWeight.w500,
                                color: context.colors.textPrimary,
                              ),
                            ),
                            const Spacer(),
                            Text(
                              '${(state.brightness * 100).toInt()}%',
                              style: TextStyle(
                                fontSize: 12,
                                color: context.colors.gray,
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
                            activeTrackColor: context.colors.primary,
                            inactiveTrackColor:
                            context.colors.primaryExtraLight,
                            thumbColor: context.colors.primary,
                            overlayColor: context.colors.primary.withOpacity(
                              0.12,
                            ),
                          ),
                          child: Slider(
                            value: state.brightness,
                            onChanged: cubit.setBrightness,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const TypographyRowDivider(),
                  ExpandableSegmentRow(
                    icon: Icons.contrast_rounded,
                    label: 'Theme',
                    currentLabel: state.theme == ReadingTheme.light
                        ? 'Light'
                        : 'Dark',
                    segment: SegmentedButton<ReadingTheme>(
                      segments: const [
                        ButtonSegment(
                          value: ReadingTheme.light,
                          icon: Icon(Icons.wb_sunny_rounded, size: 14),
                          label: Text('Light'),
                        ),
                        ButtonSegment(
                          value: ReadingTheme.dark,
                          icon: Icon(Icons.nightlight_round, size: 14),
                          label: Text('Dark'),
                        ),
                      ],
                      selected: {state.theme},
                      onSelectionChanged: (s) => cubit.setTheme(s.first),
                      style: _segStyle(context),
                    ),
                  ),
                  const TypographyRowDivider(),
                  ExpandableSegmentRow(
                    icon: Icons.screen_rotation_rounded,
                    label: 'Orientation',
                    currentLabel: switch (state.orientation) {
                      ReadingOrientation.portrait => 'Portrait',
                      ReadingOrientation.auto => 'Auto',
                      ReadingOrientation.landscape => 'Landscape',
                    },
                    segment: SegmentedButton<ReadingOrientation>(
                      segments: const [
                        ButtonSegment(
                          value: ReadingOrientation.portrait,
                          icon: Icon(
                            Icons.stay_current_portrait_rounded,
                            size: 18,
                          ),
                          tooltip: 'Portrait',
                        ),
                        ButtonSegment(
                          value: ReadingOrientation.auto,
                          icon: Icon(Icons.screen_rotation_rounded, size: 18),
                          tooltip: 'Auto',
                        ),
                        ButtonSegment(
                          value: ReadingOrientation.landscape,
                          icon: Icon(
                            Icons.stay_current_landscape_rounded,
                            size: 18,
                          ),
                          tooltip: 'Landscape',
                        ),
                      ],
                      selected: {state.orientation},
                      onSelectionChanged: (s) => cubit.setOrientation(s.first),
                      style: _segStyle(context),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 20),

              // ── TYPOGRAPHY ───────────────────────────────────────────────
              TypographySectionHeader('TYPOGRAPHY'),
              TypographyPanelCard(
                children: [
                  TypographyPanelRow(
                    icon: Icons.font_download_rounded,
                    label: 'Font',
                    trailing: TypographyFontDropdown(
                      value: state.font,
                      fonts: _fonts,
                      onChanged: (v) => cubit.setFont(v!),
                    ),
                  ),
                  const TypographyRowDivider(),
                  ExpandableSegmentRow(
                    icon: Icons.format_line_spacing_rounded,
                    label: 'Line spacing',
                    currentLabel: switch (state.spacing) {
                      ReadingSpacing.compact => '1×',
                      ReadingSpacing.normal => '1.5×',
                      ReadingSpacing.relaxed => '2×',
                    },
                    segment: SegmentedButton<ReadingSpacing>(
                      segments: const [
                        ButtonSegment(
                          value: ReadingSpacing.compact,
                          label: Text('1×'),
                        ),
                        ButtonSegment(
                          value: ReadingSpacing.normal,
                          label: Text('1.5×'),
                        ),
                        ButtonSegment(
                          value: ReadingSpacing.relaxed,
                          label: Text('2×'),
                        ),
                      ],
                      selected: {state.spacing},
                      onSelectionChanged: (s) => cubit.setSpacing(s.first),
                      style: _segStyle(context),
                    ),
                  ),
                  const TypographyRowDivider(),
                  ExpandableSegmentRow(
                    icon: Icons.format_indent_increase_rounded,
                    label: 'Indent',
                    currentLabel: switch (state.indent) {
                      ReadingIndent.none => 'None',
                      ReadingIndent.small => 'Small',
                      ReadingIndent.large => 'Large',
                    },
                    segment: SegmentedButton<ReadingIndent>(
                      segments: const [
                        ButtonSegment(
                          value: ReadingIndent.none,
                          label: Text('None'),
                        ),
                        ButtonSegment(
                          value: ReadingIndent.small,
                          label: Text('Small'),
                        ),
                        ButtonSegment(
                          value: ReadingIndent.large,
                          label: Text('Large'),
                        ),
                      ],
                      selected: {state.indent},
                      onSelectionChanged: (s) => cubit.setIndent(s.first),
                      style: _segStyle(context),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 20),

              // ── READING ──────────────────────────────────────────────────
              TypographySectionHeader('READING'),
              TypographyPanelCard(
                children: [
                  ExpandableSegmentRow(
                    icon: Icons.import_contacts_rounded,
                    label: 'Mode',
                    currentLabel: state.mode == ReadingMode.scrolling
                        ? 'Scrolling'
                        : 'Paging',
                    segment: SegmentedButton<ReadingMode>(
                      segments: const [
                        ButtonSegment(
                          value: ReadingMode.scrolling,
                          icon: Icon(Icons.swap_vert_rounded, size: 14),
                          label: Text('Scrolling'),
                        ),
                        ButtonSegment(
                          value: ReadingMode.paging,
                          icon: Icon(Icons.auto_stories_rounded, size: 14),
                          label: Text('Paging'),
                        ),
                      ],
                      selected: {state.mode},
                      onSelectionChanged: (s) => cubit.setMode(s.first),
                      style: _segStyle(context),
                    ),
                  ),
                  const TypographyRowDivider(),
                  TypographyPanelSwitchRow(
                    icon: Icons.chat_bubble_outline_rounded,
                    label: 'Inline comments',
                    value: state.inlineComments,
                    onChanged: cubit.setInlineComments,
                  ),
                ],
              ),
              const SizedBox(height: 20),

              // ── CONTROLS ─────────────────────────────────────────────────
              TypographySectionHeader('CONTROLS'),
              TypographyPanelCard(
                children: [
                  TypographyPanelSwitchRow(
                    icon: Icons.web_asset_rounded,
                    label: 'Status bar',
                    value: state.statusBar,
                    onChanged: cubit.setStatusBar,
                  ),
                  if (_isMobile) ...[
                    const TypographyRowDivider(),
                    TypographyPanelSwitchRow(
                      icon: Icons.volume_up_rounded,
                      label: 'Vol. keys',
                      value: state.volumeNav,
                      onChanged: cubit.setVolumeNav,
                    ),
                  ] else
                    if (_isDesktop) ...[
                    const TypographyRowDivider(),
                    TypographyPanelSwitchRow(
                      icon: Icons.keyboard_rounded,
                      label: 'Arrow keys',
                      value: state.arrowNav,
                      onChanged: cubit.setArrowNav,
                    ),
                  ],
                ],
              ),
            ],
          ),
        );
      },
    );
  }
}
