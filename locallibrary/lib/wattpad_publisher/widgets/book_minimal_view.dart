import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_inner_shadow/flutter_inner_shadow.dart';
import 'package:locallibrary/core/theme/app_palette.dart';
import 'package:locallibrary/wattpad_publisher/cubit/navigation_cubit.dart';

import '../../core/exstentions/image.dart';
import '../../dependency_ingection.dart';
import '../datasource.dart';
import '../models/server_models.dart';

class BookMinimalView extends StatefulWidget {
  final int storyId;

  const BookMinimalView({super.key, required this.storyId});

  @override
  State<BookMinimalView> createState() => _BookMinimalViewState();
}

class _BookMinimalViewState extends State<BookMinimalView> {
  late final Future<BookMinimal> _future;

  @override
  void initState() {
    super.initState();
    _future = sl<StoryRemoteDataSource>().fetchMinimal(storyId: widget.storyId);
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<BookMinimal>(
      future: _future,
      builder: (context, snap) {
        if (snap.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }
        if (snap.hasError) {
          return const SizedBox.shrink();
        }

        final book = snap.data!;

        return GestureDetector(
          onTap: () => context.read<NavigationCubit>().push(
            NavigationStoryCubit(storyId: widget.storyId),
          ),
          child: Stack(
            fit: StackFit.expand,
            children: [
              // cover image
              LocalImage.relative(
                storageRoot: "/Users/meme/Desktop/storage",
                storyWattId: book.wattId,
                relativePath: book.image.path!,
                fit: BoxFit.cover,
              ),
              // progress bar overlaid at bottom
              Positioned(
                left: 0,
                right: 0,
                bottom: 0,
                child: Padding(
                  padding: const EdgeInsets.all(5),
                  child: BookProgressBar(progress: 0.5),
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}

class BookProgressBar extends StatelessWidget {
  final double progress;

  const BookProgressBar({super.key, this.progress = 0});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      height: 5,
      child: InnerShadow(
        shadows: [
          Shadow(
            color: Colors.black.withOpacity(0.25),
            blurRadius: 2,
            offset: Offset(0, 1),
          ),
        ],
        child: LinearProgressIndicator(
          color: AppPalette.primaryLight,
          value: progress,
          backgroundColor: AppPalette.primaryExtraLight,
          borderRadius: BorderRadius.all(Radius.circular(2)),
        ),
      ),
    );
  }
}
