import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_svg/svg.dart';

import '../../../core/theme/app_palette.dart';
import '../cubit/part_side_panel_cubit.dart';

class SidePanelMobileNavBar extends StatelessWidget {
  const SidePanelMobileNavBar({super.key, required this.storyId});

  final int storyId;

  @override
  Widget build(BuildContext context) {
    final panelCubit = context.read<PartSidePanelCubit>();
    return BlocBuilder<PartSidePanelCubit, PartSidePanelState>(
      builder: (context, selected) {
        final isInfo = selected is PartSidePanelPartInfoCubit;
        final isTypo = selected is PartSidePanelTypographyCubit;
        final isComments = selected is PartSidePanelCommentsCubit;

        return Container(
          height: 60,
          decoration: BoxDecoration(
            color: AppPalette.surfaceAlt,
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.1),
                blurRadius: 8,
                offset: const Offset(0, -2),
              ),
            ],
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            spacing: 16,
            children: [
              _NavBtn(
                iconPath: 'assets/icons/parts_icon.svg',
                selected: isInfo,
                onTap: () => isInfo
                    ? panelCubit.clear()
                    : panelCubit.changeContent(
                        PartSidePanelPartInfoCubit(storyId),
                      ),
              ),
              _NavBtn(
                iconPath: 'assets/icons/typography_icon.svg',
                selected: isTypo,
                onTap: () => isTypo
                    ? panelCubit.clear()
                    : panelCubit.changeContent(PartSidePanelTypographyCubit()),
              ),
              _NavBtn(
                iconPath: 'assets/icons/comments_icon.svg',
                selected: isComments,
                onTap: () => isComments
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

class _NavBtn extends StatelessWidget {
  const _NavBtn({
    required this.iconPath,
    required this.selected,
    required this.onTap,
  });

  final String iconPath;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: selected
              ? AppPalette.primary.withOpacity(0.15)
              : Colors.transparent,
          borderRadius: BorderRadius.circular(12),
        ),
        child: SvgPicture.asset(
          iconPath,
          width: 24,
          color: selected
              ? AppPalette.primary
              : AppPalette.primary.withOpacity(0.4),
        ),
      ),
    );
  }
}
