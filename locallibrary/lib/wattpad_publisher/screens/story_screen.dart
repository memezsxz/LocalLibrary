import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:locallibrary/wattpad_publisher/cubit/navigation_cubit.dart';

import '../../core/theme/app_palette.dart';
import '../../dependency_ingection.dart';
import '../bloc/story_bloc.dart';
import '../widgets/story_description_bottom.dart';
import '../widgets/story_description_top.dart';

class StoryScreen extends StatelessWidget {
  final int storyId;

  const StoryScreen({super.key, required this.storyId});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => StoryBloc(api: sl())..add(StoryRequested(storyId)),
      child: Scaffold(body: _StoryView(storyId: storyId)),
    );
  }
}

class _StoryView extends StatelessWidget {
  const _StoryView({required this.storyId});

  final int storyId;

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    final isMobile = size.width < 600;
    final marginW = isMobile ? 16.0 : size.width / 7;
    final marginH = isMobile ? 12.0 : size.width / 20;
    final topSize = size.height / 1.5;

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

        if (isMobile) {
          return SafeArea(
            child: Scaffold(
              body: Stack(
                children: [
                  SingleChildScrollView(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
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
                          child: StoryDescriptionTop(
                            margin: EdgeInsets.fromLTRB(
                              marginW,
                              marginH + 56,
                              marginW,
                              marginH,
                            ),
                            story: story,
                          ),
                        ),
                        Container(
                          color: AppPalette.surface,
                          child: ContentContainer(
                            margin: EdgeInsets.symmetric(
                              vertical: marginH,
                              horizontal: marginW,
                            ),
                            child: StoryDescriptionBottom(storyBundle: story),
                          ),
                        ),
                      ],
                    ),
                  ),
                  Positioned(
                    top: 16,
                    left: 16,
                    child: FloatingActionButton(
                      heroTag: 'back',
                      mini: true,
                      onPressed: () => context.read<NavigationCubit>().pop(),
                      child: const Icon(Icons.arrow_back),
                    ),
                  ),
                ],
              ),
            ),
          );
        }

        return SafeArea(
          child: Scaffold(
            body: Stack(
              children: [
                SingleChildScrollView(
                  clipBehavior: Clip.none,
                  child: Container(
                    color: Colors.white,
                    child: Stack(
                      children: [
                        Container(
                          margin: EdgeInsets.only(top: topSize),
                          width: double.infinity,
                          decoration: const BoxDecoration(
                            color: AppPalette.surface,
                          ),
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
                ),
                Positioned(
                  top: 16,
                  left: 16,
                  child: FloatingActionButton(
                    heroTag: 'back',
                    mini: true,
                    onPressed: () => context.read<NavigationCubit>().pop(),
                    child: const Icon(Icons.arrow_back),
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
