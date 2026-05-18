import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../core/api/story_api_client.dart';
import '../../../core/common/widgets/loader.dart';
import '../../../core/theme/app_palette.dart';
import '../../../dependency_injection.dart';
import '../../story/bloc/story_bloc.dart';
import '../../story/bloc/story_event.dart';
import '../../story/bloc/story_state.dart';
import '../../story/models/dto/part_full_info.dart';
import '../../story/models/dto/story_bundle.dart';
import '../bloc/part_bloc.dart';
import '../widgets/paragraphs_column.dart' show ProgressRecord;
import '../widgets/part_content.dart';
import '../widgets/part_divider.dart';
import '../widgets/part_peek_bar.dart';
import '../widgets/part_side_panel.dart';

class PartView extends StatefulWidget {
  const PartView({
    super.key,
    required this.storyId,
    this.targetParagraphId,
    this.targetCommentId,
  });

  final int storyId;
  final int? targetParagraphId;
  final int? targetCommentId;

  @override
  State<PartView> createState() => _PartViewState();
}

class _PartViewState extends State<PartView>
    with SingleTickerProviderStateMixin {
  late final ScrollController _scrollController;
  late final AnimationController _fadeCtrl;
  late PartBloc _partBloc;
  final List<PartFullInfo> _parts = [];
  final ValueNotifier<ProgressRecord?> _progressNotifier = ValueNotifier(null);
  bool _seeded = false;
  bool _loadingNext = false;
  bool _loadingPrev = false;

  final ValueNotifier<double> _bottomOverscroll = ValueNotifier(0.0);
  final ValueNotifier<double> _topOverscroll = ValueNotifier(0.0);

  static const double _kThresholdDesktop = 200.0;
  static const double _kThresholdMobile = 150.0;
  static const Duration _fadeDuration = Duration(milliseconds: 220);

  static bool get _isDesktop =>
      defaultTargetPlatform == TargetPlatform.macOS ||
      defaultTargetPlatform == TargetPlatform.windows ||
      defaultTargetPlatform == TargetPlatform.linux;

  double get _kThreshold => _isDesktop ? _kThresholdDesktop : _kThresholdMobile;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _partBloc = context.read<PartBloc>();
  }

  @override
  void initState() {
    super.initState();
    _scrollController = ScrollController();
    _scrollController.addListener(_onScroll);
    _fadeCtrl = AnimationController(
      vsync: this,
      duration: _fadeDuration,
      value: 1.0,
    );
  }

  @override
  void dispose() {
    final p = _progressNotifier.value;
    if (p != null) {
      _partBloc.add(PartProgressUpdated(
        storyId: widget.storyId,
        lastParagraphId: p.paragraphId,
      ));
    }
    _progressNotifier.dispose();
    _scrollController.removeListener(_onScroll);
    _scrollController.dispose();
    _fadeCtrl.dispose();
    _bottomOverscroll.dispose();
    _topOverscroll.dispose();
    super.dispose();
  }

  void _onScroll() {
    if (!_scrollController.hasClients) return;
    final pos = _scrollController.position;

    final bottomOS = (pos.pixels - pos.maxScrollExtent).clamp(
      0.0,
      double.infinity,
    );
    final topOS = (pos.minScrollExtent - pos.pixels).clamp(
      0.0,
      double.infinity,
    );

    _bottomOverscroll.value = bottomOS;
    _topOverscroll.value = topOS;

    if (bottomOS >= _kThreshold && !_loadingNext) _loadNext();
    if (topOS >= _kThreshold && !_loadingPrev) _loadPrev();
  }

  StoryBundle? _bundle() =>
      context.read<StoryBloc>().state.bundles[widget.storyId];

  Future<void> _replaceWith(PartFullInfo info, {required bool toEnd}) async {
    await _fadeCtrl.reverse();
    if (!mounted) return;
    setState(
      () => _parts
        ..clear()
        ..add(info),
    );
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!_scrollController.hasClients) return;
      _scrollController.jumpTo(
        toEnd ? _scrollController.position.maxScrollExtent : 0,
      );
    });
    _fadeCtrl.forward();
  }

  Future<void> _loadNext() async {
    final bundle = _bundle();
    if (bundle == null || _parts.isEmpty) return;
    final lastId = _parts.last.part.partId;
    final idx = bundle.parts.indexWhere((p) => p.partId == lastId);
    if (idx == -1 || idx >= bundle.parts.length - 1) return;
    _loadingNext = true;
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) setState(() {});
    });
    try {
      final info = await sl<StoryApiClient>().getFullPartInfo(
        widget.storyId,
        bundle.parts[idx + 1].partId,
      );
      if (!mounted) return;
      await _replaceWith(info, toEnd: false);
      if (!mounted) return;
      _syncBlocs(info);
    } finally {
      if (mounted) setState(() => _loadingNext = false);
      _bottomOverscroll.value = 0;
    }
  }

  Future<void> _loadPrev() async {
    final bundle = _bundle();
    if (bundle == null || _parts.isEmpty) return;
    final firstId = _parts.first.part.partId;
    final idx = bundle.parts.indexWhere((p) => p.partId == firstId);
    if (idx <= 0) return;
    _loadingPrev = true;
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) setState(() {});
    });
    try {
      final info = await sl<StoryApiClient>().getFullPartInfo(
        widget.storyId,
        bundle.parts[idx - 1].partId,
      );
      if (!mounted) return;
      await _replaceWith(info, toEnd: true);
      if (!mounted) return;
      _syncBlocs(info);
    } finally {
      if (mounted) setState(() => _loadingPrev = false);
      _topOverscroll.value = 0;
    }
  }

  void _syncBlocs(PartFullInfo info) {
    final p = _progressNotifier.value;
    if (p != null) {
      context.read<PartBloc>().add(PartProgressUpdated(
        storyId: widget.storyId,
        lastParagraphId: p.paragraphId,
      ));
    }
    context.read<PartBloc>().add(PartDataProvided(info));
    context.read<PartBloc>().add(PartProgressStarted(storyId: widget.storyId));
    context.read<StoryBloc>().add(
      StoryCurrentPartChanged(widget.storyId, info.part),
    );
  }

  String? _adjacentTitle(StoryBundle bundle, int partId, int delta) {
    final idx = bundle.parts.indexWhere((p) => p.partId == partId);
    if (idx == -1) return null;
    final adj = idx + delta;
    if (adj < 0 || adj >= bundle.parts.length) return null;
    return bundle.parts[adj].title;
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener<PartBloc, PartState>(
      listener: (context, state) {
        if (state is PartLoaded && !_seeded) {
          _seeded = true;
          setState(() {
            _parts
              ..clear()
              ..add(state.info);
          });
          context.read<StoryBloc>().add(
            StoryCurrentPartChanged(widget.storyId, state.info.part),
          );
        }
      },
      child: BlocBuilder<PartBloc, PartState>(
        builder: (context, partState) {
          return BlocBuilder<StoryBloc, StoryState>(
            builder: (context, storyState) {
              final bundle = storyState.bundles[widget.storyId];

              if (_parts.isEmpty) {
                if (partState is PartError) {
                  return Scaffold(
                    body: Center(child: Text('Failed: ${partState.message}')),
                  );
                }
                return const Scaffold(body: Center(child: Loader()));
              }

              final nextTitle = bundle != null
                  ? _adjacentTitle(bundle, _parts.last.part.partId, 1)
                  : null;
              final prevTitle = bundle != null
                  ? _adjacentTitle(bundle, _parts.first.part.partId, -1)
                  : null;

              return Scaffold(
                backgroundColor: Colors.white,
                body: SafeArea(
                  child: SidePanelScaffold(
                    storyId: widget.storyId,
                    panelWidth: MediaQuery.of(context).size.width / 4,
                    dockSize: 40,
                    scrollController: _scrollController,
                    content: FadeTransition(
                      opacity: _fadeCtrl,
                      child: Stack(
                        children: [
                          CustomScrollView(
                            controller: _scrollController,
                            physics: const BouncingScrollPhysics(
                              parent: AlwaysScrollableScrollPhysics(),
                            ),
                            slivers: [
                              for (int i = 0; i < _parts.length; i++) ...[
                                if (i > 0)
                                  SliverToBoxAdapter(
                                    child: PartDivider(
                                      title: _parts[i].part.title,
                                    ),
                                  ),
                                SliverToBoxAdapter(
                                  child: Align(
                                    alignment: Alignment.topCenter,
                                    child: ConstrainedBox(
                                      constraints: BoxConstraints(
                                        maxWidth:
                                            MediaQuery.of(context).size.width <
                                                900
                                            ? double.infinity
                                            : MediaQuery.of(
                                                    context,
                                                  ).size.width /
                                                  1.6,
                                        minHeight: i == 0
                                            ? MediaQuery.sizeOf(context).height
                                            : 0,
                                      ),
                                      child: Container(
                                        decoration: BoxDecoration(
                                          color: AppPalette.surfaceAlt,
                                          image: const DecorationImage(
                                            repeat: ImageRepeat.repeat,
                                            image: AssetImage(
                                              'assets/images/texture_5.png',
                                            ),
                                            fit: BoxFit.none,
                                            opacity: 0.1,
                                          ),
                                          boxShadow: [
                                            BoxShadow(
                                              color: Colors.black.withOpacity(
                                                0.25,
                                              ),
                                              blurRadius: 40,
                                            ),
                                          ],
                                        ),
                                        alignment: Alignment.topCenter,
                                        child: PartContent(
                                          storyId: widget.storyId,
                                          info: _parts[i],
                                          scrollController: _scrollController,
                                          progressNotifier: _progressNotifier,
                                          targetParagraphId:
                                              widget.targetParagraphId,
                                          targetCommentId:
                                              widget.targetCommentId,
                                        ),
                                      ),
                                    ),
                                  ),
                                ),
                              ],
                            ],
                          ),
                          if (prevTitle != null)
                            Positioned(
                              top: 0,
                              left: 0,
                              right: 0,
                              child: PartPeekBar(
                                overscroll: _topOverscroll,
                                threshold: _kThreshold,
                                title: prevTitle,
                                loading: _loadingPrev,
                                direction: PeekDirection.top,
                              ),
                            ),
                          if (nextTitle != null)
                            Positioned(
                              bottom: 0,
                              left: 0,
                              right: 0,
                              child: PartPeekBar(
                                overscroll: _bottomOverscroll,
                                threshold: _kThreshold,
                                title: nextTitle,
                                loading: _loadingNext,
                                direction: PeekDirection.bottom,
                              ),
                            ),
                        ],
                      ),
                    ),
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }
}
