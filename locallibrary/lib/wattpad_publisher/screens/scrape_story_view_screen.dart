import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../dependency_ingection.dart';
import '../bloc/story_bloc.dart';
import '../models/server_models.dart';
import '../widgets/scrape_description_bottom.dart';
import '../widgets/story_description_top.dart';
import 'story_screen.dart';

/// Story screen in scrape mode.
///
/// Reuses [StoryLayout] and [StoryDescriptionTop] from the normal read flow
/// but renders [ScrapeDescriptionBottom] instead of [StoryDescriptionBottom],
/// giving access to per-part scrape controls and a global "Scrape All" bar.
class ScrapeStoryViewScreen extends StatelessWidget {
  final int storyId;
  final ScrapeStoryRes scrapeRes;

  const ScrapeStoryViewScreen({
    super.key,
    required this.storyId,
    required this.scrapeRes,
  });

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => StoryBloc(api: sl())..add(StoryRequested(storyId)),
      child: _ScrapeStoryView(storyId: storyId, scrapeRes: scrapeRes),
    );
  }
}

class _ScrapeStoryView extends StatelessWidget {
  final int storyId;
  final ScrapeStoryRes scrapeRes;

  const _ScrapeStoryView({required this.storyId, required this.scrapeRes});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<StoryBloc, StoryState>(
      builder: (context, state) {
        if (state is StoryLoading || state is StoryInitial) {
          return const Center(child: CircularProgressIndicator());
        }

        if (state is StoryError) {
          return Padding(
            padding: const EdgeInsets.all(16),
            child: Text('Failed to load: ${state.message}'),
          );
        }

        final bundle = (state as StoryLoaded).bundle;

        return StoryLayout(
          topBuilder: (margin) =>
              StoryDescriptionTop(margin: margin, story: bundle),
          bottom: ScrapeDescriptionBottom(bundle: bundle, scrapeRes: scrapeRes),
        );
      },
    );
  }
}
