import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_inner_shadow/flutter_inner_shadow.dart';
import 'package:flutter_svg/svg.dart';
import 'package:locallibrary/wattpad_publisher/bloc/windows_bloc.dart';

import '../../core/theme/app_palette.dart';
import '../../dependency_ingection.dart';

class SingleWindowActivatorButton extends StatelessWidget {
  final String windowName;
  final VoidCallback onTap;
  final String toolTip;
  final String openedIconPath;
  final String closedIconPath;
  final double width;
  final double iconWidth;

  const SingleWindowActivatorButton({
    super.key,
    required this.windowName,
    required this.onTap,
    required this.toolTip,
    required this.openedIconPath,
    required this.closedIconPath,
    this.width = 44,
    this.iconWidth = 24,
  });

  factory SingleWindowActivatorButton.scrape() {
    return SingleWindowActivatorButton(
      windowName: 'scrape',
      onTap: () => sl.get<WindowsBloc>().add(OpenWindowRequested.scrape()),
      toolTip: 'add story',
      openedIconPath: 'assets/icons/add_icon_dark.svg',
      closedIconPath: 'assets/icons/add_icon_light.svg',
    );
  }

  factory SingleWindowActivatorButton.settings(int storyId) {
    return SingleWindowActivatorButton(
      windowName: 'settings',
      onTap: () =>
          () => {},
      toolTip: 'open settings',
      openedIconPath: "assets/icons/settings_icon_dark.svg",
      closedIconPath: "assets/icons/settings_icon_light.svg",
    );
  }

  @override
  Widget build(BuildContext context) {
    return BlocSelector<WindowsBloc, WindowsState, bool>(
      selector: (s) => s.idByName.containsKey(windowName),
      bloc: sl.get<WindowsBloc>(),
      builder: (context, opened) {
        final bg = opened ? AppPalette.surfaceAlt : AppPalette.transparent;
        final borderColor = opened
            ? AppPalette.primary.withOpacity(0.15)
            : AppPalette.transparent;

        final content = Container(
          width: width,
          height: width,
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: bg,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: borderColor),
          ),
          child: Center(
            child: SvgPicture.asset(
              opened ? openedIconPath : closedIconPath,
              width: iconWidth,
              height: iconWidth,
              fit: BoxFit.contain,
            ),
          ),
        );

        final withShadow = opened
            ? InnerShadow(
                shadows: [
                  Shadow(
                    offset: const Offset(2, 4),
                    color: AppPalette.primary.withOpacity(0.15),
                    blurRadius: 8,
                  ),
                ],
                child: content,
              )
            : content;

        return Tooltip(
          message: toolTip,
          waitDuration: const Duration(milliseconds: 400),
          verticalOffset: 12,
          preferBelow: true,
          child: Material(
            color: Colors.transparent,
            child: Padding(
              padding: const EdgeInsets.all(4),
              child: Ink(
                child: InkWell(
                  onTap: onTap,
                  enableFeedback: !opened,
                  borderRadius: BorderRadius.circular(12),
                  hoverColor: AppPalette.primary.withOpacity(0.06),
                  highlightColor: AppPalette.primary.withOpacity(0.08),
                  splashColor: AppPalette.primary.withOpacity(0.12),
                  child: withShadow,
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}
