import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_svg/flutter_svg.dart';

import '../../../core/extensions/image.dart';
import '../../../core/secrets/app_secrets.dart';
import '../../../core/theme/app_theme.dart';
import '../../story/bloc/story_bloc.dart';
import '../../story/models/dto/part_full_info.dart';
import 'paragraphs_column.dart';
import 'part_image_view.dart';
import 'part_local_video.dart';

class PartContent extends StatelessWidget {
  const PartContent({
    super.key,
    required this.storyId,
    required this.info,
    required this.scrollController,
    required this.progressNotifier,
    this.targetParagraphId,
    this.targetCommentId,
  });

  final int storyId;
  final PartFullInfo info;
  final ScrollController scrollController;
  final ValueNotifier<ProgressRecord?> progressNotifier;
  final int? targetParagraphId;
  final int? targetCommentId;

  @override
  Widget build(BuildContext context) {
    final wattId = context
        .read<StoryBloc>()
        .state
        .bundles[storyId]
        ?.story
        .wattId;
    final List<Widget> partImages = [];

    if (info.image != null) {
      if (info.image!.path != null && wattId != null) {
        partImages.add(
          LocalImage.relative(
            storageRoot: AppSecrets.storageRoot,
            storyWattId: wattId,
            relativePath: info.image!.path!,
            width: double.infinity,
            fit: BoxFit.contain,
          ),
        );
      } else if (info.image!.url != null) {
        partImages.add(Image.network(info.image!.url!, fit: BoxFit.contain));
      }
    }

    if (info.video != null && wattId != null) {
      partImages.add(
        PartLocalVideo.relative(
          storageRoot: AppSecrets.storageRoot,
          storyWattId: wattId,
          relativePath: info.video!.path!,
        ),
      );
    }

    return Padding(
      padding: EdgeInsets.symmetric(
        horizontal: MediaQuery.of(context).size.width * 0.03,
        vertical: 30,
      ),
      child: Column(
        children: [
          if (partImages.isNotEmpty) PartImages(partImages: partImages),
          const SizedBox(height: 40),
          Text(
            info.part.title,
            style: Theme.of(context).textTheme.titleLarge?.copyWith(
              color: context.colors.textPrimary,
              fontFamily: 'Courier New',
            ),
          ),
          const SizedBox(height: 20),
          Row(
            mainAxisSize: MainAxisSize.min,
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            spacing: 7,
            children: [
              Text(
                '${info.part.votes}',
                textAlign: TextAlign.center,
                strutStyle: const StrutStyle(
                  forceStrutHeight: true,
                  height: 0.1,
                  leading: 0,
                ),
                style: Theme.of(context).textTheme.labelLarge?.copyWith(
                  color: context.colors.primary,
                  fontFamily: 'Courier New',
                  fontSize: 18,
                  fontWeight: FontWeight.w600,
                  height: 1.0,
                ),
              ),
              SizedBox(
                width: 18,
                height: 18,
                child: Center(
                  child: SvgPicture.asset(
                    'assets/icons/star_fill_icon.svg',
                    color: context.colors.primary,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),
          Container(
            height: 2,
            width: MediaQuery.of(context).size.width * 0.3,
            decoration: ShapeDecoration(
              color: context.colors.primaryLight,
              shape: BeveledRectangleBorder(
                borderRadius: BorderRadius.circular(150),
              ),
            ),
          ),
          const SizedBox(height: 20),
          ParagraphsColumn(
            info: info,
            storyId: storyId,
            scrollController: scrollController,
            progressNotifier: progressNotifier,
            targetParagraphId: targetParagraphId,
            targetCommentId: targetCommentId,
          ),
          const SizedBox(height: 40),
        ],
      ),
    );
  }
}
