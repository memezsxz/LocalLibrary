import 'package:expansion_tile_list/expansion_tile_list.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';

import '../../core/exstentions/image.dart';
import '../../core/theme/app_palette.dart';
import '../models/server_models.dart';
import '../screens/dashboard.dart';
import '../widgets/input_bars.dart';
import '../widgets/story_description_bottom.dart';
import 'scraped_part_row.dart';

class ScrapedStoryInfo extends StatelessWidget {
  final ScrapeStoryRes res;

  const ScrapedStoryInfo({super.key, required this.res});

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(
      context,
    ).textTheme.labelMedium?.copyWith(color: AppPalette.primary);

    final whiteSpace = 7.0;

    final showLastCol =
        !res.story.story.isFree ||
        res.story.story.isDeleted ||
        !res.story.story.isFamilyFriendly;

    return ClipRect(
      clipBehavior: Clip.none,
      clipper: const TopOnlyClip(expandSides: 24, expandBottom: 24),
      child: SingleChildScrollView(
        clipBehavior: Clip.none,

        child: Column(
          spacing: 40,
          children: [
            Row(
              mainAxisSize: MainAxisSize.max,
              mainAxisAlignment: MainAxisAlignment.start,
              crossAxisAlignment: CrossAxisAlignment.start,
              spacing: 30,
              children: [
                Expanded(
                  flex: 15,
                  child: FittedBox(
                    fit: BoxFit.fitWidth,

                    child: Container(
                      padding: EdgeInsetsGeometry.all(5),
                      decoration: BoxDecoration(
                        color: AppPalette.primaryLight,
                        borderRadius: BorderRadius.circular(5),
                      ),
                      child: LocalImage.relative(
                        storageRoot: "/Users/meme/Desktop/storage",
                        storyWattId: res.story.story.wattId,
                        relativePath: res.story.image.path!,
                        // height: MediaQuery.of(context).size.height / 4,
                        fit: BoxFit.contain,
                      ),
                    ),
                  ),
                ),

                Expanded(
                  flex: showLastCol ? 60 : 65,
                  child: Column(
                    spacing: 10,
                    children: [
                      InfoContainer(
                        padding: EdgeInsets.all(whiteSpace),
                        title: "Title:",
                        rowContent: Text(
                          res.story.story.title,
                          style: textTheme,
                        ),
                      ),
                      InfoContainer(
                        padding: EdgeInsets.all(whiteSpace),
                        title: "Author:",
                        rowContent: Text(
                          res.story.author.username,
                          style: textTheme,
                        ),
                      ),
                      InfoContainer(
                        padding: EdgeInsets.all(whiteSpace),
                        title: "Genre:",
                        rowContent: Text(
                          res.story.genre.name,
                          style: textTheme,
                        ),
                      ),
                      InfoContainer(
                        padding: EdgeInsets.all(whiteSpace),
                        title: "Age Range:",
                        rowContent: Text(
                          res.story.story.ageRange,
                          style: textTheme,
                        ),
                      ),
                      InfoContainer(
                        padding: EdgeInsets.all(whiteSpace),
                        title: "Language:",
                        rowContent: Text(
                          res.story.story.language,
                          style: textTheme,
                        ),
                      ),
                      InfoContainer(
                        padding: EdgeInsets.all(whiteSpace),
                        title: "Tags:",
                        rowContent: StoryTagsWrap(
                          tags: res.story.tags,
                          fontSize: 10,
                        ),
                      ),
                      InfoContainer(
                        padding: EdgeInsets.all(whiteSpace),
                        title: "Description:",
                        rowContent: Text(
                          res.story.story.description,
                          style: textTheme,
                        ),
                      ),
                    ],
                  ),
                ),
                // if (showLastCol)
                Expanded(
                  flex: 5,
                  child: WhiteContainer(
                    axis: Axis.vertical,
                    padding: EdgeInsetsGeometry.all(5),
                    margin: EdgeInsetsGeometry.all(0),

                    children: [
                      // if (!res.story.story.isFree)
                      GrayContainer(
                        padding: EdgeInsets.all(5),
                        child: SvgPicture.asset("assets/icons/paid_icon.svg"),
                      ),
                      // if (res.story.story.isDeleted)
                      GrayContainer(
                        padding: EdgeInsets.all(5),
                        child: SvgPicture.asset(
                          "assets/icons/deleted_icon.svg",
                        ),
                      ),
                      // if (!res.story.story.isFamilyFriendly)
                      GrayContainer(
                        padding: EdgeInsets.all(5),
                        child: SvgPicture.asset("assets/icons/adult_icon.svg"),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            ScrapedPartLinks(res: res),
          ],
        ),
      ),
    );
  }
}

class ScrapedPartLinks extends StatelessWidget {
  const ScrapedPartLinks({super.key, required this.res});

  final ScrapeStoryRes res;

  @override
  Widget build(BuildContext context) {
    final storyId = res.story.story.storyId;

    return ExpansionTileList(
      shrinkWrap: true,
      primary: false,
      physics: const NeverScrollableScrollPhysics(),
      itemGapSize: 12,
      expansionMode: ExpansionMode.atMostOne,
      children: [
        for (final partLink in res.partLinks)
          ExpansionTile(
            key: PageStorageKey('part_${partLink.wattId}'),
            maintainState: true,
            tilePadding: EdgeInsets.zero,
            title: ScrapedPartRow(storyId: storyId, partLink: partLink),
            childrenPadding: const EdgeInsets.fromLTRB(8, 0, 8, 8),
            children: [
              if ((partLink.url ?? '').isNotEmpty)
                SelectableText(
                  partLink.url!,
                  style: Theme.of(context).textTheme.labelSmall?.copyWith(
                    color: AppPalette.primary.withOpacity(0.8),
                  ),
                ),
            ],
          ),
      ],
    );
  }
}
