import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../core/secrets/app_secrets.dart';
import '../../../core/theme/app_palette.dart';
import '../../../dependency_injection.dart';
import '../../story/models/enum/book_size.dart';
import '../cubit/settings_cubit.dart';

class Settings extends StatefulWidget {
  const Settings({super.key});

  @override
  State<Settings> createState() => _SettingsState();
}

class _SettingsState extends State<Settings> {
  double _fontSize = 16;
  _FontFamily _fontFamily = _FontFamily.defaultFont;
  _AppTheme _theme = _AppTheme.system;

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.fromLTRB(20, 28, 20, 48),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // ── page title ──
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
          _SectionHeader('LIBRARY'),
          _SettingsCard(
            children: [
              _SettingsRow(
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
                      style: ButtonStyle(
                        backgroundColor:
                        WidgetStateProperty.resolveWith((states) {
                          if (states.contains(WidgetState.selected)) {
                            return AppPalette.primary;
                          }
                          return AppPalette.background;
                        }),
                        foregroundColor:
                        WidgetStateProperty.resolveWith((states) {
                          if (states.contains(WidgetState.selected)) {
                            return AppPalette.textOnLight;
                          }
                          return AppPalette.textPrimary;
                        }),
                        side: const WidgetStatePropertyAll(
                          BorderSide(color: AppPalette.primaryLight),
                        ),
                        tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                        visualDensity: VisualDensity.compact,
                      ),
                    );
                  },
                ),
              ),
            ],
          ),
          const SizedBox(height: 24),

          // ── READING ──
          _SectionHeader('READING'),
          _SettingsCard(
            children: [
              _SettingsRow(
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
                          overlayColor:
                          AppPalette.primary.withOpacity(0.12),
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
              const _RowDivider(),
              _SettingsRow(
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
                  style: ButtonStyle(
                    backgroundColor: WidgetStateProperty.resolveWith((states) {
                      if (states.contains(WidgetState.selected)) {
                        return AppPalette.primary;
                      }
                      return AppPalette.background;
                    }),
                    foregroundColor: WidgetStateProperty.resolveWith((states) {
                      if (states.contains(WidgetState.selected)) {
                        return AppPalette.textOnLight;
                      }
                      return AppPalette.textPrimary;
                    }),
                    side: const WidgetStatePropertyAll(
                      BorderSide(color: AppPalette.primaryLight),
                    ),
                    tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                    visualDensity: VisualDensity.compact,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 24),

          // ── APPEARANCE ──
          _SectionHeader('APPEARANCE'),
          _SettingsCard(
            children: [
              _SettingsRow(
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
                  style: ButtonStyle(
                    backgroundColor: WidgetStateProperty.resolveWith((states) {
                      if (states.contains(WidgetState.selected)) {
                        return AppPalette.primary;
                      }
                      return AppPalette.background;
                    }),
                    foregroundColor: WidgetStateProperty.resolveWith((states) {
                      if (states.contains(WidgetState.selected)) {
                        return AppPalette.textOnLight;
                      }
                      return AppPalette.textPrimary;
                    }),
                    side: const WidgetStatePropertyAll(
                      BorderSide(color: AppPalette.primaryLight),
                    ),
                    tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                    visualDensity: VisualDensity.compact,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 24),

          // ── CONNECTION ──
          _SectionHeader('CONNECTION'),
          _SettingsCard(
            children: [
              _SettingsRow(
                icon: Icons.lan_rounded,
                label: 'API server',
                trailing: _ApiUrlDisplay(url: AppSecrets.apiBaseUrl),
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
          fontSize: 11,
          fontWeight: FontWeight.w600,
          letterSpacing: 1.4,
          color: AppPalette.gray,
        ),
      ),
    );
  }
}

// ─── settings card ────────────────────────────────────────────────────────────

class _SettingsCard extends StatelessWidget {
  final List<Widget> children;

  const _SettingsCard({required this.children});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: AppPalette.surface,
        borderRadius: BorderRadius.circular(14),
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

// ─── settings row ─────────────────────────────────────────────────────────────

class _SettingsRow extends StatelessWidget {
  final IconData icon;
  final String label;
  final Widget trailing;

  const _SettingsRow({
    required this.icon,
    required this.label,
    required this.trailing,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      child: Row(
        spacing: 12,
        children: [
          Icon(icon, size: 18, color: AppPalette.primary),
          Text(
            label,
            style: const TextStyle(
              fontSize: 14,
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

// ─── row divider ─────────────────────────────────────────────────────────────

class _RowDivider extends StatelessWidget {
  const _RowDivider();

  @override
  Widget build(BuildContext context) {
    return const Divider(
      height: 1,
      indent: 48,
      endIndent: 0,
      color: AppPalette.primaryExtraLight,
    );
  }
}

// ─── api url display ──────────────────────────────────────────────────────────

class _ApiUrlDisplay extends StatefulWidget {
  final String url;

  const _ApiUrlDisplay({required this.url});

  @override
  State<_ApiUrlDisplay> createState() => _ApiUrlDisplayState();
}

class _ApiUrlDisplayState extends State<_ApiUrlDisplay> {
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
              ? Colors.green.shade50
              : AppPalette.primaryExtraLight,
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
                color: _copied ? Colors.green.shade700 : AppPalette.primary,
                fontWeight: FontWeight.w500,
                fontFamily: 'monospace',
              ),
            ),
            Icon(
              _copied ? Icons.check_rounded : Icons.copy_rounded,
              size: 13,
              color: _copied ? Colors.green.shade600 : AppPalette.primaryLight,
            ),
          ],
        ),
      ),
    );
  }
}