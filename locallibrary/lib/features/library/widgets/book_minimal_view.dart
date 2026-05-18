import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:locallibrary/features/library/cubit/navigation_state.dart';

import '../../../core/api/story_api_client.dart';
import '../../../core/extensions/image.dart';
import '../../../core/secrets/app_secrets.dart';
import '../../../dependency_injection.dart';
import '../../story/models/domain/book_cover_model.dart';
import '../cubit/navigation_cubit.dart';
import 'book_progress_bar.dart';

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
    _future = sl<StoryApiClient>().fetchMinimal(widget.storyId);
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
            NavigationStoryState(storyId: widget.storyId),
          ),
          child: Stack(
            fit: StackFit.expand,
            children: [
              // cover image
              LocalImage.relative(
                storageRoot: AppSecrets.storageRoot,
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
