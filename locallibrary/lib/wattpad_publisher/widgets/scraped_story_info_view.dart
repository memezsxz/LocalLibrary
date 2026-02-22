import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_svg/svg.dart';
import 'package:locallibrary/wattpad_publisher/bloc/scrape_part_bloc.dart';
import 'package:locallibrary/wattpad_publisher/datasource.dart';
import 'package:locallibrary/wattpad_publisher/modals/logs_modal.dart';
import 'package:locallibrary/wattpad_publisher/widgets/split_filled_button.dart';

import '../../core/exstentions/image.dart';
import '../../core/theme/app_palette.dart';
import '../../dependency_ingection.dart';
import '../bloc/base_scrape_bloc.dart';
import '../models/server_models.dart';
import '../models/server_parsed_json_models.dart';
import '../models/store_models.dart';
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
            (e) =>
                ScrapedPartRow(storyId: res.story.story.storyId, partLink: e),
          )
          .toList(),
    );
  }
}

class ScrapedPartRow extends StatefulWidget {
  final int storyId;
  final PartLink partLink; // has: String wattId; String? url;

  const ScrapedPartRow({
    super.key,
    required this.storyId,
    required this.partLink,
  });

  @override
  State<ScrapedPartRow> createState() => _ScrapedPartRowState();
}

class _ScrapedPartRowState extends State<ScrapedPartRow> {
  late final ScrapePartBloc _bloc;

  @override
  void initState() {
    super.initState();
    _bloc = ScrapePartBloc(
      api: sl.get<AppApiDataSource>(),
      storyId: widget.storyId, // if your bloc supports ctor capture
    );
  }

  @override
  void dispose() {
    _bloc.close();
    super.dispose();
  }

  bool _isActive(BaseScrapeState<PartTxResult> s) =>
      s.status == ScrapeStatus.connecting || s.status == ScrapeStatus.streaming;

  void _onPrimaryTap(BaseScrapeState<PartTxResult> s) {
    if (_isActive(s)) {
      // already scraping -> show live events
      openScrapeEventsModal<PartTxResult>(context: context, bloc: _bloc);
      return;
    }

    // If your bloc uses the custom event that carries storyId + input:
    _bloc.add(InputChanged(widget.partLink.url!));
    _bloc.add(StartRequested());

    // Optionally open the inspector immediately:
    openScrapeEventsModal<PartTxResult>(context: context, bloc: _bloc);
  }

  void _onCancel(BaseScrapeState<PartTxResult> s) {
    if (_isActive(s)) _bloc.add(CancelRequested());
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<ScrapePartBloc, BaseScrapeState<PartTxResult>>(
      bloc: _bloc,
      buildWhen: (p, n) =>
          p.status != n.status || p.events.length != n.events.length,
      builder: (context, state) {
        print(state.status.name);
        return Row(
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
                          widget.partLink.title ?? widget.partLink.wattId,
                          style: Theme.of(context).textTheme.titleMedium
                              ?.copyWith(
                                fontSize: 16,
                                color: AppPalette.primary,
                              ),
                        ),

                        SplitFilledButton(
                          status: state.status,
                          onPrimaryTap: () {
                            _onPrimaryTap(_bloc.state);
                            // start scrape or open inspector
                          },
                          onSecondary: () {
                            // cancel requested
                            context.read<ScrapePartBloc>().add(
                                CancelRequested());
                          },
                          secondaryActions: [
                            SecondaryAction(
                              label: 'Open logs',
                              icon: Icons.list_alt,
                              onTap: () =>
                                  openScrapeEventsModal<PartTxResult>(
                                    context: context,
                                    bloc: _bloc,
                                    // title: 'Part Scrape • ${widget.partLink.wattId}',
                                  ),
                            ),
                            SecondaryAction(
                              label: 'Copy part URL',
                              icon: Icons.copy,
                              onTap: () =>
                                  Clipboard.setData(ClipboardData(
                                      text: widget.partLink.url!)),
                            ),
                            SecondaryAction(
                              label: 'Rescrape',
                              icon: Icons.refresh,
                              onTap: () => () => _onPrimaryTap(state),
                            ),
                          ],
                        )

                        // SplitFilledButton(
                        //   status: state.status,
                        //   onPrimaryTap: () => _onPrimaryTap(state),
                        //   onSecondary: () => _onCancel(state),
                        // ),
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
        );
      },
    );
  }
}

