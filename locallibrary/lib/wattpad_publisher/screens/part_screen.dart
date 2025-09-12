import 'dart:io';

import 'package:carousel_slider/carousel_slider.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_html/flutter_html.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:locallibrary/wattpad_publisher/bloc/story_bloc.dart';
import 'package:locallibrary/wattpad_publisher/cubit/part_side_panel_cubit.dart';
import 'package:locallibrary/wattpad_publisher/models/models.dart';
import 'package:locallibrary/wattpad_publisher/models/server_models.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:url_launcher_macos/url_launcher_macos.dart';
import 'package:video_player/video_player.dart';

import '../../core/exstentions/image.dart';
import '../../core/theme/app_palette.dart';
import '../../core/theme/theme.dart';
import '../../dependency_ingection.dart';
import '../bloc/comments_bloc.dart';
import '../bloc/part_bloc.dart';
import '../widgets/comment_icon.dart';
import '../widgets/part_image_view.dart';
import '../widgets/part_sidepanel.dart';

import 'package:path/path.dart' as path;

class PartScreen extends StatelessWidget {
  final int storyId;
  final int partId;

  const PartScreen({super.key, required this.storyId, required this.partId});

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider(
          create: (_) =>
              sl<PartBloc>()
                ..add(PartFetchRequested(storyId: storyId, partId: partId)),
        ),

        // BlocProvider(create: (ctx) => PartSidePanelCubit()),
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
  _PartView({super.key, required this.storyId});

  final CarouselSliderController buttonCarouselController =
      CarouselSliderController();

