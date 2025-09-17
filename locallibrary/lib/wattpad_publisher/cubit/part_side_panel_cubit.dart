import 'package:bloc/bloc.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:locallibrary/wattpad_publisher/models/server_models.dart';
import 'package:meta/meta.dart';

import '../models/models.dart';
import '../screens/part_screen.dart';
import '../widgets/part_comments_side_panel.dart';
import '../widgets/part_info_side_panel.dart';
import '../widgets/scrape_log_panel.dart';

part 'part_side_panel_state.dart';

class PartSidePanelCubit extends Cubit<PartSidePanelState> {
  PartSidePanelCubit() : super(PartSidePanelNoneCubit());

  void changeContent(PartSidePanelState state) {
    final prev = this.state.runtimeType.toString();
    if (state is PartSidePanelCommentsCubit) {
      // debugPrint('[PartSidePanelCubit] changeContent(prev=$prev -> next=Comments, storyId=${state.storyId}, paragraph=${state.paragraph?.paragraphId}) | cubitId=${identityHashCode(this)}');
    } else {
      // debugPrint('[PartSidePanelCubit] changeContent(prev=$prev -> next=${state.runtimeType}) | cubitId=${identityHashCode(this)}');
    }
    emit(state);
  }

  void clear() {
    // debugPrint('[PartSidePanelCubit] clear() from=${state.runtimeType} | cubitId=${identityHashCode(this)}');
    emit(PartSidePanelNoneCubit());
  }

}
