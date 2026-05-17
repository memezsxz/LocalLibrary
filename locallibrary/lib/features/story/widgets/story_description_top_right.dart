import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';

import '../../../core/api/library_api_client.dart';
import '../../../core/theme/app_palette.dart';
import '../../../dependency_injection.dart';
import '../models/dto/story_bundle.dart';
import '../screens/scrape_story_screen.dart';
import 'author_dialog.dart';

class StoryDescriptionTopRight extends StatelessWidget {
  const StoryDescriptionTopRight({super.key, required this.story});

  final StoryBundle story;
  final double w = 35;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: w,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.end,
        spacing: 10,
        children: [
          GestureDetector(
            onTap: () => showAuthorDialog(
              context: context,
              author: story.author,
              fetchStories: (limit, offset) => sl<LibraryApiClient>()
                  .getStoriesByAuthor(story.author.authorId, limit, offset),
            ),
            child: AuthorAvatar(name: story.author.name, size: w),
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
              width: w,
            ),
          ),
          GestureDetector(
            onTap: () {
              print("export");
            },
            child: SvgPicture.asset("assets/icons/export_icon.svg", width: w),
          ),
          SizedBox(
            width: w,
            child: Divider(
              color: AppPalette.primaryLight.withOpacity(0.5),
              thickness: 2,
              radius: BorderRadius.all(Radius.circular(50)),
              height: 3,
            ),
          ),
          GestureDetector(
            onTap: () {
              print("laod from file");
            },
            child: SvgPicture.asset(
              "assets/icons/reload_from_file.svg",
              width: w,
            ),
          ),
        ],
      ),
    );
  }
}