// class ScrapedPartLinkRow extends StatefulWidget {
//   final int storyId;
//   final PartLink partLink;
//
//   const ScrapedPartLinkRow({
//     super.key,
//     required this.storyId,
//     required this.partLink,
//   });
//
//   @override
//   State<ScrapedPartLinkRow> createState() => _ScrapedPartLinkRowState();
// }
//
// class _ScrapedPartLinkRowState extends State<ScrapedPartLinkRow> {
//   late final ScrapePartBloc _bloc;
//
//   @override
//   void initState() {
//     super.initState();
//     _bloc = ScrapePartBloc(api: sl.get<AppApiDataSource>(), storyId: widget.storyId);
//   }
//
//   @override
//   void dispose() {
//     _bloc.close();
//     super.dispose();
//   }
//
//   bool _isActive(BaseScrapeState<PartTxResult> s) =>
//       s.status == ScrapeStatus.connecting || s.status == ScrapeStatus.streaming;
//
//   void _onPrimaryTap(BaseScrapeState<PartTxResult> s) {
//     if (_isActive(s)) {
//       openScrapeEventsModal<PartTxResult>(context: context, bloc: _bloc);
//       return;
//     }
//
//     final href = widget.partLink.url;
//     if (href == null || href.isEmpty) return;
//
//     _bloc.add(InputChanged(href));
//     _bloc.add(StartRequested());
//     openScrapeEventsModal<PartTxResult>(context: context, bloc: _bloc);
//   }
//
//   @override
//   Widget build(BuildContext context) {
//     return BlocBuilder<ScrapePartBloc, BaseScrapeState<PartTxResult>>(
//       bloc: _bloc,
//       buildWhen: (p, n) =>
//           p.status != n.status || p.events.length != n.events.length,
//       builder: (context, state) {
//         return Row(
//           spacing: 20,
//           children: [
//             Expanded(
//               flex: 90,
//               child: WhiteContainer(
//                 spacing: 10,
//                 children: [
//                   Expanded(
//                     child: Row(
//                       mainAxisAlignment: MainAxisAlignment.spaceBetween,
//                       children: [
//                         Text(
//                           widget.partLink.wattId,
//                           style: Theme.of(context).textTheme.titleMedium?.copyWith(
//                             fontSize: 16,
//                             color: AppPalette.primary,
//                           ),
//                         ),
//                         SplitFilledButton(
//                           status: state.status,
//                           onPrimaryTap: () => _onPrimaryTap(_bloc.state),
//                           onSecondary: () =>
//                               context.read<ScrapePartBloc>().add(CancelRequested()),
//                           secondaryActions: [
//                             SecondaryAction(
//                               label: 'Open logs',
//                               icon: Icons.list_alt,
//                               onTap: () => openScrapeEventsModal<PartTxResult>(
//                                 context: context,
//                                 bloc: _bloc,
//                               ),
//                             ),
//                             SecondaryAction(
//                               label: 'Copy part URL',
//                               icon: Icons.copy,
//                               onTap: () {
//                                 final href = widget.partLink.url;
//                                 if (href == null || href.isEmpty) return;
//                                 Clipboard.setData(ClipboardData(text: href));
//                               },
//                             ),
//                           ],
//                         ),
//                       ],
//                     ),
//                   ),
//                 ],
//               ),
//             ),
//             Expanded(
//               flex: 5,
//               child: WhiteContainer(
//                 mainAxisAlignment: MainAxisAlignment.center,
//                 children: [SvgPicture.asset("assets/icons/adult_icon.svg")],
//               ),
//             ),
//             Expanded(
//               flex: 5,
//               child: WhiteContainer(
//                 mainAxisAlignment: MainAxisAlignment.center,
//                 children: [SvgPicture.asset("assets/icons/adult_icon.svg")],
//               ),
//             ),
//           ],
//         );
//       },
//     );
//   }
// }
