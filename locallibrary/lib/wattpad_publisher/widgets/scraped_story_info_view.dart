import 'package:expansion_tile_list/expansion_tile_list.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';

import '../../core/exstentions/image.dart';
import '../../core/theme/app_palette.dart';
import '../../dependency_ingection.dart';
import '../bloc/scrape_comments_bloc.dart';
import '../bloc/scrape_part_bloc.dart';
import '../datasource.dart';
import '../models/models.dart';
import '../models/server_models.dart';
import '../screens/dashboard.dart';
import '../widgets/input_bars.dart';
import '../widgets/story_description_bottom.dart';
import 'scraped_part_row.dart';

class ScrapedStoryInfo extends StatelessWidget {
  final ScrapeStoryRes res;
  final StoryBundle? bundle;

  const ScrapedStoryInfo({super.key, required this.res, this.bundle});

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
            ScrapedPartLinks(
              res: res,
              downloadedParts: {
                for (final p in bundle?.parts ?? []) p.wattId: p,
              },
            ),
          ],
        ),
      ),
    );
  }
}

class ScrapedPartLinks extends StatefulWidget {
  const ScrapedPartLinks({
    super.key,
    required this.res,
    this.downloadedParts = const {},
  });

  final ScrapeStoryRes res;
  final Map<String, Part> downloadedParts;

  @override
  State<ScrapedPartLinks> createState() => _ScrapedPartLinksState();
}

class _ScrapedPartLinksState extends State<ScrapedPartLinks> {
  late final List<ScrapePartBloc> _blocs;
  late final List<ScrapeCommentsBloc> _commentBlocs;
  late final List<ValueNotifier<bool>> _expansionNotifiers;
  late final int _storyId;
  late final AppApiDataSource _api;

  @override
  void initState() {
    super.initState();
    _storyId = widget.res.story.story.storyId;
    _api = sl.get<AppApiDataSource>();
    _blocs = widget.res.partLinks
        .map((_) => ScrapePartBloc(api: _api, storyId: _storyId))
        .toList();
    _commentBlocs = widget.res.partLinks
        .map((_) => ScrapeCommentsBloc(api: _api, storyId: _storyId))
        .toList();
    _expansionNotifiers = List.generate(
      widget.res.partLinks.length,
      (_) => ValueNotifier(false),
    );
  }

  @override
  void dispose() {
    for (final bloc in _blocs) bloc.close();
    for (final bloc in _commentBlocs) bloc.close();
    for (final notifier in _expansionNotifiers) notifier.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return ExpansionTileList(
      shrinkWrap: true,
      primary: false,
      physics: const NeverScrollableScrollPhysics(),
      itemGapSize: 12,
      expansionMode: ExpansionMode.atMostOne,
      children: [
        for (var i = 0; i < widget.res.partLinks.length; i++)
          ScrapedPartRow(
            partLink: widget.res.partLinks[i],
            bloc: _blocs[i],
            commentsBloc: _commentBlocs[i],
            expansionNotifier: _expansionNotifiers[i],
            storyId: _storyId,
            api: _api,
            downloadedPart:
                widget.downloadedParts[widget.res.partLinks[i].wattId],
          ),
      ],
    );
  }
}
