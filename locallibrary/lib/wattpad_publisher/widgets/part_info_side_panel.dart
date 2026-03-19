import 'package:auto_size_text/auto_size_text.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_svg/svg.dart';
import 'package:scrollable_positioned_list/scrollable_positioned_list.dart';

import '../../core/exstentions/image.dart';
import '../../core/route/route.dart';
import '../../core/theme/app_palette.dart';
import '../bloc/part_bloc.dart';
import '../bloc/story_bloc.dart';
import '../models/models.dart';
import '../models/server_models.dart';

class PartInfoSidePanel extends StatefulWidget {
  const PartInfoSidePanel({super.key, required this.storyId});

  final int storyId;

  @override
  State<PartInfoSidePanel> createState() => _PartInfoSidePanelState();
}

class _PartInfoSidePanelState extends State<PartInfoSidePanel> {
  final _itemScroll = ItemScrollController();
  final _positions = ItemPositionsListener.create();

  int? _currentIndex(StoryBundle b) {
    final current = b.currentPart;
    if (current == null) return null;
    final idx = b.parts.indexWhere((p) => p.partId == current.partId);
    return idx >= 0 ? idx : null;
  } // Retry until controller is attached, then scroll once

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<StoryBloc, StoryState>(
      buildWhen: (prev, next) =>
          prev.bundleFor(widget.storyId) != next.bundleFor(widget.storyId) ||
          prev.isLoading(widget.storyId) != next.isLoading(widget.storyId) ||
          prev.errorFor(widget.storyId) != next.errorFor(widget.storyId),
      builder: (context, state) {
        final bundle = state.bundleFor(widget.storyId);
        final loading = state.isLoading(widget.storyId);
        final error = state.errorFor(widget.storyId);

        // Not in cache? (e.g., direct link) → fetch it now.
        if (bundle == null && !loading && error == null) {
          context.read<StoryBloc>().add(StoryRequested(widget.storyId));
          return const Center(child: CircularProgressIndicator());
        }

        if (bundle == null && loading) {
          return const Center(child: CircularProgressIndicator());
        }

        if (bundle == null && error != null) {
          return Padding(
            padding: const EdgeInsets.all(16),
            child: Text('Failed to load: $error'),
          );
        }

        final b = bundle!;

        // _scheduleScrollTo(b);
        final targetIndex = _currentIndex(b);
        return SizedBox(
          height: double.infinity,
          // color: Colors.amberAccent,
          child: Column(
            mainAxisSize: MainAxisSize.max,
            mainAxisAlignment: MainAxisAlignment.start,
            // crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // story and author
              Expanded(
                flex: 2,

                child: _PartInfoSidePanelStoryInfo(
                  storyId: widget.storyId,
                  image: b.image,
                  bundle: b,
                ),
              ),
              //
              Expanded(
                flex: 7,

                child: ScrollablePositionedList.separated(
                  itemScrollController: _itemScroll,
                  itemPositionsListener: _positions,
                  initialScrollIndex: targetIndex ?? 0,
                  initialAlignment: 0.1,
                  separatorBuilder: (context, index) => SizedBox(height: 5),
                  itemCount: b.parts.length,
                  itemBuilder: (ctx, i) {
                    final part = b.parts[i];
                    final isCurrentPart =
                        b.currentPart != null &&
                        b.currentPart!.partId == part.partId;

                    return _PartContainer(
                      isCurrentPart: isCurrentPart,
                      storyId: widget.storyId,
                      part: part,
                    );
                  },
                ),
              ),
              Expanded(
                flex: 1,
                child: Container(
                  // padding: const EdgeInsets.symmetric(vertical: 20),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      InkWell(
                        overlayColor: WidgetStatePropertyAll(
                          AppPalette.transparent,
                        ),
                        onTap: () {
                          print("load from web");
                        },
                        child: SvgPicture.asset(
                          "assets/icons/reload_from_web_icon.svg",
                          width: 35,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}

class _PartInfoSidePanelStoryInfo extends StatelessWidget {
  const _PartInfoSidePanelStoryInfo({
    required this.storyId,
    required this.image,
    required bundle,
  }) : b = bundle;

  final int storyId;
  final Media? image;
  final StoryBundle b;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(vertical: 20, horizontal: 20),
      child: Row(
        spacing: 10,
        children: [
          GestureDetector(
            child: Container(
              decoration: BoxDecoration(
                borderRadius: BorderRadius.all(Radius.circular(5)),
              ),
              clipBehavior: Clip.antiAliasWithSaveLayer,
              child: LocalImage.relative(
                storageRoot: "/Users/meme/Desktop/storage",
                storyWattId: b.story.wattId,
                relativePath: image!.path!, // Todo: handle no path
                height: MediaQuery.of(context).size.height / 4,
              ),
            ),

            onTap: () {
              goToStory(context, storyId);
            },
          ),
          Expanded(
            child: Column(
              mainAxisSize: MainAxisSize.max,
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                // Title (shrinks down but keeps up to 2 lines)
                SizedBox(
                  width: double.infinity,
                  height: MediaQuery.of(context).size.height / 10,
                  child: AutoSizeText(
                    b.story.title.trim(),
                    style: Theme.of(context).textTheme.titleMedium,
                    maxLines: 4,
                    minFontSize: 10,
                    // how small it’s allowed to g
                    stepGranularity: 0.5,
                    // smoother steps when shrinking
                    overflow: TextOverflow.ellipsis,
                    wrapWords: true,
                    softWrap: true,
                  ),
                ),

                const SizedBox(height: 6),

                // Author line (single line, shrinks if tight)
                AutoSizeText.rich(
                  TextSpan(
                    children: [
                      const TextSpan(
                        text: 'By ',
                        style: TextStyle(color: Colors.black),
                      ),
                      TextSpan(
                        text: b.author.username,
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          color: Colors.black,
                        ),
                        recognizer: TapGestureRecognizer()
                          ..onTap = () =>
                              debugPrint('clicked ${b.author.username}'),
                      ),
                    ],
                  ),
                  maxLines: 1,
                  minFontSize: 10,
                  overflow: TextOverflow.ellipsis,
                  stepGranularity: 0.5,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _PartContainer extends StatelessWidget {
  const _PartContainer({
    required this.isCurrentPart,
    required this.storyId,
    required this.part,
  });

  final bool isCurrentPart;
  final int storyId;
  final Part part;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: isCurrentPart
          ? AppPalette.primary.withOpacity(0.5)
          : AppPalette.primaryLight.withOpacity(0.3),
      child: InkWell(
        onTap: () {
          context.read<PartBloc>().add(
            PartFetchRequested(storyId: storyId, partId: part.partId),
          );
          // goToPart(ctx, b.story.storyId, part.partId);
        },
        child: ConstrainedBox(
          constraints: const BoxConstraints(minHeight: 40), // pick your min
          child: Row(
            mainAxisSize: MainAxisSize.max,
            mainAxisAlignment: MainAxisAlignment.spaceBetween,

            spacing: 10,
            children: [
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.symmetric(
                    vertical: 10,
                    horizontal: 20,
                  ),
                  child: Text(
                    part.title,
                    softWrap: true,
                    // wrapWords: true,
                    style: Theme.of(
                      context,
                    ).textTheme.labelMedium?.copyWith(fontSize: 16),
                  ),
                ),
              ),
              if (isCurrentPart)
                FittedBox(
                  fit: BoxFit.fitHeight,
                  child: SvgPicture.asset("assets/icons/current_part_icon.svg"),
                ),
            ],
          ),
        ),
      ),
    );
  }
}
