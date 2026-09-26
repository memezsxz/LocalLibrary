import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../core/theme/app_theme.dart';
import '../../library/cubit/navigation_cubit.dart';
import '../../library/cubit/navigation_state.dart';
import '../models/dto/story_bundle.dart';

class StoryDescriptionBottom extends StatelessWidget {
  const StoryDescriptionBottom({super.key, required this.storyBundle});

  final StoryBundle storyBundle;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        _Card(
          label: 'SYNOPSIS',
          child: Text(
            storyBundle.story.description,
            style: TextStyle(
              fontSize: 15,
              height: 1.55,
              color: context.colors.textPrimary,
            ),
          ),
        ),
        const SizedBox(height: 16),
        _Card(
          label: 'PARTS',
          child: Column(
            children: [
              for (var i = 0; i < storyBundle.parts.length; i++)
                _PartRow(
                  title: storyBundle.parts[i].title.trim(),
                  isCurrent:
                  storyBundle.currentPart?.partId ==
                      storyBundle.parts[i].partId,
                  progress:
                  storyBundle.currentPart?.partId ==
                      storyBundle.parts[i].partId
                      ? storyBundle.storyProgress.progress
                      : null,
                  showDivider: i != storyBundle.parts.length - 1,
                  onTap: () =>
                      context.read<NavigationCubit>().push(
                        NavigationPartState(
                          storyId: storyBundle.story.storyId,
                          partId: storyBundle.parts[i].partId,
                        ),
                      ),
                ),
            ],
          ),
        ),
      ],
    );
  }
}

class _Card extends StatelessWidget {
  const _Card({required this.label, required this.child});

  final String label;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: context.colors.surface,
        border: Border.all(color: context.colors.primaryExtraLight),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w700,
              letterSpacing: 0.5,
              color: context.colors.gray,
            ),
          ),
          const SizedBox(height: 10),
          child,
        ],
      ),
    );
  }
}

class _PartRow extends StatelessWidget {
  const _PartRow({
    required this.title,
    required this.isCurrent,
    required this.progress,
    required this.showDivider,
    required this.onTap,
  });

  final String title;
  final bool isCurrent;
  final double? progress;
  final bool showDivider;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 11),
        decoration: BoxDecoration(
          color: isCurrent ? context.colors.primaryExtraLight : null,
          border: showDivider
              ? Border(
            bottom: BorderSide(color: context.colors.primaryExtraLight),
          )
              : null,
        ),
        child: Row(
          children: [
            Expanded(
              child: Text(
                title,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(
                  fontSize: 14,
                  color: context.colors.textPrimary,
                ),
              ),
            ),
            if (progress != null)
              Text(
                '${(progress! * 100).toStringAsFixed(0)}%',
                style: TextStyle(fontSize: 12, color: context.colors.gray),
              ),
          ],
        ),
      ),
    );
  }
}
