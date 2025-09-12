import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_inner_shadow/flutter_inner_shadow.dart';
import 'package:flutter_svg/svg.dart';
import 'package:locallibrary/wattpad_publisher/cubit/part_side_panel_cubit.dart';

import '../../core/theme/app_palette.dart';
import '../../dependency_ingection.dart';
import '../bloc/comments_bloc.dart';
import '../bloc/part_bloc.dart';

// enum SidePanel { none, comments, typography, info }

class SidePanelScaffold extends StatefulWidget {
  const SidePanelScaffold({
    super.key,
    required this.content, // your main screen
    required this.storyId, // your main screen
    this.panelWidth = 320,
    // this.panelBg , // your beige
    this.dockSize = 40,
  });

  final Widget content;

  final double panelWidth;
  final Color panelBg = AppPalette.surfaceAlt;
  final double dockSize;
  final int storyId;

  @override
  State<SidePanelScaffold> createState() => SidePanelScaffoldState();
}

class SidePanelScaffoldState extends State<SidePanelScaffold> {
  @override
  Widget build(BuildContext context) {
    // debugPrint('panel cubit id = ${identityHashCode(sl<PartSidePanelCubit>())}');

    // Use the instance from widget tree to avoid DI mismatches
    final panelCubit = context.read<PartSidePanelCubit>();

    return BlocListener<PartSidePanelCubit, PartSidePanelState>(
      bloc: panelCubit,
      listener: (context, state) {
        debugPrint('[SidePanelScaffold] listener state=${state.runtimeType}');

        // Option B: prime comments when we switch to Comments with a paragraph
        if (state is PartSidePanelCommentsCubit) {
          final commentsBloc = context.read<CommentsBloc>();
          final blocId = identityHashCode(commentsBloc);
          if (state.paragraph != null) {
            debugPrint('[SidePanelScaffold] priming paragraph comments for storyId=${state.storyId} paragraph=${state.paragraph!.paragraphId} | CommentsBloc id=$blocId');
            commentsBloc.add(
              LoadParagraphComments(state.storyId, state.paragraph!.paragraphId),
            );
          } else {
            final partState = context.read<PartBloc>().state;
            if (partState is PartLoaded) {
              final partId = partState.info.part.partId;
              debugPrint('[SidePanelScaffold] priming part comments for storyId=${state.storyId} partId=$partId | CommentsBloc id=$blocId');
              commentsBloc.add(LoadPartComments(state.storyId, partId));
            } else {
              debugPrint('[SidePanelScaffold] cannot prime part comments: PartBloc not loaded');
            }
          }
        }
      },
      child: Row(
        children: [
          // LEFT: sliding panel
          BlocBuilder<PartSidePanelCubit, PartSidePanelState>(
            bloc: panelCubit,
            builder: (context, state) {
              // using the SL singleton directly
              debugPrint('Panel BlocBuilder rebuild - state: ${state.runtimeType}');

              // be tolerant to either naming
              final bool isClosed = state is PartSidePanelNoneCubit;

              final double panelW = isClosed ? 0.0 : widget.panelWidth;
              final currentKey = _panelKey(state);
              debugPrint('[SidePanelScaffold] isClosed=$isClosed width=$panelW key=$currentKey');

              // (optional) quick debug
              // debugPrint('panel cubit id=${identityHashCode(panelCubit)} state=${state.runtimeType} width=$panelW');

              return AnimatedContainer(
                width: panelW,
                height: double.infinity,
                duration: const Duration(milliseconds: 280),
                curve: Curves.easeOutCubic,
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
                    ? (() {
                        debugPrint('[SidePanelScaffold] Panel is closed -> rendering SizedBox');
                        return const SizedBox.shrink();
                      })()
                    : Material(
                        color: widget.panelBg,
                        elevation: 4,
                        child: KeyedSubtree(
                          key: ValueKey(currentKey),
                          child: LayoutBuilder(
                            builder: (context, constraints) {
                              debugPrint('[SidePanelScaffold] panel child -> $currentKey (${state.runtimeType}) | panel constraints: minW=${constraints.minWidth}, maxW=${constraints.maxWidth}, minH=${constraints.minHeight}, maxH=${constraints.maxHeight}');
                              if (constraints.minWidth > constraints.maxWidth || constraints.minHeight > constraints.maxHeight) {
                                debugPrint('[SidePanelScaffold][WARN] NON-NORMALIZED constraints passed into panel');
                              }
                              return state.get(); // returns CommentsPanel/Info/...
                            },
                          ),
                        ),
                      ),
              );
            },
          ),

          // RIGHT: content + dock
          Expanded(
            child: Stack(
              clipBehavior: Clip.none,
              children: [
                widget.content,
                Align(
                  alignment: Alignment.centerLeft,
                  child: Transform.translate(
                    offset: const Offset(0, 0),
                    child: _Dock(storyId: widget.storyId, size: widget.dockSize),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  String _panelKey(PartSidePanelState s) {
    if (s is PartSidePanelCommentsCubit) {
      return 'comments_${s.storyId}_${s.paragraph?.paragraphId ?? "none"}';
    }
    if (s is PartSidePanelPartInfoCubit) {
      return 'info_${s.storyId}';
    }
    return s.runtimeType.toString();
  }
}

class _Dock extends StatelessWidget {
  const _Dock({required this.size, required this.storyId, super.key});

  final double size;
  final int storyId;

  @override
  Widget build(BuildContext context) {
    const gap = 8.0;

    // get the cubit from the widget tree
    final panelCubit = context.read<PartSidePanelCubit>();
    debugPrint('[Dock] panel cubit id (context) = ${identityHashCode(panelCubit)}');

    return BlocBuilder<PartSidePanelCubit, PartSidePanelState>(
      bloc: panelCubit, // <- use context-provided cubit
      builder: (context, selected) {
        debugPrint('Dock BlocBuilder rebuild - state: ${selected.runtimeType}');
        final bool selectedInfo        = selected is PartSidePanelPartInfoCubit;
        final bool selectedTypography  = selected is PartSidePanelTypographyCubit;
        final bool selectedComments    = selected is PartSidePanelCommentsCubit;
        debugPrint('Dock selected states - info: $selectedInfo, typography: $selectedTypography, comments: $selectedComments');

        final all = <Widget>[
          _DockBtn(
            size: size,
            iconPath: "assets/icons/parts_icon.svg",
            onTap: () {
              if (selectedInfo) {
                panelCubit.clear(); // toggle close
              } else {
                panelCubit.changeContent(PartSidePanelPartInfoCubit(storyId));
              }
            },
            selected: selectedInfo,
          ),
          const SizedBox(height: gap),
          _DockBtn(
            size: size,
            iconPath: "assets/icons/typography_icon.svg",
            onTap: () {
              if (selectedTypography) {
                panelCubit.clear();
              } else {
                panelCubit.changeContent(PartSidePanelTypographyCubit());
              }
            },
            selected: selectedTypography,
          ),
          const SizedBox(height: gap),
          _DockBtn(
            size: size,
            iconPath: "assets/icons/comments_icon.svg",
            onTap: () {
              debugPrint('Comments dock button clicked - selectedComments: $selectedComments');
              if (selectedComments) {
                debugPrint('Clearing panel');
                panelCubit.clear();
              } else {
                debugPrint('Opening comments panel for storyId: $storyId (no paragraph)');
                panelCubit.changeContent(
                  PartSidePanelCommentsCubit(storyId: storyId),
                );
              }
            },
            selected: selectedComments,
          ),
        ];

        return AnimatedSize(
          duration: const Duration(milliseconds: 180),
          curve: Curves.linear,
          child: Column(mainAxisSize: MainAxisSize.min, children: all),
        );
      },
    );
  }
}

class _DockBtn extends StatelessWidget {
  const _DockBtn({
    super.key,
    required this.iconPath,
    required this.size,
    required this.onTap,
    required this.selected,
  });

  final String iconPath;
  final double size; // outer tap target
  final VoidCallback onTap;
  final bool selected;

  @override
  Widget build(BuildContext context) {
    final inner = size * 0.40;

    // same pill-ish shape you used before
    const shape = RoundedRectangleBorder(
      borderRadius: BorderRadiusDirectional.horizontal(
        end: Radius.circular(50),
      ),
    );

    // core button (ripple, icon, background)
    Widget core = ClipRect(
      clipper: ClipPad(padding: EdgeInsets.all(30).copyWith(left: 0)),
      child: SizedBox(
        width: size,
        height: size,
        child: Material(
          clipBehavior: Clip.antiAlias,
          // clip ripple to shape
          color: AppPalette.surfaceAlt,
          shape: shape,
          elevation: selected ? 15 : 0,
          // ← outer shadow when selected
          shadowColor: AppPalette.primary.withOpacity(0.3),
          child: InkWell(
            customBorder: shape, // match ripple shape
            onTap: onTap,
            overlayColor: WidgetStateProperty.all(AppPalette.transparent),
            child: Center(
              child: SizedBox(
                width: inner,
                height: inner,
                child: SvgPicture.asset(iconPath, color: AppPalette.primary),
              ),
            ),
          ),
        ),
      ),
    );

    // add inner shadow only when NOT selected
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

/// Clips the given object by its size.
/// The clip area can optionally be enlarged by a given padding.
class ClipPad extends CustomClipper<Rect> {
  final EdgeInsets padding;

  const ClipPad({this.padding = EdgeInsets.zero});

  @override
  Rect getClip(Size size) => padding.inflateRect(Offset.zero & size);

  @override
  bool shouldReclip(ClipPad oldClipper) => oldClipper.padding != padding;
}
