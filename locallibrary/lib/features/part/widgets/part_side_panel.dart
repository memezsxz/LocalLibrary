import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../core/theme/app_theme.dart';
import '../../comments/bloc/comments_bloc.dart';
import '../../library/cubit/navigation_cubit.dart';
import '../bloc/part_bloc.dart';
import '../cubit/part_side_panel_cubit.dart';
import 'part_dock.dart';
import 'part_mobile_nav_bar.dart';

class SidePanelScaffold extends StatefulWidget {
  const SidePanelScaffold({
    super.key,
    required this.content,
    required this.storyId,
    this.panelWidth = 320,
    this.dockSize = 40,
    this.scrollController,
  });

  final Widget content;
  final double panelWidth;
  final double dockSize;
  final int storyId;
  final ScrollController? scrollController;

  @override
  State<SidePanelScaffold> createState() => SidePanelScaffoldState();
}

class SidePanelScaffoldState extends State<SidePanelScaffold> {
  bool _showControls = true;
  double _prevOffset = 0;
  double _panelDragOffset = 0.0;
  bool _isDraggingPanel = false;

  @override
  void initState() {
    super.initState();
    widget.scrollController?.addListener(_onScroll);
  }

  @override
  void didUpdateWidget(SidePanelScaffold old) {
    super.didUpdateWidget(old);
    if (old.scrollController != widget.scrollController) {
      old.scrollController?.removeListener(_onScroll);
      widget.scrollController?.addListener(_onScroll);
    }
  }

  @override
  void dispose() {
    widget.scrollController?.removeListener(_onScroll);
    super.dispose();
  }

  void _onScroll() {
    final sc = widget.scrollController;
    if (sc == null || !sc.hasClients) return;
    final pos = sc.position;
    if (pos.pixels > pos.maxScrollExtent || pos.pixels < pos.minScrollExtent)
      return;
    final offset = pos.pixels;
    final goingDown = offset > _prevOffset;
    _prevOffset = offset;
    if (goingDown == _showControls) {
      setState(() => _showControls = !goingDown);
    }
  }

  @override
  Widget build(BuildContext context) {
    final panelCubit = context.read<PartSidePanelCubit>();
    final isMobile = MediaQuery
        .of(context)
        .size
        .width < 1200;

    return BlocListener<PartBloc, PartState>(
      listenWhen: (prev, next) =>
      next is PartLoaded && prev is PartLoaded
          ? (prev as PartLoaded).info.part.partId !=
          (next as PartLoaded).info.part.partId
          : next is PartLoaded,
      listener: (context, partState) {
        final panelState = panelCubit.state;
        if (panelState is! PartSidePanelCommentsCubit) return;
        if (panelState.paragraph != null) {
          panelCubit.changeContent(
            PartSidePanelCommentsCubit(storyId: panelState.storyId),
          );
        } else {
          context.read<CommentsBloc>().add(
            LoadPartComments(
              panelState.storyId,
              (partState as PartLoaded).info.part.partId,
            ),
          );
        }
      },
      child: BlocListener<PartSidePanelCubit, PartSidePanelState>(
        bloc: panelCubit,
        listener: _onPanelStateChanged,
        child: isMobile
            ? _buildMobile(context, panelCubit)
            : _buildDesktop(context, panelCubit),
      ),
    );
  }

  void _onPanelStateChanged(BuildContext context, PartSidePanelState state) {
    if (state is PartSidePanelCommentsCubit) {
      final commentsBloc = context.read<CommentsBloc>();
      if (state.paragraph != null) {
        commentsBloc.add(
          LoadParagraphComments(state.storyId, state.paragraph!.paragraphId),
        );
      } else {
        final partState = context
            .read<PartBloc>()
            .state;
        if (partState is PartLoaded) {
          commentsBloc.add(
            LoadPartComments(state.storyId, partState.info.part.partId),
          );
        }
      }
    }
  }

