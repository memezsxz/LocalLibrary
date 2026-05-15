import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_inner_shadow/flutter_inner_shadow.dart';
import 'package:flutter_svg/svg.dart';
import 'package:locallibrary/wattpad_publisher/cubit/navigation_cubit.dart';
import 'package:locallibrary/wattpad_publisher/cubit/part_side_panel_cubit.dart';

import '../../core/theme/app_palette.dart';
import '../bloc/comments_bloc.dart';
import '../bloc/part_bloc.dart';

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
  final Color panelBg = AppPalette.surfaceAlt;
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
    // Ignore overscroll region — bounce-back would falsely flip _showControls
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
          // Was viewing paragraph comments — reset to part-level comments for new part.
          // _onPanelStateChanged will fire and load the new part's comments.
          panelCubit.changeContent(
            PartSidePanelCommentsCubit(storyId: panelState.storyId),
          );
        } else {
          context.read<CommentsBloc>().add(
            LoadPartComments(
                panelState.storyId, (partState as PartLoaded).info.part.partId),
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

  // ── Desktop ───────────────────────────────────────────────────────────────

  Widget _buildDesktop(BuildContext context, PartSidePanelCubit panelCubit) {
    return Row(
      children: [
        // LEFT: sliding panel
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
                    color: AppPalette.primary.withOpacity(0.3),
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
                  color: widget.panelBg,
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

        // RIGHT: content + full-height dock
        Expanded(
          child: Stack(
            clipBehavior: Clip.none,
            children: [
              widget.content,
              Positioned(
                left: 0,
                top: 0,
                bottom: 0,
                child: _Dock(storyId: widget.storyId, size: widget.dockSize),
              ),
            ],
          ),
        ),
      ],
    );
  }

  // ── Mobile ────────────────────────────────────────────────────────────────

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

              // slide-up panel with drag-to-close
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
                      color: widget.panelBg,
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
                            // drag handle
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
                                final shouldClose = _panelDragOffset >
                                    panelH * 0.3 ||
                                    vel > 400;
                                setState(() {
                                  _isDraggingPanel = false;
                                  _panelDragOffset = 0.0;
                                });
                                if (shouldClose) panelCubit.clear();
                              },
                              child: Padding(
                                padding: const EdgeInsets.symmetric(
                                    vertical: 10),
                                child: Center(
                                  child: Container(
                                    width: 40,
                                    height: 4,
                                    decoration: BoxDecoration(
                                      color: Colors.grey.withOpacity(0.35),
                                      borderRadius: BorderRadius.circular(2),
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

              // FAB back button — hides on scroll up, top-left
              AnimatedPositioned(
                duration: const Duration(milliseconds: 200),
                curve: Curves.easeOut,
                top: _showControls ? 16 : -(fabSize + 16),
                left: 16,
                child: FloatingActionButton.small(
                  heroTag: 'back',
                  backgroundColor: widget.panelBg,
                  foregroundColor: AppPalette.primary,
                  elevation: 4,
                  onPressed: () => context.read<NavigationCubit>().pop(),
                  child: const Icon(Icons.arrow_back),
                ),
              ),
            ],
          ),
        ),

        // bottom nav bar — hides on scroll down
        AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          curve: Curves.easeOut,
          height: _showControls ? navH : 0,
          child: SingleChildScrollView(
            physics: const NeverScrollableScrollPhysics(),
            child: SizedBox(
              height: navH,
              child: _MobileNavBar(storyId: widget.storyId),
            ),
          ),
        ),
      ],
    );
  }

  // ── Helpers ───────────────────────────────────────────────────────────────

  String _panelKey(PartSidePanelState s) {
    if (s is PartSidePanelCommentsCubit) {
      return 'comments_${s.storyId}_${s.paragraph?.paragraphId ?? "none"}';
    }
    if (s is PartSidePanelPartInfoCubit) return 'info_${s.storyId}';
    return s.runtimeType.toString();
  }
}

// ── Desktop dock ──────────────────────────────────────────────────────────────

class _Dock extends StatelessWidget {
  const _Dock({required this.size, required this.storyId});

  final double size;
  final int storyId;

  @override
  Widget build(BuildContext context) {
    const gap = 8.0;
    final panelCubit = context.read<PartSidePanelCubit>();

    return BlocBuilder<PartSidePanelCubit, PartSidePanelState>(
      bloc: panelCubit,
      builder: (context, selected) {
        final bool selectedInfo = selected is PartSidePanelPartInfoCubit;
        final bool selectedTypography = selected is PartSidePanelTypographyCubit;
        final bool selectedComments = selected is PartSidePanelCommentsCubit;

        return Column(
          mainAxisSize: MainAxisSize.max,
          children: [
            // center group: 3 action buttons
            Expanded(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                mainAxisSize: MainAxisSize.max,
                children: [
                  _DockBtn(
                    size: size,
                    iconPath: "assets/icons/parts_icon.svg",
                    selected: selectedInfo,
                    onTap: () =>
                    selectedInfo
                        ? panelCubit.clear()
                        : panelCubit.changeContent(
                      PartSidePanelPartInfoCubit(storyId),
                    ),
                  ),
                  const SizedBox(height: gap),
                  _DockBtn(
                    size: size,
                    iconPath: "assets/icons/typography_icon.svg",
                    selected: selectedTypography,
                    onTap: () =>
                    selectedTypography
                        ? panelCubit.clear()
                        : panelCubit.changeContent(
                        PartSidePanelTypographyCubit()),
                  ),
                  const SizedBox(height: gap),
                  _DockBtn(
                    size: size,
                    iconPath: "assets/icons/comments_icon.svg",
                    selected: selectedComments,
                    onTap: () =>
                    selectedComments
                        ? panelCubit.clear()
                        : panelCubit.changeContent(
                      PartSidePanelCommentsCubit(storyId: storyId),
                    ),
                  ),
                ],
              ),
            ),

            // back button at the very bottom
            _DockBtn(
              size: size,
              selected: false,
              iconWidget: Icon(
                Icons.arrow_back,
                color: AppPalette.primary,
                size: size * 0.40,
              ),
              onTap: () => context.read<NavigationCubit>().pop(),
            ),
            const SizedBox(height: 8),
          ],
        );
      },
    );
  }
}

