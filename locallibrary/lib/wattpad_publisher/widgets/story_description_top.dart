import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:locallibrary/wattpad_publisher/widgets/input_bars.dart';

import '../../core/exstentions/image.dart';
import '../../core/route/route.dart';
import '../../core/theme/app_palette.dart';
import '../models/server_models.dart';
import '../screens/story_screen.dart';

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
    return ContentContainer(
      margin: margin,
      width: double.infinity,
      height: double.infinity,
      color: Colors.white,
      child: LayoutBuilder(
        builder: (context, c) {
          final w = c.maxWidth;
          return Container(
            // color: Colors.red,
            child: Row(
              mainAxisSize: MainAxisSize.max,
              children: [
                SizedBox(
                  width: w * 0.3,
                  child: StoryDescrioptionTopLeft(story: story),
                ),
                SizedBox(
                  width: w * 0.6,
                  child: StoryDescrioptionTopCenter(story: story),
                ),
                SizedBox(
                  width: w * 0.1,
                  child: StoryDescrioptionTopRight(story: story),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}

class StoryDescrioptionTopRight extends StatelessWidget {
  const StoryDescrioptionTopRight({super.key, required this.story});

  final StoryBundle story;
  final double w = 35;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: w, // ← define width once
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
              print("load from web");
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

class StoryDescrioptionTopCenter extends StatelessWidget {
  const StoryDescrioptionTopCenter({super.key, required this.story});

  final StoryBundle story;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Column(
        children: [
          Text(
            story.story.title,
            style: Theme.of(context).textTheme.titleLarge,
            textAlign: TextAlign.start,
          ),
          SizedBox(height: 20),
          StoryData(
            image: SvgPicture.asset("assets/icons/star_icon.svg"),
            label: "Votes",
            number: story.parts
                .map((p) => p.votes)
                .reduce((prev, now) => prev + now),
          ),
          StoryData(
            image: SvgPicture.asset("assets/icons/parts_icon.svg"),
            label: "Parts",
            number: story.parts.length,
          ),
          SizedBox(height: 20),
          if (!story.story.isFamilyFriendly)
            StoryData(
              image: SvgPicture.asset("assets/icons/adult_icon.svg"),
              label: "For Adults",
            ),
          if (story.story.isDeleted)
            StoryData(
              image: SvgPicture.asset("assets/icons/deleted_icon.svg"),
              label: "Deleted",
            ),
          if (!story.story.isFree)
            StoryData(
              image: SvgPicture.asset("assets/icons/paid_icon.svg"),
              label: "Paid",
            ),
        ],
      ),
    );
  }
}

class StoryData extends StatelessWidget {
  StoryData({super.key, required this.image, required this.label, this.number});

  final SvgPicture image;
  final String label;
  final int? number;
  Color color = AppPalette.primaryLight;

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.center,
      spacing: 10,
      children: [
        image,
        Text(
          label,
          style: Theme.of(context).textTheme.labelLarge?.copyWith(
            color: color,
            fontFamily: 'Courier New',
            fontSize: 18,
          ),
        ),
        if (number != null)
          Text(
            "$number",
            style: Theme.of(context).textTheme.labelLarge?.copyWith(
              color: color,
              fontWeight: FontWeight.bold,
              fontFamily: 'Courier New',
              fontSize: 18,
            ),
          ),
      ],
    );
  }
}

class StoryDescrioptionTopLeft extends StatelessWidget {
  const StoryDescrioptionTopLeft({super.key, required this.story});

  final StoryBundle story;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsetsGeometry.symmetric(horizontal: 20),
      width: double.infinity,
      height: double.infinity,
      // color: Colors.cyanAccent,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        // ← makes children full width
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        mainAxisSize: MainAxisSize.max,
        // spacing: 10,
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
              // height: 220,
              fit: BoxFit.fitWidth,
            ),
          ),
          BaseButton(
            label: story.storyProgress.progress == null ? "Read" : "Continue",
            onPressed: () async {
              if (story.currentPart != null) {
                goToPart(
                  context,
                  story.story.storyId,
                  story.currentPart!.partId,
                );
              } else if (story.parts.isNotEmpty) {
                goToPart(context, story.story.storyId, story.parts[0].partId);
              } else {
                // Todo: tell the user there are no parts in the story
              }
            },
          ),
        ],
      ),
    );
  }
}
