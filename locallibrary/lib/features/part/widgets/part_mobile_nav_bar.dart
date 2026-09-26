import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_svg/svg.dart';

import '../../../core/theme/app_theme.dart';
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
            color: context.colors.surfaceAlt,
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.1),
                blurRadius: 8,
                offset: const Offset(0, -2),
              ),
            ],
          ),
          child: Row(
            children: [
              _NavBtn(
                iconPath: 'assets/icons/parts_icon.svg',
                label: 'Story',
                selected: isInfo,
                onTap: () => isInfo
                    ? panelCubit.clear()
                    : panelCubit.changeContent(
                        PartSidePanelPartInfoCubit(storyId),
                      ),
              ),
              _NavBtn(
                iconPath: 'assets/icons/typography_icon.svg',
                label: 'Settings',
                selected: isTypo,
                onTap: () => isTypo
                    ? panelCubit.clear()
                    : panelCubit.changeContent(PartSidePanelTypographyCubit()),
              ),
              _NavBtn(
                iconPath: 'assets/icons/comments_icon.svg',
                label: 'Comments',
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
    final color = selected ? context.colors.primary : context.colors.gray;
    return Expanded(
      child: GestureDetector(
        onTap: onTap,
        behavior: HitTestBehavior.opaque,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          mainAxisSize: MainAxisSize.min,
          children: [
            SizedBox(
              width: 19,
              height: 19,
              child: SvgPicture.asset(
                iconPath,
                colorFilter: ColorFilter.mode(color, BlendMode.srcIn),
              ),
            ),
            const SizedBox(height: 3),
            Text(
              label,
              style: TextStyle(
                fontSize: 10,
                fontWeight: FontWeight.w600,
                color: color,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
