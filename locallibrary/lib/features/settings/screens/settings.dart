import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../core/secrets/app_secrets.dart';
import '../../../core/theme/app_palette.dart';
import '../../../dependency_injection.dart';
import '../../story/models/enum/book_size.dart';
import '../cubit/settings_cubit.dart';
import '../widgets/settings_widgets.dart';

class Settings extends StatefulWidget {
  const Settings({super.key});

  @override
  State<Settings> createState() => _SettingsState();
}

class _SettingsState extends State<Settings> {
  double _fontSize = 16;
  _FontFamily _fontFamily = _FontFamily.defaultFont;
  _AppTheme _theme = _AppTheme.system;

  ButtonStyle get _segStyle =>
      ButtonStyle(
        backgroundColor: WidgetStateProperty.resolveWith((states) {
          if (states.contains(WidgetState.selected)) return AppPalette.primary;
          return AppPalette.background;
        }),
        foregroundColor: WidgetStateProperty.resolveWith((states) {
          if (states.contains(WidgetState.selected))
            return AppPalette.textOnLight;
          return AppPalette.textPrimary;
        }),
        side: const WidgetStatePropertyAll(
          BorderSide(color: AppPalette.primaryLight),
        ),
        tapTargetSize: MaterialTapTargetSize.shrinkWrap,
        visualDensity: VisualDensity.compact,
      );

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.fromLTRB(20, 28, 20, 48),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Settings',
            style: TextStyle(
              fontSize: 26,
              fontWeight: FontWeight.w700,
              color: AppPalette.textPrimary,
              letterSpacing: -0.5,
            ),
          ),
          const SizedBox(height: 4),
          const Text(
            'Customize your reading experience',
            style: TextStyle(fontSize: 13, color: AppPalette.gray),
          ),
          const SizedBox(height: 32),

          // ── LIBRARY ──
          SettingsSectionHeader('LIBRARY'),
          SettingsCard(
            children: [
              SettingsRow(
                icon: Icons.grid_view_rounded,
                label: 'Book card size',
                trailing: BlocBuilder<SettingsCubit, SettingsState>(
                  bloc: sl<SettingsCubit>(),
                  builder: (context, state) {
                    return SegmentedButton<BookSize>(
                      segments: const [
                        ButtonSegment(value: BookSize.s, label: Text('S')),
                        ButtonSegment(value: BookSize.m, label: Text('M')),
                        ButtonSegment(value: BookSize.l, label: Text('L')),
                      ],
                      selected: {state.bookSize},
                      onSelectionChanged: (s) =>
                          sl<SettingsCubit>().setBookSize(s.first),
                      style: _segStyle,
                    );
                  },
                ),
              ),
            ],
          ),
          const SizedBox(height: 24),

          // ── READING ──
          SettingsSectionHeader('READING'),
          SettingsCard(
            children: [
              SettingsRow(
                icon: Icons.text_fields_rounded,
                label: 'Font size',
                trailing: Row(
                  mainAxisSize: MainAxisSize.min,
                  spacing: 8,
                  children: [
                    Text(
                      _fontSize.toInt().toString(),
                      style: const TextStyle(
                        fontSize: 13,
                        color: AppPalette.gray,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    SizedBox(
                      width: 120,
                      child: SliderTheme(
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
                          value: _fontSize,
                          min: 12,
                          max: 24,
                          divisions: 12,
                          onChanged: (v) => setState(() => _fontSize = v),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const SettingsRowDivider(),
              SettingsRow(
                icon: Icons.font_download_rounded,
                label: 'Font family',
                trailing: SegmentedButton<_FontFamily>(
                  segments: const [
                    ButtonSegment(
                      value: _FontFamily.defaultFont,
                      label: Text('Default'),
                    ),
                    ButtonSegment(
                      value: _FontFamily.serif,
                      label: Text('Serif'),
                    ),
                    ButtonSegment(
                      value: _FontFamily.mono,
                      label: Text('Mono'),
                    ),
                  ],
                  selected: {_fontFamily},
                  onSelectionChanged: (s) =>
                      setState(() => _fontFamily = s.first),
                  style: _segStyle,
                ),
              ),
            ],
          ),
          const SizedBox(height: 24),

          // ── APPEARANCE ──
          SettingsSectionHeader('APPEARANCE'),
          SettingsCard(
            children: [
              SettingsRow(
                icon: Icons.contrast_rounded,
                label: 'Theme',
                trailing: SegmentedButton<_AppTheme>(
                  segments: const [
                    ButtonSegment(
                      value: _AppTheme.light,
                      icon: Icon(Icons.light_mode_rounded, size: 16),
                      label: Text('Light'),
                    ),
                    ButtonSegment(
                      value: _AppTheme.system,
                      icon: Icon(Icons.phone_android_rounded, size: 16),
                      label: Text('System'),
                    ),
                    ButtonSegment(
                      value: _AppTheme.dark,
                      icon: Icon(Icons.dark_mode_rounded, size: 16),
                      label: Text('Dark'),
                    ),
                  ],
                  selected: {_theme},
                  onSelectionChanged: (s) => setState(() => _theme = s.first),
                  style: _segStyle,
                ),
              ),
            ],
          ),
          const SizedBox(height: 24),

          // ── CONNECTION ──
          SettingsSectionHeader('CONNECTION'),
          SettingsCard(
            children: [
              SettingsRow(
                icon: Icons.lan_rounded,
                label: 'API server',
                trailing: ApiUrlDisplay(url: AppSecrets.apiBaseUrl),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

// ─── enums ────────────────────────────────────────────────────────────────────

enum _FontFamily { defaultFont, serif, mono }

enum _AppTheme { light, system, dark }