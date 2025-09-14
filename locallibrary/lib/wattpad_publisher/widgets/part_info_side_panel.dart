import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_svg/svg.dart';
import 'package:go_router/go_router.dart';

import '../../core/exstentions/image.dart';
import '../../core/route/story_route.dart';
import '../../core/theme/app_palette.dart';
import '../bloc/part_bloc.dart';
import '../bloc/story_bloc.dart';
import 'package:auto_size_text/auto_size_text.dart';

class PartInfoSidePanel extends StatelessWidget {
  const PartInfoSidePanel({super.key, required this.storyId});

  final int storyId;

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<StoryBloc, StoryState>(
      buildWhen: (prev, next) =>
          prev.bundleFor(storyId) != next.bundleFor(storyId) ||
          prev.isLoading(storyId) != next.isLoading(storyId) ||
          prev.errorFor(storyId) != next.errorFor(storyId),
      builder: (context, state) {
        final bundle = state.bundleFor(storyId);
        final loading = state.isLoading(storyId);
        final error = state.errorFor(storyId);

        // Not in cache? (e.g., direct link) → fetch it now.
        if (bundle == null && !loading && error == null) {
          context.read<StoryBloc>().add(StoryRequested(storyId));
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

        return Container(
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

                child: Container(
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
                            storyWattId: context
                                .read<StoryBloc>()
                                .state
                                .bundles[storyId]!
                                .story
                                .wattId,
                            relativePath: bundle.image!.path!,
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
                                b.story.title.trim() ,
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
                                      ..onTap = () => debugPrint(
                                        'clicked ${b.author.username}',
                                      ),
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
                ),
              ),
              //
              Expanded(
                flex: 7,

                child: ListView.separated(
                  separatorBuilder: (context, index) => SizedBox(height: 5),
                  itemCount: b.parts.length,
                  itemBuilder: (ctx, i) {
                    final part = b.parts[i];
                    return Material(
                      color: AppPalette.primaryLight.withOpacity(0.3),
                      child: InkWell(
                        onTap: () {
                          context.read<PartBloc>().add(
                            PartFetchRequested(
                              storyId: storyId,
                              partId: part.partId,
                            ),
                          );
                          // goToPart(ctx, b.story.storyId, part.partId);
                        },
                        child: Padding(
                          padding: const EdgeInsets.symmetric(
                            vertical: 10,
                            horizontal: 20,
                          ),
                          child: Text(
                            part.title,
                            style: Theme.of(
                              ctx,
                            ).textTheme.labelMedium?.copyWith(fontSize: 16),
                          ),
                        ),
                      ),
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
