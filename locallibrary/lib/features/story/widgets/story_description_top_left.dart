import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../core/common/widgets/base_button.dart';
import '../../../core/extensions/image.dart';
import '../../library/cubit/navigation_cubit.dart';
import '../../library/cubit/navigation_state.dart';
import '../models/dto/story_bundle.dart';

class StoryDescriptionTopLeft extends StatelessWidget {
  const StoryDescriptionTopLeft({super.key, required this.story});

  final StoryBundle story;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsetsGeometry.symmetric(horizontal: 20),
      width: double.infinity,
      height: double.infinity,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        mainAxisSize: MainAxisSize.max,
        children: [
          Container(
            clipBehavior: Clip.antiAliasWithSaveLayer,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.all(Radius.circular(5)),
            ),
            width: double.infinity,
            child: LocalImage.relative(
              storageRoot: "/Users/meme/Desktop/storage",
              storyWattId: story.story.wattId,
              relativePath: story.image!.path!,
              width: double.infinity,
              fit: BoxFit.fitWidth,
            ),
          ),
          BaseButton(
            label: story.storyProgress.progress == null ? "Read" : "Continue",
            onPressed: () async {
              final partId =
                  story.currentPart?.partId ??
                  (story.parts.isNotEmpty ? story.parts[0].partId : null);
              if (partId != null) {
                context.read<NavigationCubit>().push(
                  NavigationPartState(
                    storyId: story.story.storyId,
                    partId: partId,
                  ),
                );
              }
            },
          ),
        ],
      ),
    );
  }
}
