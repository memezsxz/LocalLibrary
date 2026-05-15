import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../dependency_injection.dart';
import '../bloc/story_bloc.dart';
import '../bloc/story_event.dart';
import '../bloc/story_state.dart';
import '../widgets/story_footer_section.dart';
import '../widgets/story_header_section.dart';
import '../widgets/story_layout.dart';

class StoryScreen extends StatelessWidget {
  final int storyId;

  const StoryScreen({super.key, required this.storyId});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => StoryBloc(api: sl())..add(StoryRequested(storyId)),
      child: _StoryView(storyId: storyId),
    );
  }
}

class _StoryView extends StatelessWidget {
  const _StoryView({required this.storyId});

  final int storyId;

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

        final story = (state as StoryLoaded).bundle;

        return StoryLayout(
          topBuilder: (margin) =>
              StoryDescriptionTop(margin: margin, story: story),
          bottom: StoryDescriptionBottom(storyBundle: story),
        );
      },
    );
  }
}
