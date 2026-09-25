import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../core/secrets/app_secrets.dart';
import '../../../core/theme/app_palette.dart';
import '../../../dependency_injection.dart';
import '../../story/models/enum/book_size.dart';
import '../cubit/settings_cubit.dart';
import '../widgets/settings_widgets.dart';

class Settings extends StatelessWidget {
  const Settings({super.key});

  ButtonStyle _segStyle(BuildContext context) =>
      ButtonStyle(
        backgroundColor: WidgetStateProperty.resolveWith((states) {
          if (states.contains(WidgetState.selected))
            return context.colors.primary;
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
    return SingleChildScrollView(
      padding: const EdgeInsets.fromLTRB(20, 28, 20, 48),
      child: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 640),
          child: BlocBuilder<SettingsCubit, SettingsState>(
            bloc: sl<SettingsCubit>(),
            builder: (context, state) {
              final cubit = sl<SettingsCubit>();
              return Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Settings',
                    style: TextStyle(
                      fontSize: 26,
                      fontWeight: FontWeight.w700,
                      color: context.colors.textPrimary,
                      letterSpacing: -0.5,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'Customize your reading experience',
                    style: TextStyle(fontSize: 13, color: context.colors.gray),
                  ),
                  const SizedBox(height: 32),

                  // ── LIBRARY ──
                  SettingsSectionHeader('LIBRARY'),
                  SettingsCard(
                    children: [
                      SettingsRow(
                        icon: Icons.grid_view_rounded,
                        label: 'Book card size',
                        trailing: SegmentedButton<BookSize>(
                          segments: const [
                            ButtonSegment(value: BookSize.s, label: Text('S')),
                            ButtonSegment(value: BookSize.m, label: Text('M')),
                            ButtonSegment(value: BookSize.l, label: Text('L')),
                          ],
                          selected: {state.bookSize},
                          onSelectionChanged: (s) => cubit.setBookSize(s.first),
                          style: _segStyle(context),
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
                              state.fontSize.toInt().toString(),
                              style: TextStyle(
                                fontSize: 13,
                                color: context.colors.gray,
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
                                  activeTrackColor: context.colors.primary,
                                  inactiveTrackColor:
                                  context.colors.primaryExtraLight,
                                  thumbColor: context.colors.primary,
                                  overlayColor: context.colors.primary
                                      .withOpacity(0.12),
                                ),
                                child: Slider(
                                  value: state.fontSize,
                                  min: 12,
                                  max: 24,
                                  divisions: 12,
                                  onChanged: cubit.setFontSize,
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
                        trailing: SegmentedButton<AppFontFamily>(
                          segments: const [
                            ButtonSegment(
                              value: AppFontFamily.defaultFont,
                              label: Text('Default'),
                            ),
                            ButtonSegment(
                              value: AppFontFamily.serif,
                              label: Text('Serif'),
                            ),
                            ButtonSegment(
                              value: AppFontFamily.mono,
                              label: Text('Mono'),
                            ),
                          ],
                          selected: {state.fontFamily},
                          onSelectionChanged: (s) =>
                              cubit.setFontFamily(s.first),
                          style: _segStyle(context),
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
                        trailing: SegmentedButton<ThemeMode>(
                          segments: const [
                            ButtonSegment(
                              value: ThemeMode.light,
                              icon: Icon(Icons.light_mode_rounded, size: 16),
                              label: Text('Light'),
                            ),
                            ButtonSegment(
                              value: ThemeMode.system,
                              icon: Icon(Icons.phone_android_rounded, size: 16),
                              label: Text('System'),
                            ),
                            ButtonSegment(
                              value: ThemeMode.dark,
                              icon: Icon(Icons.dark_mode_rounded, size: 16),
                              label: Text('Dark'),
                            ),
                          ],
                          selected: {state.themeMode},
                          onSelectionChanged: (s) =>
                              cubit.setThemeMode(s.first),
                          style: _segStyle(context),
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
              );
            },
          ),
        ),
      ),
    );
  }
}
