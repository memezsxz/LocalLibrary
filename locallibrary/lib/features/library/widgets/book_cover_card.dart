import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../core/datasource.dart';
import '../../../core/extensions/image.dart';
import '../../../dependency_injection.dart';
import '../../story/models/story_dto.dart';
import '../cubit/navigation_cubit.dart';
import '../cubit/navigation_state.dart';
import 'book_progress_bar.dart';

class BookCoverCard extends StatefulWidget {
  final int storyId;

  const BookCoverCard({super.key, required this.storyId});

  @override
  State<BookCoverCard> createState() => _BookCoverCardState();
}

class _BookCoverCardState extends State<BookCoverCard> {
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
            NavigationStoryState(storyId: widget.storyId),
          ),
          child: Stack(
            fit: StackFit.expand,
            children: [
              LocalImage.relative(
                storageRoot: "/Users/meme/Desktop/storage",
                storyWattId: book.wattId,
                relativePath: book.image.path!,
                fit: BoxFit.cover,
              ),
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
