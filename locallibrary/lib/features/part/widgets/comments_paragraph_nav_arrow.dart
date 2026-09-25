import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_svg/flutter_svg.dart';

import '../../../core/theme/app_palette.dart';
import '../../story/models/domain/part_model.dart';
import '../bloc/part_bloc.dart';
import '../cubit/part_side_panel_cubit.dart';

enum NavDir { prev, next }

class CommentsParagraphNavArrow extends StatelessWidget {
  const CommentsParagraphNavArrow({
    super.key,
    required this.dir,
    required this.storyId,
    required this.current,
    required this.iconAsset,
    this.disabledOpacity = 0.35,
  });

  final NavDir dir;
  final int storyId;
  final Paragraph current;
  final String iconAsset;
  final double disabledOpacity;

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<PartBloc, PartState>(
      builder: (context, state) {
        if (state is! PartLoaded) {
          return const SizedBox.shrink();
        }

        final paragraphs = state.info.paragraphs;
        final currIdx = paragraphs.indexWhere(
          (x) => x.paragraphId == current.paragraphId,
        );

        Paragraph? target;
        if (dir == NavDir.prev) {
          for (
            int i = (currIdx < 0 ? paragraphs.length - 1 : currIdx - 1);
            i >= 0;
            i--
          ) {
            final q = paragraphs[i];
            if ((q.commentsCount ?? 0) > 0) {
              target = q;
              break;
            }
          }
        } else {
          for (
            int i = (currIdx < 0 ? 0 : currIdx + 1);
            i < paragraphs.length;
            i++
          ) {
            final q = paragraphs[i];
            if ((q.commentsCount ?? 0) > 0) {
              target = q;
              break;
            }
          }
        }

        final hasTarget = target != null;

        return IgnorePointer(
          ignoring: !hasTarget,
          child: Opacity(
            opacity: hasTarget ? 1.0 : disabledOpacity,
            child: GestureDetector(
              onTap: () {
                final next = target;
                if (next == null) return;
                context.read<PartSidePanelCubit>().changeContent(
                  PartSidePanelCommentsCubit(storyId: storyId, paragraph: next),
                );
              },
              child: SvgPicture.asset(
                iconAsset,
                colorFilter: ColorFilter.mode(
                  context.colors.textPrimary,
                  BlendMode.srcIn,
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}
