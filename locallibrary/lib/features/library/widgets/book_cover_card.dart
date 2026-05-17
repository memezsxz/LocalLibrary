import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../core/api/story_api_client.dart';
import '../../../core/extensions/image.dart';
import '../../../dependency_injection.dart';
import '../../story/models/domain/book_cover_model.dart';
import '../cubit/navigation_cubit.dart';
import '../cubit/navigation_state.dart';
import 'book_progress_bar.dart';

class BookCoverCard extends StatefulWidget {
  final int storyId;
  final BookMinimal? preloaded;

  const BookCoverCard({super.key, required this.storyId}) : preloaded = null;

  BookCoverCard.fromBook({super.key, required BookMinimal book})
    : storyId = book.storyId,
      preloaded = book;

  @override
  State<BookCoverCard> createState() => _BookCoverCardState();
}

class _BookCoverCardState extends State<BookCoverCard> {
  Future<BookMinimal>? _future;

  @override
  void initState() {
    super.initState();
    if (widget.preloaded == null) {
      _future = sl<StoryApiClient>().fetchMinimal(widget.storyId);
    }
  }

  Widget _buildCard(BuildContext context, BookMinimal book) {
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
  }

  @override
  Widget build(BuildContext context) {
    if (widget.preloaded != null) {
      return _buildCard(context, widget.preloaded!);
    }

    return FutureBuilder<BookMinimal>(
      future: _future,
      builder: (context, snap) {
        if (snap.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }
        if (snap.hasError) return const SizedBox.shrink();
        return _buildCard(context, snap.data!);
      },
    );
  }
}
