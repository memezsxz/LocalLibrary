import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_svg/svg.dart';

import '../../../core/theme/app_theme.dart';
import '../cubit/part_side_panel_cubit.dart';

/// Left-edge sidebar for the reading screen (desktop) — a real flex
/// sibling of the content, same as the main app's nav rail, not an overlay.
class SidePanelDock extends StatelessWidget {
  const SidePanelDock({super.key, required this.size, required this.storyId});

  final double size;
  final int storyId;

  @override
  Widget build(BuildContext context) {
    final panelCubit = context.read<PartSidePanelCubit>();

    return BlocBuilder<PartSidePanelCubit, PartSidePanelState>(
      bloc: panelCubit,
      builder: (context, selected) {
        final bool selectedInfo = selected is PartSidePanelPartInfoCubit;
        final bool selectedTypography =
            selected is PartSidePanelTypographyCubit;
        final bool selectedComments = selected is PartSidePanelCommentsCubit;

        return Container(
          width: size,
          color: context.colors.surface,
          padding: const EdgeInsets.symmetric(vertical: 6, horizontal: 6),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              _DockItem(
                iconPath: 'assets/icons/parts_icon.svg',
                label: 'Story',
                selected: selectedInfo,
                onTap: () =>
                selectedInfo
                    ? panelCubit.clear()
                    : panelCubit.changeContent(
                  PartSidePanelPartInfoCubit(storyId),
                ),
              ),
              const SizedBox(height: 6),
              _DockItem(
                iconPath: 'assets/icons/typography_icon.svg',
                label: 'Settings',
                selected: selectedTypography,
                onTap: () =>
                selectedTypography
                    ? panelCubit.clear()
                    : panelCubit.changeContent(PartSidePanelTypographyCubit()),
              ),
              const SizedBox(height: 6),
              _DockItem(
                iconPath: 'assets/icons/comments_icon.svg',
                label: 'Comments',
                selected: selectedComments,
                onTap: () =>
                selectedComments
                    ? panelCubit.clear()
                    : panelCubit.changeContent(
                  PartSidePanelCommentsCubit(storyId: storyId),
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}

class _DockItem extends StatelessWidget {
  const _DockItem({
    required this.iconPath,
    required this.label,
    required this.selected,
    required this.onTap,
  });

  final String iconPath;
  final String label;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: selected ? context.colors.primaryExtraLight : Colors.transparent,
      borderRadius: BorderRadius.circular(14),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(14),
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 7, horizontal: 4),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              SizedBox(
                width: 19,
                height: 19,
                child: SvgPicture.asset(
                  iconPath,
                  colorFilter: ColorFilter.mode(
                    selected ? context.colors.primary : context.colors.gray,
                    BlendMode.srcIn,
                  ),
                ),
              ),
              const SizedBox(height: 4),
              Text(
                label,
                style: TextStyle(
                  fontSize: 10,
                  fontWeight: FontWeight.w600,
                  color: selected
                      ? context.colors.primary
                      : context.colors.gray,
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
