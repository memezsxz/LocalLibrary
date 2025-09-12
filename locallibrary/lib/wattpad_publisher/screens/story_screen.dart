import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import '../../core/theme/app_palette.dart';
import '../../dependency_ingection.dart';
import '../../window_service.dart';
import '../bloc/story_bloc.dart';
import '../widgets/story_description_bottom.dart';
import '../widgets/story_description_top.dart';

class StoryWindowLauncherPage extends StatefulWidget {
  final int storyId;

  const StoryWindowLauncherPage({required this.storyId});

  @override
  State<StoryWindowLauncherPage> createState() =>
      StoryWindowLauncherPageState();
}

class StoryWindowLauncherPageState extends State<StoryWindowLauncherPage> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      await AppWindows.openStoryWindow(storyId: widget.storyId);
      if (mounted) context.pop(); // return to whatever was showing (Home)
    });
  }

  @override
  Widget build(BuildContext context) => const SizedBox.shrink();
}

class StoryScreen extends StatelessWidget {
  final int storyId;

  const StoryScreen({super.key, required this.storyId});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) =>
          sl<StoryBloc>()
            ..add(StoryRequested(storyId)),
      child: Scaffold(body: _StoryView(storyId: storyId)),
    );
  }
}

class _StoryView extends StatelessWidget {
  const _StoryView({required this.storyId});

  final int storyId;

  @override
  Widget build(BuildContext context) {
    final marginW = MediaQuery.of(context).size.width / 7;
    final marginH = MediaQuery.of(context).size.width / 20;
    final topSize = MediaQuery.of(context).size.height / 1.5;

    return BlocBuilder<StoryBloc, StoryState>(
      builder: (context, state) {
        if (state is StoryLoading || state is StoryInitial) {
          return const Center(child: CircularProgressIndicator());
        }

        if (state is StoryError) {
          return Padding(
            padding: const EdgeInsets.all(16),
            child: Text('Failed to load: ${state.message}'),
          );
        }

        final story = (state as StoryLoaded).bundle;

        return SingleChildScrollView(
          clipBehavior: Clip.none,
          child: Container(
            color: Colors.white,
            child: Stack(
              children: [
                Container(
                  margin: EdgeInsets.only(top: topSize),
                  width: double.infinity,
                  decoration: const BoxDecoration(color: AppPalette.surface),
                  child: ContentContainer(
                    margin: EdgeInsets.symmetric(
                      vertical: marginH,
                      horizontal: marginW,
                    ),
                    child: StoryDescriptionBottom(storyBundle: story),
                  ),
                ),

                // Top card with drop shadow
                Container(
                  decoration: BoxDecoration(
                    color: Colors.white,
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.25),
                        blurRadius: 43,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  width: double.infinity,
                  height: topSize,
                  child: StoryDescriptionTop(
                    margin: EdgeInsets.symmetric(
                      vertical: marginH,
                      horizontal: marginW,
                    ),
                    story: story,
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}

// class StoryScreen extends StatelessWidget {
//   final int storyId;
//
//   StoryScreen({super.key, required this.storyId})
//     : _future = sl<AppApiDataSource>().getFullStoryInfo(2);
//
//   final Future<StoryBundle> _future;
//
//   @override
//   Widget build(BuildContext context) {
//     final marginW = MediaQuery.of(context).size.width / 7;
//     final marginH = MediaQuery.of(context).size.width / 20;
//     final topSize = MediaQuery.of(context).size.height / 1.5;
//
//     return FutureBuilder<StoryBundle>(
//       future: _future,
//       builder: (context, snap) {
//         if (snap.connectionState == ConnectionState.waiting) {
//           return const Center(child: CircularProgressIndicator());
//         }
//         if (snap.hasError) {
//           print(snap.error);
//           return Padding(
//             padding: const EdgeInsets.all(16),
//             child: Text('Failed to load: ${snap.error}'),
//           );
//         }
//         final story = snap.data!;
//
//         return SingleChildScrollView(
//           clipBehavior: Clip.none,
//           child: Container(
//             color: Colors.white,
//             child: Stack(
//               children: [
//                 // description container
//                 Container(
//                   margin: EdgeInsets.only(top: topSize),
//                   width: double.infinity,
//                   decoration: BoxDecoration(color: AppPalette.surface),
//                   child: ContentContainer(
//                     margin: EdgeInsets.symmetric(
//                       vertical: marginH,
//                       horizontal: marginW,
//                     ),
//
//                     child: StoryDescriptionBottom(storyBundle: story),
//                   ),
//                 ),
//                 Container(
//                   decoration: BoxDecoration(
//                     color: Colors.white,
//                     boxShadow: [
//                       BoxShadow(
//                         color: Colors.black.withOpacity(0.25),
//                         blurRadius: 43,
//                         offset: Offset(0, 4),
//                         spreadRadius: 0,
//                       ),
//                     ],
//                   ),
//                   width: double.infinity,
//                   height: topSize,
//                   child: StoryDescriptionTop(
//                     margin: EdgeInsets.symmetric(
//                       vertical: marginH,
//                       horizontal: marginW,
//                     ),
//                     story: story,
//                   ),
//                 ),
//               ],
//             ),
//           ),
//         );
//       },
//     );
//   }
// }

class ContentContainer extends StatelessWidget {
  const ContentContainer({
    super.key,
    required this.margin,
    this.width,
    this.height,
    this.color,
    required this.child,
  });

  final EdgeInsetsGeometry margin;
  final double? width;
  final double? height;
  final Color? color;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: margin,
      child: Container(
        width: width,
        height: height,
        color: color,
        child: child,
      ),
    );
  }
}
