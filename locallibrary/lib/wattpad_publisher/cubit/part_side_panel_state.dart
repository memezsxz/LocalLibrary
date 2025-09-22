part of 'part_side_panel_cubit.dart';

@immutable
sealed class PartSidePanelState {
  Widget get();
}

final class PartSidePanelNoneCubit extends PartSidePanelState {
  @override
  Widget get() {
    return const SizedBox.shrink();
  }
}

final class PartSidePanelPartInfoCubit extends PartSidePanelState {
  final int storyId;

  PartSidePanelPartInfoCubit(this.storyId);

  @override
  Widget get() {
    return PartInfoSidePanel(storyId: storyId);
  }
}

final class PartSidePanelCommentsCubit extends PartSidePanelState {
  final Paragraph? paragraph;
  final int storyId;

  PartSidePanelCommentsCubit({required this.storyId, this.paragraph});

  @override
  Widget get() {

    return CommentsPanel(storyId: storyId, paragraph: paragraph,);

    // return Container(
    //   color: Colors.red,
    //   child: Center(
    //     child: Text(
    //       'TEST COMMENTS PANEL - StoryId: $storyId, Paragraph: ${paragraph?.paragraphId ?? "none"}',
    //       style: TextStyle(color: Colors.white, fontSize: 16),
    //     ),
    //   ),
    // );
  }
}

final class PartSidePanelTypographyCubit extends PartSidePanelState {
  @override
  Widget get() {
    return Placeholder();
  }
}
