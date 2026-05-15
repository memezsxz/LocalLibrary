import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_html/flutter_html.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:locallibrary/features/story/models/domain/story_enums.dart';
import 'package:path/path.dart' as path;
import 'package:url_launcher/url_launcher.dart';
import 'package:video_player/video_player.dart';

import '../../../core/common/widgets/loader.dart';
import '../../../core/datasource.dart';
import '../../../core/extensions/image.dart';
import '../../../core/theme/app_palette.dart';
import '../../../core/theme/theme.dart';
import '../../../dependency_injection.dart';
import '../../comments/bloc/comments_bloc.dart';
import '../../comments/widgets/comment_icon.dart';
import '../../story/bloc/story_bloc.dart';
import '../../story/bloc/story_event.dart';
import '../../story/bloc/story_state.dart';
import '../../story/models/dto/part_full_info.dart';
import '../../story/models/dto/story_bundle.dart';
import '../bloc/part_bloc.dart';
import '../cubit/part_side_panel_cubit.dart';
import '../widgets/part_image_view.dart';
import '../widgets/part_side_panel.dart';

class PartScreen extends StatelessWidget {
  final int storyId;
  final int partId;

  const PartScreen({super.key, required this.storyId, required this.partId});

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider<StoryBloc>.value(
          value: sl<StoryBloc>()
            ..add(StoryRequested(storyId)),
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

        // BlocProvider(
        //   create: (ctx) => sl.get<CommentsBloc>(),
        // ),
      ],
      child: _PartView(storyId: storyId),
    );
  }
}

class _PartView extends StatefulWidget {
  const _PartView({required this.storyId});

  final int storyId;

  @override
  State<_PartView> createState() => _PartViewState();
}

