import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:locallibrary/core/exstentions/datetime.dart';

import '../../core/route/route.dart';
import '../../core/theme/app_palette.dart';
import '../models/models.dart';
import '../models/server_models.dart';

class StoryDescriptionBottom extends StatelessWidget {
  const StoryDescriptionBottom({super.key, required this.storyBundle});

  final StoryBundle storyBundle;

  @override
  Widget build(BuildContext context) {
    int padding = 40;
    return Column(
      children: [
        // description
        Text(
          storyBundle.story.description,
          style: Theme.of(
            context,
          ).textTheme.labelMedium?.copyWith(fontSize: 18),
          // textDirection: TextDirection.rtl,
        ),

        SizedBox(height: 50),

        // tags
        StoryTagsWrap(tags: storyBundle.tags),
        SizedBox(height: 50),

        // table of content
        Container(
          margin: EdgeInsets.all(0),
          width: double.infinity,
          padding: EdgeInsets.only(top: 30),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.all(Radius.circular(25)),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.25),
                offset: Offset(0, 0),
                blurRadius: 20,
                spreadRadius: 0,
              ),
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            spacing: 15,
            children: [
              // title
              Padding(
                padding: EdgeInsets.symmetric(
                  vertical: 10,
                  horizontal: padding + 0.0,
                ),
                child: Text(
                  "Table Of Content",
                  style: Theme.of(
                    context,
                  ).textTheme.titleLarge?.copyWith(fontSize: 20),
                ),
              ),
              SizedBox(),
              // chapters
              ...storyBundle.parts.map((p) {
                bool isCurrentPart = storyBundle.currentPart?.idx == p.idx;

                return GestureDetector(
                  onTap: () {
                    goToPart(context, storyBundle.story.storyId, p.partId);
                  },
                  child: Container(
                    // padding: EdgeInsets.symmetric( vertical: 10),
                    color: isCurrentPart
                        ? AppPalette.primaryLight.withOpacity(0.3)
                        : Colors.white,
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.start,
                      children: [
                        SizedBox(width: padding + 0.0),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            spacing: 5,
                            children: [
                              Text(
                                p.title.trim(),
                                style: Theme.of(context).textTheme.labelLarge
                                    ?.copyWith(
                                      color: Colors.black,
                                      fontFamily: 'Courier New',
                                      fontSize: 18,
                                    ),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                              if (isCurrentPart)
                                Text(
                                  "${storyBundle.storyProgress.progress! * 100}% Complete",
                                  style: Theme.of(context).textTheme.labelLarge
                                      ?.copyWith(
                                        color: AppPalette.primary,
                                        fontWeight: FontWeight.bold,
                                        fontFamily: 'Courier New',
                                        fontSize: 14,
                                      ),
                                ),
                            ],
                          ),
                        ),
                        Text(
                          p.datePublished.showDateInOwnFormat(),
                          style: Theme.of(context).textTheme.labelLarge
                              ?.copyWith(
                                color: Colors.black,
                                fontFamily: 'Courier New',
                                fontSize:
                                    MediaQuery.of(context).size.width < 600
                                    ? 12
                                    : 18,
                              ),
                        ),
                        if (isCurrentPart) SizedBox(width: padding / 2),
                        if (isCurrentPart)
                          SvgPicture.asset(
                            'assets/icons/current_part_icon.svg',
                          ),
                        if (!isCurrentPart) SizedBox(width: padding + 0.0),
                      ],
                    ),
                  ),
                );
              }),
              SizedBox(height: 10),
            ],
          ),
        ),
      ],
    );
  }
}

class StoryTagsWrap extends StatelessWidget {
  const StoryTagsWrap({super.key, required this.tags, this.fontSize = 16});

  final List<Tag> tags;
  final double fontSize;

  @override
  Widget build(BuildContext context) {
    return Wrap(
      spacing: 10,
      runSpacing: 10,
      runAlignment: WrapAlignment.start,
      alignment: WrapAlignment.start,
      crossAxisAlignment: WrapCrossAlignment.start,
      children: [
        for (var t in tags)
          Container(
            padding: EdgeInsets.symmetric(
              vertical: fontSize / 3,
              horizontal: fontSize - 2,
            ),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.all(Radius.circular(50)),
              color: AppPalette.primaryLight,
            ),
            child: Text(
              t.name,
              style: Theme.of(
                context,
              ).textTheme.labelMedium?.copyWith(fontSize: fontSize),
            ),
          ),
      ],
    );
  }
}
