import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_svg/svg.dart';

import '../../../core/api/library_api_client.dart';
import '../../../core/common/widgets/base_button.dart';
import '../../../core/extensions/image.dart';
import '../../../core/secrets/app_secrets.dart';
import '../../../core/theme/app_palette.dart';
import '../../../dependency_injection.dart';
import '../../library/cubit/navigation_cubit.dart';
import '../../library/cubit/navigation_state.dart';
import '../models/dto/story_bundle.dart';
import '../screens/scrape_story_screen.dart';
import 'author_dialog.dart';
import 'story_description_top_center.dart';
import 'story_description_top_left.dart';
import 'story_description_top_right.dart';
import 'story_layout.dart';

export 'story_data.dart';
export 'story_description_top_center.dart';
export 'story_description_top_left.dart';
export 'story_description_top_right.dart';

class StoryDescriptionTop extends StatelessWidget {
  const StoryDescriptionTop({
    super.key,
    required this.margin,
    required this.story,
  });

  final EdgeInsetsGeometry margin;
  final StoryBundle story;

  @override
  Widget build(BuildContext context) {
    final isMobile = MediaQuery.of(context).size.width < 600;

    if (isMobile) {
      return Container(
        margin: margin,
        color: Colors.white,
        width: double.infinity,
        child: _MobileStoryDescriptionTop(story: story),
      );
    }

    return ContentContainer(
      margin: margin,
      width: double.infinity,
      height: double.infinity,
      color: Colors.white,
      child: LayoutBuilder(
        builder: (context, c) {
          final w = c.maxWidth;
          return Container(
            child: Row(
              mainAxisSize: MainAxisSize.max,
              children: [
                SizedBox(
                  width: w * 0.3,
                  child: StoryDescriptionTopLeft(story: story),
                ),
                SizedBox(
                  width: w * 0.6,
                  child: StoryDescriptionTopCenter(story: story),
                ),
                SizedBox(
                  width: w * 0.1,
                  child: StoryDescriptionTopRight(story: story),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}

class _MobileStoryDescriptionTop extends StatelessWidget {
  const _MobileStoryDescriptionTop({required this.story});

  final StoryBundle story;

  static const double _iconW = 32;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Center(
          child: SizedBox(
            width: MediaQuery.of(context).size.width * 0.5,
            child: Container(
              clipBehavior: Clip.antiAliasWithSaveLayer,
              decoration: const BoxDecoration(
                borderRadius: BorderRadius.all(Radius.circular(5)),
              ),
              child: LocalImage.relative(
                storageRoot: AppSecrets.storageRoot,
                storyWattId: story.story.wattId,
                relativePath: story.image!.path!,
                width: double.infinity,
                fit: BoxFit.fitWidth,
              ),
            ),
          ),
        ),
        const SizedBox(height: 12),
        StoryDescriptionTopCenter(story: story),
        const SizedBox(height: 12),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            GestureDetector(
              onTap: () => showAuthorDialog(
                context: context,
                author: story.author,
                fetchStories: (limit, offset) => sl<LibraryApiClient>()
                    .getStoriesByAuthor(story.author.authorId, limit, offset),
              ),
              child: AuthorAvatar(name: story.author.name, size: _iconW),
            ),
            GestureDetector(
              onTap: () {
                final url =
                    story.story.url ??
                    'https://www.wattpad.com/story/${story.story.wattId}';
                showScrapeSheet(context, url: url, autoStart: true);
              },
              child: SvgPicture.asset(
                "assets/icons/reload_from_web_icon.svg",
                width: _iconW,
              ),
            ),
            GestureDetector(
              onTap: () => print("export"),
              child: SvgPicture.asset(
                "assets/icons/export_icon.svg",
                width: _iconW,
              ),
            ),
            VerticalDivider(
              color: AppPalette.primaryLight.withOpacity(0.5),
              thickness: 2,
              width: 16,
            ),
            GestureDetector(
              onTap: () => print("load from file"),
              child: SvgPicture.asset(
                "assets/icons/reload_from_file.svg",
                width: _iconW,
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
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
    );
  }
}
