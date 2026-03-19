import 'dart:io';

import 'package:carousel_slider/carousel_slider.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_html/flutter_html.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:locallibrary/wattpad_publisher/bloc/story_bloc.dart';
import 'package:locallibrary/wattpad_publisher/cubit/part_side_panel_cubit.dart';
import 'package:locallibrary/wattpad_publisher/models/models.dart';
import 'package:locallibrary/wattpad_publisher/models/server_models.dart';
import 'package:path/path.dart' as path;
import 'package:url_launcher/url_launcher.dart';
import 'package:video_player/video_player.dart';

import '../../core/commen/widgets/loader.dart';
import '../../core/exstentions/image.dart';
import '../../core/theme/app_palette.dart';
import '../../core/theme/theme.dart';
import '../../dependency_ingection.dart';
import '../bloc/comments_bloc.dart';
import '../bloc/part_bloc.dart';
import '../widgets/comment_icon.dart';
import '../widgets/part_image_view.dart';
import '../widgets/part_sidepanel.dart';

class PartScreen extends StatelessWidget {
  final int storyId;
  final int partId;

  const PartScreen({super.key, required this.storyId, required this.partId});

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider<StoryBloc>(
          create: (_) =>
          sl<StoryBloc>()
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

class _PartView extends StatelessWidget {
  _PartView({required this.storyId});

  final CarouselSliderController buttonCarouselController =
      CarouselSliderController();

  final int storyId;

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<PartBloc, PartState>(
      builder: (context, partState) {
        return BlocBuilder<StoryBloc, StoryState>(
          builder: (context, storyState) {
            final bundle = storyState.bundles[storyId];

            if (partState is PartInitial ||
                partState is PartLoading ||
                bundle == null) {
              return const Scaffold(
                body: Center(child: Loader()),
              );
            }

            if (partState is PartError) {
              return Scaffold(
                body: Center(
                  child: Text('Failed: ${(partState as PartError).message}'),
                ),
              );
            }

            final info = (partState as PartLoaded).info;

            return Scaffold(
              backgroundColor: Colors.white,
              body: SafeArea(
                child: SidePanelScaffold(
                  storyId: storyId,
                  panelWidth: MediaQuery
                      .of(context)
                      .size
                      .width / 4,
                  dockSize: 40,
                  content: CustomScrollView(
                    slivers: [
                      SliverToBoxAdapter(
                        child: Align(
                          alignment: Alignment.topCenter,
                          child: ConstrainedBox(
                            constraints: BoxConstraints(
                              maxWidth: MediaQuery
                                  .of(context)
                                  .size
                                  .width / 1.6,
                              minHeight: MediaQuery
                                  .sizeOf(context)
                                  .height,
                            ),
                            child: Container(
                              decoration: BoxDecoration(
                                color: AppPalette.surfaceAlt,
                                image: DecorationImage(
                                  repeat: ImageRepeat.repeat,
                                  image: AssetImage(
                                    "assets/images/texture_5.png",
                                  ),
                                  fit: BoxFit.none,
                                  opacity: 0.1,
                                ),
                                boxShadow: [
                                  BoxShadow(
                                    color: Colors.black.withOpacity(0.25),
                                    blurRadius: 40,
                                  ),
                                ],
                              ),
                              alignment: Alignment.topCenter,
                              child: PartContent(storyId: storyId, info: info),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            );
          },
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
            fit: BoxFit.fitWidth,
          ),
        );
      } else if (info.image!.url != null) {
        partImages.add(Image.network(info.image!.url!, fit: BoxFit.fitWidth));
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
      padding: const EdgeInsets.symmetric(horizontal: 30, vertical: 30),
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
