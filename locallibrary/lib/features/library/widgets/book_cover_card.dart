import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../core/api/story_api_client.dart';
import '../../../core/extensions/image.dart';
import '../../../core/secrets/app_secrets.dart';
import '../../../dependency_injection.dart';
import '../../story/models/domain/book_cover_model.dart';
import '../cubit/navigation_cubit.dart';
import '../cubit/navigation_state.dart';
import 'book_progress_bar.dart';

class BookCoverCard extends StatefulWidget {
  final int storyId;
  final BookMinimal? preloaded;
  final VoidCallback? onTap;

  const BookCoverCard({super.key, required this.storyId, this.onTap})
    : preloaded = null;

  BookCoverCard.fromBook({super.key, required BookMinimal book, this.onTap})
    : storyId = book.storyId,
      preloaded = book;

  @override
  State<BookCoverCard> createState() => _BookCoverCardState();
}

class _BookCoverCardState extends State<BookCoverCard> {
  Future<BookMinimal>? _future;
  bool _hovering = false;

  @override
  void initState() {
    super.initState();
    if (widget.preloaded == null) {
      _future = sl<StoryApiClient>().fetchMinimal(widget.storyId);
    }
  }

  Widget _buildCard(BuildContext context, BookMinimal book) {
    return MouseRegion(
      onEnter: (_) => setState(() => _hovering = true),
      onExit: (_) => setState(() => _hovering = false),
      child: GestureDetector(
        onTap:
        widget.onTap ??
                () =>
                context.read<NavigationCubit>().push(
                  NavigationStoryState(storyId: widget.storyId),
                ),
        child: AnimatedSlide(
          duration: const Duration(milliseconds: 150),
          curve: Curves.easeOut,
          offset: _hovering ? const Offset(0, -0.02) : Offset.zero,
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 150),
            curve: Curves.easeOut,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(10),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(_hovering ? 0.32 : 0.22),
                  blurRadius: _hovering ? 26 : 16,
                  offset: Offset(0, _hovering ? 14 : 8),
                ),
              ],
            ),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(10),
              child: Stack(
                fit: StackFit.expand,
                children: [
                  LocalImage.relative(
                    storageRoot: AppSecrets.storageRoot,
                    storyWattId: book.wattId,
                    relativePath: book.image.path!,
                    fit: BoxFit.cover,
                  ),
                  Positioned(
                    left: 0,
                    right: 0,
                    bottom: 0,
                    child: Container(
                      padding: const EdgeInsets.fromLTRB(9, 22, 9, 8),
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          begin: Alignment.topCenter,
                          end: Alignment.bottomCenter,
                          colors: [
                            Colors.black.withOpacity(0),
                            Colors.black.withOpacity(0.78),
                          ],
                        ),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(
                            book.title,
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 11.5,
                              fontWeight: FontWeight.w700,
                              height: 1.25,
                            ),
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                          ),
                          // Placeholder — BookMinimal doesn't carry an author
                          // field yet; swap for the real name once it does.
                          Padding(
                            padding: const EdgeInsets.only(top: 1),
                            child: Text(
                              'Unknown author',
                              style: TextStyle(
                                color: Colors.white.withOpacity(0.75),
                                fontSize: 9.5,
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                          if ((book.storyProgress?.progress ?? 0) > 0)
                            Padding(
                              padding: const EdgeInsets.only(top: 6),
                              child: BookProgressBar(
                                progress: book.storyProgress!.progress!,
                              ),
                            ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
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
