import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';

import '../../../core/theme/app_palette.dart';
import '../models/dto/story_bundle.dart';
import '../screens/scrape_story_screen.dart';

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
            onTap: () {
              print("show author info");
            },
            child: Container(
              clipBehavior: Clip.hardEdge,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.all(Radius.circular(100)),
              ),
              child: Image.asset("assets/images/author_image.png", width: w),
            ),
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