  Widget _buildDesktop(BuildContext context, PartSidePanelCubit panelCubit) {
    return Row(
      children: [
        BlocBuilder<PartSidePanelCubit, PartSidePanelState>(
          bloc: panelCubit,
          builder: (context, state) {
            final bool isClosed = state is PartSidePanelNoneCubit;
            final double panelW = isClosed ? 0.0 : widget.panelWidth;
            final currentKey = _panelKey(state);

            return AnimatedContainer(
              width: panelW,
              height: double.infinity,
              duration: const Duration(milliseconds: 280),
              curve: Curves.easeOutCubic,
              clipBehavior: Clip.hardEdge,
              decoration: BoxDecoration(
                boxShadow: [
                  BoxShadow(
                    offset: const Offset(2, 12),
                    color: context.colors.primary.withOpacity(0.3),
                    blurRadius: 20,
                  ),
                ],
              ),
              child: panelW == 0
                  ? const SizedBox.shrink()
                  : OverflowBox(
                minWidth: widget.panelWidth,
                maxWidth: widget.panelWidth,
                child: Material(
                  color: context.colors.surfaceAlt,
                  elevation: 4,
                  child: KeyedSubtree(
                    key: ValueKey(currentKey),
                    child: state.get(),
                  ),
                ),
              ),
            );
          },
        ),
        Expanded(
          child: Stack(
            clipBehavior: Clip.none,
            children: [
              widget.content,
              Positioned(
                left: 0,
                top: 0,
                bottom: 0,
                child: SidePanelDock(
                  storyId: widget.storyId,
                  size: widget.dockSize,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildMobile(BuildContext context, PartSidePanelCubit panelCubit) {
    final panelH = MediaQuery
        .of(context)
        .size
        .height * 0.75;
    const navH = 60.0;
    const fabSize = 40.0;

    return Column(
      children: [
        Expanded(
          child: Stack(
            clipBehavior: Clip.none,
            children: [
              GestureDetector(
                behavior: HitTestBehavior.translucent,
                onTap: () => setState(() => _showControls = !_showControls),
                child: widget.content,
              ),
              BlocBuilder<PartSidePanelCubit, PartSidePanelState>(
                bloc: panelCubit,
                builder: (context, state) {
                  final isOpen = state is! PartSidePanelNoneCubit;
                  final bottom = isOpen ? -_panelDragOffset : -panelH;

                  return AnimatedPositioned(
                    duration: _isDraggingPanel
                        ? Duration.zero
                        : const Duration(milliseconds: 280),
                    curve: Curves.easeOutCubic,
                    bottom: bottom,
                    left: 0,
                    right: 0,
                    height: panelH,
                    child: Material(
                      color: context.colors.surfaceAlt,
                      elevation: 8,
                      borderRadius: const BorderRadius.vertical(
                        top: Radius.circular(16),
                      ),
                      child: ClipRRect(
                        borderRadius: const BorderRadius.vertical(
                          top: Radius.circular(16),
                        ),
                        child: isOpen
                            ? Column(
                          children: [
                            GestureDetector(
                              behavior: HitTestBehavior.opaque,
                              onVerticalDragUpdate: (d) {
                                setState(() {
                                  _isDraggingPanel = true;
                                  _panelDragOffset =
                                      (_panelDragOffset + d.delta.dy)
                                          .clamp(0.0, panelH);
                                });
                              },
                              onVerticalDragEnd: (d) {
                                final vel = d.primaryVelocity ?? 0;
                                final shouldClose =
                                    _panelDragOffset > panelH * 0.3 ||
                                        vel > 400;
                                setState(() {
                                  _isDraggingPanel = false;
                                  _panelDragOffset = 0.0;
                                });
                                if (shouldClose) panelCubit.clear();
                              },
                              child: Padding(
                                padding: const EdgeInsets.symmetric(
                                  vertical: 10,
                                ),
                                child: Center(
                                  child: Container(
                                    width: 40,
                                    height: 4,
                                    decoration: BoxDecoration(
                                      color: context.colors.primaryLight,
                                      borderRadius: BorderRadius.circular(
                                        2,
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                            ),
                            Expanded(
                              child: KeyedSubtree(
                                key: ValueKey(_panelKey(state)),
                                child: state.get(),
                              ),
                            ),
                          ],
                        )
                            : const SizedBox.shrink(),
                      ),
                    ),
                  );
                },
              ),
              AnimatedPositioned(
                duration: const Duration(milliseconds: 200),
                curve: Curves.easeOut,
                top: _showControls ? 16 : -(fabSize + 16),
                left: 16,
                child: FloatingActionButton.small(
                  heroTag: 'back',
                  backgroundColor: context.colors.surfaceAlt,
                  foregroundColor: context.colors.primary,
                  elevation: 4,
                  onPressed: () => context.read<NavigationCubit>().pop(),
                  child: const Icon(Icons.arrow_back),
                ),
              ),
            ],
          ),
        ),
        AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          curve: Curves.easeOut,
          height: _showControls ? navH : 0,
          child: SingleChildScrollView(
            physics: const NeverScrollableScrollPhysics(),
            child: SizedBox(
              height: navH,
              child: SidePanelMobileNavBar(storyId: widget.storyId),
            ),
          ),
        ),
      ],
    );
  }

  String _panelKey(PartSidePanelState s) {
    if (s is PartSidePanelCommentsCubit) {
      return 'comments_${s.storyId}_${s.paragraph?.paragraphId ?? "none"}';
    }
    if (s is PartSidePanelPartInfoCubit) return 'info_${s.storyId}';
    return s.runtimeType.toString();
  }
}
