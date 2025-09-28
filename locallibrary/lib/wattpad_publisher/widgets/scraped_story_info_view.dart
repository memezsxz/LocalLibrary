import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:locallibrary/wattpad_publisher/widgets/split_filled_button.dart';

import '../../core/exstentions/image.dart';
import '../../core/theme/app_palette.dart';
import '../bloc/base_scrape_bloc.dart';
import '../models/server_models.dart';
import '../screens/dashboard.dart';
import '../widgets/input_bars.dart';
import '../widgets/story_description_bottom.dart';

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
    return Column(
      children: res.partLinks
          .map(
            (e) => Row(
              spacing: 20,
              children: [
                Expanded(
                  flex: 90,
                  child: WhiteContainer(
                    spacing: 10,
                    children: [
                      Expanded(
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              e.wattId,
                              style: Theme.of(context).textTheme.titleMedium
                                  ?.copyWith(
                                    fontSize: 16,
                                    color: AppPalette.primary,
                                    // TODO: if downloaded show part title and not in bold
                                    // backgroundColor: AppPalette.error,
                                  ),
                            ),
                            SplitFilledButton(
                              onPrimaryTap: () {},
                              onSecondary: () {},
                              status: ScrapeStatus.idle,
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
                Expanded(
                  flex: 5,
                  child: WhiteContainer(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [SvgPicture.asset("assets/icons/adult_icon.svg")],
                  ),
                ),
                Expanded(
                  flex: 5,
                  child: WhiteContainer(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [SvgPicture.asset("assets/icons/adult_icon.svg")],
                  ),
                ),
              ],
            ),
          )
          .toList(),
    );
  }
}
