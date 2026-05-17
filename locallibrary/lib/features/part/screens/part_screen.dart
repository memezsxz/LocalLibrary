import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../dependency_injection.dart';
import '../../comments/bloc/comments_bloc.dart';
import '../../story/bloc/story_bloc.dart';
import '../../story/bloc/story_event.dart';
import '../bloc/part_bloc.dart';
import '../cubit/part_side_panel_cubit.dart';
import 'part_view.dart';

class PartScreen extends StatelessWidget {
  final int storyId;
  final int partId;
  final int? targetParagraphId;
  final int? targetCommentId;

  const PartScreen({
    super.key,
    required this.storyId,
    required this.partId,
    this.targetParagraphId,
    this.targetCommentId,
  });

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider<StoryBloc>.value(
          value: sl<StoryBloc>()..add(StoryRequested(storyId)),
        ),
        BlocProvider<PartBloc>(
          create: (_) =>
              sl<PartBloc>()
                ..add(PartFetchRequested(storyId: storyId, partId: partId)),
        ),
        BlocProvider<PartSidePanelCubit>(
          create: (_) => sl<PartSidePanelCubit>(),
        ),
        BlocProvider<CommentsBloc>(create: (_) => sl<CommentsBloc>()),
      ],
      child: PartView(
        storyId: storyId,
        targetParagraphId: targetParagraphId,
        targetCommentId: targetCommentId,
      ),
    );
  }
}