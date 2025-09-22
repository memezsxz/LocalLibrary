import 'package:flutter/material.dart';
import 'package:flutter_inner_shadow/flutter_inner_shadow.dart';
import 'package:flutter_svg/svg.dart';

import '../../core/theme/app_palette.dart';
import '../../window_service.dart';

class SingleWindowActivatorButton extends StatefulWidget {
  final VoidCallback onTap;
  final bool Function() checkOpened;
  final String toolTip;
  final String openedIconPath;
  final String closedIconPath;
  final double width;
  final double iconWidth;

  final ValueNotifier? refreshWhen;

  @override
  State<SingleWindowActivatorButton> createState() =>
      _SingleWindowActivatorButtonState();

  const SingleWindowActivatorButton({
    super.key,
    required this.onTap,
    required this.toolTip,
    required this.openedIconPath,
    required this.closedIconPath,
    required this.checkOpened,
    this.width = 44,
    this.iconWidth = 24,
    this.refreshWhen,
  });

  factory SingleWindowActivatorButton.settings() {
    return SingleWindowActivatorButton(
      onTap: () => {},
      toolTip: "settings",
      openedIconPath: "assets/icons/settings_icon_dark.svg",
      closedIconPath: "assets/icons/settings_icon_light.svg",
      checkOpened: () {
        return false;
      },
    );
  }

  factory SingleWindowActivatorButton.scrape() {
    return SingleWindowActivatorButton(
      onTap: () => {ScrapeStoryAppWindow.I.openOrFocus()},
      toolTip: "add story",
      openedIconPath: "assets/icons/add_icon_dark.svg",
      closedIconPath: "assets/icons/add_icon_light.svg",
      checkOpened: () => ScrapeStoryAppWindow.I.id.value != null,
      refreshWhen: ScrapeStoryAppWindow.I.id,
    );
  }
}

class _SingleWindowActivatorButtonState
    extends State<SingleWindowActivatorButton> {
  void _onExternalChange() {
    if (mounted) setState(() {});
  }

  @override
  void initState() {
    super.initState();
    widget.refreshWhen?.addListener(_onExternalChange);
  }

  @override
  void didUpdateWidget(covariant SingleWindowActivatorButton oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.refreshWhen != widget.refreshWhen) {
      oldWidget.refreshWhen?.removeListener(_onExternalChange);
      widget.refreshWhen?.addListener(_onExternalChange);
    }
  }

  @override
  void dispose() {
    widget.refreshWhen?.removeListener(_onExternalChange);
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final opened = widget.checkOpened();

    final bg = (opened) ? AppPalette.surfaceAlt : AppPalette.transparent;
    final borderColor = (opened)
        ? AppPalette.primary.withOpacity(0.15)
        : AppPalette.transparent;

    final content = Container(
      width: widget.width,
      height: widget.width,
      padding: const EdgeInsets.all(8),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: borderColor),
      ),
      child: Center(
        child: SvgPicture.asset(
          opened ? widget.openedIconPath : widget.closedIconPath,
          width: widget.iconWidth,
          height: widget.iconWidth,
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
      message: widget.toolTip,
      waitDuration: const Duration(milliseconds: 400),
      verticalOffset: 12,
      preferBelow: true,
      child: Material(
        color: Colors.transparent,
        child: Padding(
          padding: const EdgeInsets.all(4),
          child: Ink(
            child: InkWell(
              onTap: widget.onTap,
              // onHover: (h) => setState(() => _hover = h),
              // onHighlightChanged: (p) => setState(() => _pressed = p),
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
  }
}
