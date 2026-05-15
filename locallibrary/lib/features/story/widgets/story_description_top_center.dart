import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';

import '../models/dto/story_bundle.dart' show StoryBundle;
import 'story_data.dart';

class StoryDescriptionTopCenter extends StatelessWidget {
  const StoryDescriptionTopCenter({super.key, required this.story});

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