  final int storyId;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        // keep the panel widget stable
        child: SidePanelScaffold(
          storyId: storyId,
          panelWidth: MediaQuery.of(context).size.width / 4,
          // tweak to match the mock
          dockSize: 40,

          // ⬇️ only this part rebuilds on new PartBloc state
          content: CustomScrollView(
            slivers: [
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.all(0),
                  child: Align(
                    alignment: Alignment.topCenter,
                    child: ConstrainedBox(
                      constraints: BoxConstraints(
                        maxWidth:
                            MediaQuery.of(context).size.width /
                            1.6, // controls the size of the paper
                        minHeight: MediaQuery.sizeOf(context).height,
                      ),
                      child: Container(
                        // height: 120,
                        decoration: BoxDecoration(
                          color: AppPalette.surfaceAlt,
                          image: DecorationImage(
                            image: AssetImage("assets/images/texture_5.png"),
                            fit: BoxFit.fill,
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
                        child: BlocBuilder<PartBloc, PartState>(
                          builder: (context, state) {
                            if (state is PartInitial || state is PartLoading) {
                              return const Center(
                                child: CircularProgressIndicator(),
                              );
                            }
                            if (state is PartError) {
                              return Center(
                                child: Text('Failed: ${state.message}'),
                              );
                            }
                            final info = (state as PartLoaded).info;

                            return PartContent(storyId: storyId, info: info);
                          },
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
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
          Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: List.generate(info.paragraphs.length, (i) {
              final p = info.paragraphs[i];
              final comments = p.commentsCount;
              final hasComments = comments > 0;

              Widget content = Html(
                data: p.content,
                style: {
                  "p": AppTheme.paragraphsStyle.copyWith(
                    direction: p.direction.toTextDirection,
                  ),
                },
              );

              if (p.contentType == ContentType.image) {
                content = ConstrainedBox(
                  constraints: BoxConstraints(
                    maxHeight: MediaQuery.of(context).size.height * 0.7,
                  ),
                  child: LocalImage.relative(
                    storageRoot: "/Users/meme/Desktop/storage",
                    storyWattId: context
                        .read<StoryBloc>()
                        .state
                        .bundles[storyId]!
                        .story
                        .wattId,
                    relativePath: p.media!.path!,
                    width: double.infinity,
                  ),
                );
              }

              if (p.contentType == ContentType.video) {
                // todo: handle videos
              }

              if (p.contentType == ContentType.link ||
                  ((p.contentType == ContentType.video ) ||
                  (p.contentType == ContentType.image) && p.media!.path == null)) {
                content = RichText(
                  text: TextSpan(
                    children: [
                      TextSpan(
                        text: p.contentType.name,
                        style: TextStyle(color: Colors.blue),
                        recognizer: TapGestureRecognizer()
                          ..onTap = () async {
                            const url = 'https://www.google.de/';
                            if (await canLaunchUrl(Uri.parse(url))) {
                              await launchUrl(Uri.parse(url), mode: LaunchMode.externalApplication);
                            } else {
                              throw 'Could not launch $url';
                            }
                          },
                      ),
                    ],
                  ),
                );
              }

              return IntrinsicHeight(
                child: Padding(
                  padding: const EdgeInsets.only(bottom: 16),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    // children get full height
                    children: [
                      // LEFT: comment icon with number inside (clickable)
                      Padding(
                        padding: const EdgeInsets.only(bottom: 13),
                        child: Align(
                          alignment: Alignment.bottomCenter,
                          child: CommentIcon(
                            count: comments,
                            visible: hasComments,
                            onTap: () {
                              final ctxCubit = context
                                  .read<PartSidePanelCubit>();
                              debugPrint(
                                '[PartScreen] paragraph icon tap storyId=$storyId paragraphId=${p.paragraphId} | cubitId=${identityHashCode(ctxCubit)}',
                              );
                              ctxCubit.changeContent(
                                PartSidePanelCommentsCubit(
                                  storyId: storyId,
                                  paragraph: p,
                                ),
                              );
                            },
                          ),
                        ),
                      ),
                      const SizedBox(width: 8),

                      // RIGHT: the paragraph
                      Expanded(child: content),
                    ],
                  ),
                ),
              );
            }),
          ),
          SizedBox(height: 40),
        ],
      ),
    );
  }
}

// class LocalVideo extends StatefulWidget {
//   const LocalVideo({
//     super.key,
//     required this.absolutePath,
//     this.width,
//     this.height,
//     this.borderRadius,
//     this.autoPlay = false,
//     this.loop = true,
//     this.muted = true,
//   });
//
//   factory LocalVideo.relative({
//     Key? key,
//     required String storageRoot,
//     required String storyWattId,
//     required String relativePath, // e.g. "media/clip.mp4"
//     double? width,
//     double? height,
//     BorderRadius? borderRadius,
//     bool autoPlay = false,
//     bool loop = true,
//     bool muted = true,
//   }) => LocalVideo(
//     key: key,
//     absolutePath: path.join(storageRoot, storyWattId, relativePath),
//     width: width,
//     height: height,
//     borderRadius: borderRadius,
//     autoPlay: autoPlay,
//     loop: loop,
//     muted: muted,
//   );
//
//   final String absolutePath;
//   final double? width;
//   final double? height;
//   final BorderRadius? borderRadius;
//   final bool autoPlay;
//   final bool loop;
//   final bool muted;
//
//   @override
//   State<LocalVideo> createState() => _LocalVideoState();
// }
//
// class _LocalVideoState extends State<LocalVideo> {
//   late final VideoPlayerController _ctrl;
//   late final Future<void> _init;
//
//   @override
//   void initState() {
//     super.initState();
//     _ctrl = VideoPlayerController.file(File(widget.absolutePath));
//     _init = _ctrl.initialize().then((_) {
//       _ctrl.setLooping(widget.loop);
//       if (widget.muted) _ctrl.setVolume(0);
//       if (widget.autoPlay) _ctrl.play();
//       setState(() {});
//     });
//   }
//
//   @override
//   void dispose() {
//     _ctrl.dispose();
//     super.dispose();
//   }
//
//   @override
//   Widget build(BuildContext context) {
//     Widget body = FutureBuilder(
//       future: _init,
//       builder: (context, snap) {
//         if (snap.connectionState != ConnectionState.done) {
//           return const Center(child: CircularProgressIndicator());
//         }
//         if (snap.hasError) {
//           print(snap.error);
//           return const Center(child: Icon(Icons.broken_image_outlined));
//         }
//         return Stack(
//           alignment: Alignment.bottomCenter,
//           children: [
//             AspectRatio(
//               aspectRatio: _ctrl.value.aspectRatio == 0
//                   ? 16 / 9
//                   : _ctrl.value.aspectRatio,
//               child: VideoPlayer(_ctrl),
//             ),
//             // Tap-to-play/pause overlay
//             Positioned.fill(
//               child: Material(
//                 color: Colors.transparent,
//                 child: InkWell(
//                   onTap: () =>
//                       _ctrl.value.isPlaying ? _ctrl.pause() : _ctrl.play(),
//                   child: AnimatedOpacity(
//                     duration: const Duration(milliseconds: 180),
//                     opacity: _ctrl.value.isPlaying ? 0.0 : 0.9,
//                     child: const Center(
//                       child: Icon(Icons.play_circle_fill, size: 64),
//                     ),
//                   ),
//                 ),
//               ),
//             ),
//             VideoProgressIndicator(_ctrl, allowScrubbing: true),
//           ],
//         );
//       },
//     );
//
//     if (widget.borderRadius != null) {
//       body = ClipRRect(borderRadius: widget.borderRadius!, child: body);
//     }
//
//     return SizedBox(width: widget.width, height: widget.height, child: body);
//   }
// }

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