class _PartViewState extends State<_PartView>
    with SingleTickerProviderStateMixin {
  late final ScrollController _scrollController;
  late final AnimationController _fadeCtrl;
  final List<PartFullInfo> _parts = [];
  bool _seeded = false;
  bool _loadingNext = false;
  bool _loadingPrev = false;

  final ValueNotifier<double> _bottomOverscroll = ValueNotifier(0.0);
  final ValueNotifier<double> _topOverscroll = ValueNotifier(0.0);

  static const double _kThresholdDesktop = 200.0;
  static const double _kThresholdMobile = 150.0;

  static bool get _isDesktop =>
      defaultTargetPlatform == TargetPlatform.macOS ||
          defaultTargetPlatform == TargetPlatform.windows ||
          defaultTargetPlatform == TargetPlatform.linux;

  double get _kThreshold => _isDesktop ? _kThresholdDesktop : _kThresholdMobile;
  static const Duration _fadeDuration = Duration(milliseconds: 220);

  @override
  void initState() {
    super.initState();
    _scrollController = ScrollController();
    _scrollController.addListener(_onScroll);
    _fadeCtrl =
        AnimationController(vsync: this, duration: _fadeDuration, value: 1.0);
  }

  @override
  void dispose() {
    _scrollController.removeListener(_onScroll);
    _scrollController.dispose();
    _fadeCtrl.dispose();
    _bottomOverscroll.dispose();
    _topOverscroll.dispose();
    super.dispose();
  }

  Future<void> _replaceWith(PartFullInfo info, {required bool toEnd}) async {
    await _fadeCtrl.reverse();
    if (!mounted) return;
    setState(() =>
    _parts
      ..clear()
      ..add(info));
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!_scrollController.hasClients) return;
      _scrollController.jumpTo(
        toEnd ? _scrollController.position.maxScrollExtent : 0,
      );
    });
    _fadeCtrl.forward();
  }

  void _onScroll() {
    if (!_scrollController.hasClients) return;
    final pos = _scrollController.position;

    final bottomOS = (pos.pixels - pos.maxScrollExtent).clamp(
        0.0, double.infinity);
    final topOS = (pos.minScrollExtent - pos.pixels).clamp(
        0.0, double.infinity);

    _bottomOverscroll.value = bottomOS;
    _topOverscroll.value = topOS;

    if (bottomOS >= _kThreshold && !_loadingNext) _loadNext();
    if (topOS >= _kThreshold && !_loadingPrev) _loadPrev();
  }

  StoryBundle? _bundle() =>
      context
          .read<StoryBloc>()
          .state
          .bundles[widget.storyId];

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
      final info = await sl<AppApiDataSource>().getFullPartInfo(
        storyId: widget.storyId,
        partId: bundle.parts[idx + 1].partId,
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
      final info = await sl<AppApiDataSource>().getFullPartInfo(
        storyId: widget.storyId,
        partId: bundle.parts[idx - 1].partId,
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
    context.read<PartBloc>().add(PartDataProvided(info));
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
                    body: Center(
                      child: Text(
                          'Failed: ${(partState as PartError).message}'),
                    ),
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
                    panelWidth: MediaQuery
                        .of(context)
                        .size
                        .width / 4,
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
                                    child: _PartDivider(
                                        title: _parts[i].part.title),
                                  ),
                                SliverToBoxAdapter(
                                  child: Align(
                                    alignment: Alignment.topCenter,
                                    child: ConstrainedBox(
                                      constraints: BoxConstraints(
                                        maxWidth: MediaQuery
                                            .of(context)
                                            .size
                                            .width < 900
                                            ? double.infinity
                                            : MediaQuery
                                            .of(context)
                                            .size
                                            .width / 1.6,
                                        minHeight: i == 0
                                            ? MediaQuery
                                            .sizeOf(context)
                                            .height
                                            : 0,
                                      ),
                                      child: Container(
                                        decoration: BoxDecoration(
                                          color: AppPalette.surfaceAlt,
                                          image: const DecorationImage(
                                            repeat: ImageRepeat.repeat,
                                            image: AssetImage(
                                                "assets/images/texture_5.png"),
                                            fit: BoxFit.none,
                                            opacity: 0.1,
                                          ),
                                          boxShadow: [
                                            BoxShadow(
                                              color: Colors.black.withOpacity(
                                                  0.25),
                                              blurRadius: 40,
                                            ),
                                          ],
                                        ),
                                        alignment: Alignment.topCenter,
                                        child: PartContent(
                                          storyId: widget.storyId,
                                          info: _parts[i],
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
                              child: _PeekBar(
                                overscroll: _topOverscroll,
                                threshold: _kThreshold,
                                title: prevTitle,
                                loading: _loadingPrev,
                                direction: _PeekDirection.top,
                            ),
                          ),
                          if (nextTitle != null)
                            Positioned(
                              bottom: 0,
                              left: 0,
                              right: 0,
                              child: _PeekBar(
                                overscroll: _bottomOverscroll,
                                threshold: _kThreshold,
                                title: nextTitle,
                                loading: _loadingNext,
                                direction: _PeekDirection.bottom,
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

// ── Part divider between loaded parts ─────────────────────────────────────────

class _PartDivider extends StatelessWidget {
  const _PartDivider({required this.title});

  final String title;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 40),
      child: Row(
        children: [
          const Expanded(child: Divider()),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Text(
              title,
              style: Theme
                  .of(context)
                  .textTheme
                  .labelMedium
                  ?.copyWith(
                color: AppPalette.primaryLight,
                fontFamily: 'Courier New',
              ),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ),
          const Expanded(child: Divider()),
        ],
      ),
    );
  }
}

// ── Overscroll peek bar ────────────────────────────────────────────────────────

enum _PeekDirection { top, bottom }

class _PeekBar extends StatelessWidget {
  const _PeekBar({
    super.key,
    required this.overscroll,
    required this.threshold,
    required this.title,
    required this.loading,
    required this.direction,
  });

  final ValueNotifier<double> overscroll;
  final double threshold;
  final String title;
  final bool loading;
  final _PeekDirection direction;

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<double>(
      valueListenable: overscroll,
      builder: (context, os, _) {
        final h = (os * 0.5).clamp(0.0, 72.0);
        if (h < 8) return const SizedBox.shrink();
        final progress = (os / threshold).clamp(0.0, 1.0);
        final isTop = direction == _PeekDirection.top;

        final row = Row(
          children: [
            Icon(
              isTop ? Icons.arrow_upward : Icons.arrow_downward,
              color: AppPalette.primary,
              size: 14,
            ),
            const SizedBox(width: 8),
            Expanded(
              child: Text(
                title,
                style: Theme
                    .of(context)
                    .textTheme
                    .labelSmall
                    ?.copyWith(
                  color: AppPalette.primary,
                  fontFamily: 'Courier New',
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ),
            if (loading)
              const SizedBox(
                width: 12,
                height: 12,
                child: CircularProgressIndicator(strokeWidth: 1.5),
              ),
          ],
        );

        final bar = LinearProgressIndicator(
          value: progress,
          backgroundColor: AppPalette.primaryLight.withOpacity(0.15),
          color: AppPalette.primary,
          minHeight: 2,
        );

        return ClipRect(
          child: SizedBox(
            height: h,
            child: OverflowBox(
              minHeight: 0,
              maxHeight: double.infinity,
              alignment: isTop ? Alignment.bottomCenter : Alignment.topCenter,
              child: Container(
                color: AppPalette.surfaceAlt.withOpacity(0.95),
                padding: const EdgeInsets.symmetric(
                    horizontal: 16, vertical: 6),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: isTop
                      ? [row, const SizedBox(height: 4), bar]
                      : [bar, const SizedBox(height: 4), row],
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}

class PartContent extends StatelessWidget {
  const PartContent({super.key, required this.storyId, required this.info});

  final int storyId;
  final PartFullInfo info;

  @override
  Widget build(BuildContext context) {
    List<Widget> partImages = [];

    if (info.image != null) {
      if (info.image!.path != null) {
        partImages.add(
          LocalImage.relative(
            storageRoot: "/Users/meme/Desktop/storage",
            storyWattId: context
                .read<StoryBloc>()
                .state
                .bundles[storyId]!
                .story
                .wattId,
            relativePath: info.image!.path!,
            width: double.infinity,
            // height: 220,
            fit: BoxFit.contain,
          ),
        );
      } else if (info.image!.url != null) {
        partImages.add(Image.network(info.image!.url!, fit: BoxFit.contain));
      }
    }

    if (info.video != null) {
      partImages.add(
        LocalVideo.relative(
          storageRoot: "/Users/meme/Desktop/storage",
          storyWattId: context
              .read<StoryBloc>()
              .state
              .bundles[storyId]!
              .story
              .wattId,
          relativePath: info.video!.path!, // e.g. "media/clip.mp4"
          // width: double.infinity,
          // borderRadius: BorderRadius.circular(5),
          // autoPlay: false, // set true if you want autoplay
          // loop: true,
          // muted: true,
        ),
      );
    }

    return Padding(
      padding: EdgeInsets.symmetric(
        horizontal: MediaQuery
            .of(context)
            .size
            .width * 0.03,
        vertical: 30,
      ),
      child: Column(
        // mainAxisAlignment: MainAxisAlignment.start,
        // mainAxisSize: MainAxisSize.max,
        children: [
          // images
          if (partImages.isNotEmpty) PartImages(partImages: partImages),

          SizedBox(height: 40),

          // title
          Text(
            info.part.title,
            style: Theme.of(context).textTheme.titleLarge?.copyWith(
              color: Colors.black,
              fontFamily: 'Courier New',
            ),
          ),

          SizedBox(height: 20),

          // votes
          Row(
            mainAxisSize: MainAxisSize.min,

            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            spacing: 7,
            children: [
              Text(
                "${info.part.votes}",
                textAlign: TextAlign.center,
                // remove extra top/bottom height from the font
                strutStyle: const StrutStyle(
                  forceStrutHeight: true,
                  height: 0.1,
                  leading: 0,
                ),
                style: Theme.of(context).textTheme.labelLarge?.copyWith(
                  color: AppPalette.primary,
                  fontFamily: 'Courier New',
                  fontSize: 18,
                  fontWeight: FontWeight.w600,
                  height: 1.0, // keep line height tight
                ),
              ),
              SizedBox(
                width: 18,
                height: 18,
                child: Center(
                  child: SvgPicture.asset(
                    "assets/icons/star_fill_icon.svg",
                    color: AppPalette.primary,
                  ),
                ),
              ),
            ],
          ),
          SizedBox(height: 20),

          Container(
            height: 2,
            width: MediaQuery.of(context).size.width * 0.3,

            decoration: ShapeDecoration(
              color: AppPalette.primaryLight,
              shape: BeveledRectangleBorder(
                borderRadius: BorderRadius.circular(150),
              ),
            ),
          ),

          SizedBox(height: 20),

          // ...info.paragraphs.map(
          //   (p) => Html(
          //     data: p.content,
          //     style: {
          //       "p": Style(
          //         direction: p.direction.toTextDirection,
          //         color: Colors.black,
          //         fontSize: FontSize.larger,
          //         // fontFamily: "Courier New",
          //         lineHeight: LineHeight.em(1.4),
          //       ),
          //     },
          //   ),
          // ),
          ParagraphsColumn(info: info, storyId: storyId),
          SizedBox(height: 40),
        ],
      ),
    );
  }
}

class ParagraphsColumn extends StatefulWidget {
  const ParagraphsColumn({
    super.key,
    required this.info,
    required this.storyId,
  });

  final PartFullInfo info;
  final int storyId;

  @override
  State<ParagraphsColumn> createState() => _ParagraphsColumnState();
}

class _ParagraphsColumnState extends State<ParagraphsColumn> {
  final Map<String, GlobalKey> _paraKeys = {};

  GlobalKey _keyFor(String id) => _paraKeys.putIfAbsent(id, () => GlobalKey());

  @override
  void initState() {
    super.initState();
    // Jump after first layout, no animation.
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final b = context.read<StoryBloc>().state.bundles[widget.storyId];
      if (b == null) return;
      // only scroll if this is the current part
      if (b.currentPart?.partId != widget.info.part.partId) return;

      final targetId = b.storyProgress.lastParagraphId;
      if (targetId == null) return;

      final ctx = _keyFor("$targetId").currentContext;
      // print("target id: ${targetId}");

      if (ctx != null) {
        Scrollable.ensureVisible(
          ctx,
          duration: Duration(milliseconds: 500),
          alignment: 0.1,
        );
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final info = widget.info;
    final b = context
        .read<StoryBloc>()
        .state
        .bundles[widget.storyId];
    if (b == null) return const SizedBox.shrink();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: List.generate(info.paragraphs.length, (i) {
        final p = info.paragraphs[i];
        final hasComments = p.commentsCount > 0;

        Widget content = Html(
          data: p.content,
          style: {
            "p": AppTheme.paragraphsStyle.copyWith(
              direction: p.direction.toTextDirection,
            ),
          },
        );

        if (p.contentType == ContentType.image && p.media?.path != null) {
          content = ConstrainedBox(
            constraints: BoxConstraints(
              maxHeight: MediaQuery.of(context).size.height * 0.7,
            ),
            child: LocalImage.relative(
              storageRoot: "/Users/meme/Desktop/storage",
              storyWattId: b.story.wattId,
              relativePath: p.media!.path!,
              width: double.infinity,
            ),
          );
        }

        if (p.contentType == ContentType.link ||
            p.contentType == ContentType.video ||
            (p.contentType == ContentType.image && p.media?.path == null)) {
          content = GestureDetector(
            onTap: () async {
              final url = Uri.parse('https://www.google.de/');
              if (await canLaunchUrl(url)) {
                await launchUrl(url, mode: LaunchMode.externalApplication);
              }
            },
            child: const Text('Open', style: TextStyle(color: Colors.blue)),
          );
        }

        return KeyedSubtree(
          key: _keyFor("${p.paragraphId}"),
          child: Padding(
            padding: const EdgeInsets.only(bottom: 16),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                CommentIcon(
                  count: p.commentsCount,
                  visible: hasComments,
                  onTap: () => context.read<PartSidePanelCubit>().changeContent(
                    PartSidePanelCommentsCubit(
                      storyId: widget.storyId,
                      paragraph: p,
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(child: content),
              ],
            ),
          ),
        );
      }),
    );
  }
}

class LocalVideo extends StatefulWidget {
  const LocalVideo({super.key, required this.absolutePath, this.fit});

  factory LocalVideo.relative({
    Key? key,
    required String storageRoot,
    required String storyWattId,
    required String relativePath,
    BoxFit? fit,
  }) => LocalVideo(
    key: key,
    absolutePath: path.join(storageRoot, storyWattId, relativePath),
    fit: fit,
  );

  final String absolutePath;
  final BoxFit? fit;

  @override
  State<LocalVideo> createState() => _LocalVideoState();
}

class _LocalVideoState extends State<LocalVideo> {
  late final VideoPlayerController _c;
  late final Future<void> _init;

  @override
  void initState() {
    super.initState();
    _c = VideoPlayerController.file(File(widget.absolutePath));
    _init = _c.initialize().then((_) => _c.setLooping(true));
  }

  @override
  void dispose() {
    _c.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder(
      future: _init,
      builder: (context, snap) {
        if (snap.connectionState != ConnectionState.done) {
          return const Center(child: CircularProgressIndicator());
        }
        if (snap.hasError) {
          return const Center(child: Icon(Icons.broken_image_outlined));
        }
        return GestureDetector(
          onTap: () => _c.value.isPlaying ? _c.pause() : _c.play(),
          child: AspectRatio(
            aspectRatio: _c.value.aspectRatio == 0
                ? 16 / 9
                : _c.value.aspectRatio,
            child: Stack(
              alignment: Alignment.bottomCenter,
              children: [
                FittedBox(
                  fit: widget.fit ?? BoxFit.contain,
                  child: SizedBox(
                    width: _c.value.size.width,
                    height: _c.value.size.height,
                    child: VideoPlayer(_c),
                  ),
                ),
                VideoProgressIndicator(_c, allowScrubbing: true),
              ],
            ),
          ),
        );
      },
    );
  }
}
