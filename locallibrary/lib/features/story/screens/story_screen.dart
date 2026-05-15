import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../core/theme/app_palette.dart';
import '../../../dependency_injection.dart';
import '../../library/cubit/navigation_cubit.dart';
import '../bloc/story_bloc.dart';
import '../widgets/story_footer_section.dart';
import '../widgets/story_header_section.dart';

class StoryScreen extends StatelessWidget {
  final int storyId;

  const StoryScreen({super.key, required this.storyId});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => StoryBloc(api: sl())..add(StoryRequested(storyId)),
      child: _StoryView(storyId: storyId),
    );
  }
}

class _StoryView extends StatelessWidget {
  const _StoryView({required this.storyId});

  final int storyId;

  @override
  Widget build(BuildContext context) {
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

        return StoryLayout(
          topBuilder: (margin) =>
              StoryDescriptionTop(margin: margin, story: story),
          bottom: StoryDescriptionBottom(storyBundle: story),
        );
      },
    );
  }
}

/// Shared two-zone layout scaffold used by [StoryScreen], [ScrapeStoryViewScreen], etc.
///
/// Renders a hero top card (cover + metadata) and a surface-coloured scrollable
/// bottom section. Handles responsive layout, scroll behaviour, drop shadow, and
/// the floating back button — callers only supply content.
///
/// [topBuilder] receives the computed margin so callers can pass it through to
/// [StoryDescriptionTop] (which applies it internally).
/// [bottom] is the raw content widget; the layout wraps it in [ContentContainer].
class StoryLayout extends StatelessWidget {
  const StoryLayout({
    super.key,
    required this.topBuilder,
    required this.bottom,
  });

  final Widget Function(EdgeInsets margin) topBuilder;
  final Widget bottom;

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery
        .of(context)
        .size;
    final isMobile = size.width < 600;
    final marginW = isMobile ? 16.0 : size.width / 7;
    final marginH = isMobile ? 12.0 : size.width / 20;
    final topSize = size.height / 1.5;
    final contentMargin = EdgeInsets.symmetric(
        vertical: marginH, horizontal: marginW);

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
                      child: topBuilder(
                        EdgeInsets.fromLTRB(
                            marginW, marginH + 56, marginW, marginH),
                      ),
                    ),
                    Container(
                      color: AppPalette.surface,
                      child: ContentContainer(
                          margin: contentMargin, child: bottom),
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
                          color: AppPalette.surface),
                      child: ContentContainer(
                          margin: contentMargin, child: bottom),
                    ),
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
                      child: topBuilder(contentMargin),
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