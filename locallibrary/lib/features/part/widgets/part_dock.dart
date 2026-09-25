import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_inner_shadow/flutter_inner_shadow.dart';
import 'package:flutter_svg/svg.dart';

import '../../../core/theme/app_palette.dart';
import '../../library/cubit/navigation_cubit.dart';
import '../cubit/part_side_panel_cubit.dart';

class SidePanelDock extends StatelessWidget {
  const SidePanelDock({super.key, required this.size, required this.storyId});

  final double size;
  final int storyId;

  @override
  Widget build(BuildContext context) {
    const gap = 8.0;
    final panelCubit = context.read<PartSidePanelCubit>();

    return BlocBuilder<PartSidePanelCubit, PartSidePanelState>(
      bloc: panelCubit,
      builder: (context, selected) {
        final bool selectedInfo = selected is PartSidePanelPartInfoCubit;
        final bool selectedTypography =
            selected is PartSidePanelTypographyCubit;
        final bool selectedComments = selected is PartSidePanelCommentsCubit;

        return Column(
          mainAxisSize: MainAxisSize.max,
          children: [
            Expanded(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                mainAxisSize: MainAxisSize.max,
                children: [
                  _DockBtn(
                    size: size,
                    iconPath: 'assets/icons/parts_icon.svg',
                    selected: selectedInfo,
                    onTap: () => selectedInfo
                        ? panelCubit.clear()
                        : panelCubit.changeContent(
                            PartSidePanelPartInfoCubit(storyId),
                          ),
                  ),
                  const SizedBox(height: gap),
                  _DockBtn(
                    size: size,
                    iconPath: 'assets/icons/typography_icon.svg',
                    selected: selectedTypography,
                    onTap: () => selectedTypography
                        ? panelCubit.clear()
                        : panelCubit.changeContent(
                            PartSidePanelTypographyCubit(),
                          ),
                  ),
                  const SizedBox(height: gap),
                  _DockBtn(
                    size: size,
                    iconPath: 'assets/icons/comments_icon.svg',
                    selected: selectedComments,
                    onTap: () => selectedComments
                        ? panelCubit.clear()
                        : panelCubit.changeContent(
                            PartSidePanelCommentsCubit(storyId: storyId),
                          ),
                  ),
                ],
              ),
            ),
            _DockBtn(
              size: size,
              selected: false,
              iconWidget: Icon(
                Icons.arrow_back,
                color: context.colors.primary,
                size: size * 0.40,
              ),
              onTap: () => context.read<NavigationCubit>().pop(),
            ),
            const SizedBox(height: 8),
          ],
        );
      },
    );
  }
}

class _DockBtn extends StatelessWidget {
  const _DockBtn({
    required this.size,
    required this.onTap,
    required this.selected,
    this.iconPath,
    this.iconWidget,
  });

  final String? iconPath;
  final Widget? iconWidget;
  final double size;
  final VoidCallback onTap;
  final bool selected;

  @override
  Widget build(BuildContext context) {
    final inner = size * 0.40;

    const shape = RoundedRectangleBorder(
      borderRadius: BorderRadiusDirectional.horizontal(
        end: Radius.circular(50),
      ),
    );

    Widget core = ClipRect(
      clipper: ClipPad(padding: const EdgeInsets.all(30).copyWith(left: 0)),
      child: SizedBox(
        width: size,
        height: size,
        child: Material(
          clipBehavior: Clip.antiAlias,
          color: context.colors.surfaceAlt,
          shape: shape,
          elevation: selected ? 15 : 0,
          shadowColor: context.colors.primary.withOpacity(0.3),
          child: InkWell(
            customBorder: shape,
            onTap: onTap,
            overlayColor: WidgetStateProperty.all(AppPalette.transparent),
            child: Center(
              child: SizedBox(
                width: inner,
                height: inner,
                child:
                    iconWidget ??
                        SvgPicture.asset(
                            iconPath!, color: context.colors.primary),
              ),
            ),
          ),
        ),
      ),
    );

    if (!selected) {
      core = InnerShadow(
        shadows: [
          Shadow(
            color: context.colors.primary.withOpacity(0.35),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
        child: core,
      );
    }

    return core;
  }
}

class ClipPad extends CustomClipper<Rect> {
  const ClipPad({this.padding = EdgeInsets.zero});

  final EdgeInsets padding;

  @override
  Rect getClip(Size size) => padding.inflateRect(Offset.zero & size);

  @override
  bool shouldReclip(ClipPad oldClipper) => oldClipper.padding != padding;
}