class _DockBtn extends StatelessWidget {
  const _DockBtn({
    required this.size,
    required this.onTap,
    required this.selected,
    this.iconPath,
    this.iconWidget,
  });

  final String? iconPath;
  final Widget? iconWidget;
  final double size;
  final VoidCallback onTap;
  final bool selected;

  @override
  Widget build(BuildContext context) {
    final inner = size * 0.40;

    const shape = RoundedRectangleBorder(
      borderRadius: BorderRadiusDirectional.horizontal(
        end: Radius.circular(50),
      ),
    );

    Widget core = ClipRect(
      clipper: ClipPad(padding: const EdgeInsets.all(30).copyWith(left: 0)),
      child: SizedBox(
        width: size,
        height: size,
        child: Material(
          clipBehavior: Clip.antiAlias,
          color: AppPalette.surfaceAlt,
          shape: shape,
          elevation: selected ? 15 : 0,
          shadowColor: AppPalette.primary.withOpacity(0.3),
          child: InkWell(
            customBorder: shape,
            onTap: onTap,
            overlayColor: WidgetStateProperty.all(AppPalette.transparent),
            child: Center(
              child: SizedBox(
                width: inner,
                height: inner,
                child: iconWidget ??
                    SvgPicture.asset(iconPath!, color: AppPalette.primary),
              ),
            ),
          ),
        ),
      ),
    );

    if (!selected) {
      core = InnerShadow(
        shadows: [
          Shadow(
            color: AppPalette.primary.withOpacity(0.35),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
        child: core,
      );
    }

    return core;
  }
}

class ClipPad extends CustomClipper<Rect> {
  final EdgeInsets padding;

  const ClipPad({this.padding = EdgeInsets.zero});

  @override
  Rect getClip(Size size) => padding.inflateRect(Offset.zero & size);

  @override
  bool shouldReclip(ClipPad oldClipper) => oldClipper.padding != padding;
}

// ── Mobile nav bar ────────────────────────────────────────────────────────────

class _MobileNavBar extends StatelessWidget {
  const _MobileNavBar({required this.storyId});

  final int storyId;

  @override
  Widget build(BuildContext context) {
    final panelCubit = context.read<PartSidePanelCubit>();
    return BlocBuilder<PartSidePanelCubit, PartSidePanelState>(
      builder: (context, selected) {
        final isInfo = selected is PartSidePanelPartInfoCubit;
        final isTypo = selected is PartSidePanelTypographyCubit;
        final isComments = selected is PartSidePanelCommentsCubit;

        return Container(
          height: 60,
          decoration: BoxDecoration(
            color: AppPalette.surfaceAlt,
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.1),
                blurRadius: 8,
                offset: const Offset(0, -2),
              ),
            ],
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            spacing: 16,
            children: [
              _NavBtn(
                iconPath: "assets/icons/parts_icon.svg",
                selected: isInfo,
                onTap: () =>
                isInfo
                    ? panelCubit.clear()
                    : panelCubit.changeContent(
                  PartSidePanelPartInfoCubit(storyId),
                ),
              ),
              _NavBtn(
                iconPath: "assets/icons/typography_icon.svg",
                selected: isTypo,
                onTap: () =>
                isTypo
                    ? panelCubit.clear()
                    : panelCubit.changeContent(PartSidePanelTypographyCubit()),
              ),
              _NavBtn(
                iconPath: "assets/icons/comments_icon.svg",
                selected: isComments,
                onTap: () =>
                isComments
                    ? panelCubit.clear()
                    : panelCubit.changeContent(
                  PartSidePanelCommentsCubit(storyId: storyId),
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}

class _NavBtn extends StatelessWidget {
  const _NavBtn({
    required this.iconPath,
    required this.selected,
    required this.onTap,
  });

  final String iconPath;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: selected
              ? AppPalette.primary.withOpacity(0.15)
              : Colors.transparent,
          borderRadius: BorderRadius.circular(12),
        ),
        child: SvgPicture.asset(
          iconPath,
          width: 24,
          color: selected
              ? AppPalette.primary
              : AppPalette.primary.withOpacity(0.4),
        ),
      ),
    );
  }
}