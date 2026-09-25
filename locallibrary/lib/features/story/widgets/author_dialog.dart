import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../core/theme/app_palette.dart';
import '../../library/cubit/navigation_cubit.dart';
import '../../library/cubit/navigation_state.dart';
import '../../library/widgets/book_cover_card.dart';
import '../../story/models/domain/author_model.dart';
import '../../story/models/domain/book_cover_model.dart';
import '../../story/models/enum/book_size.dart';

// ─── Entry point ──────────────────────────────────────────────────────────────

void showAuthorDialog({
  required BuildContext context,
  required Author author,
  required Future<List<BookMinimal>> Function(int limit, int offset)?
  fetchStories,
}) {
  final isMobile = MediaQuery.of(context).size.width < 600;
  final navCubit = context.read<NavigationCubit>();
  final rootNav = Navigator.of(context, rootNavigator: true);

  void onStoryTap(int storyId) {
    rootNav.pop();
    navCubit.push(NavigationStoryState(storyId: storyId));
  }

  if (isMobile) {
    showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      useSafeArea: true,
      useRootNavigator: true,
      backgroundColor: Colors.transparent,
      builder: (_) => DraggableScrollableSheet(
        initialChildSize: 0.85,
        minChildSize: 0.5,
        maxChildSize: 0.95,
        expand: false,
        builder: (_, scrollController) => ClipRRect(
          borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
          child: _AuthorDialogContent(
            author: author,
            fetchStories: fetchStories,
            onStoryTap: onStoryTap,
            scrollController: scrollController,
            isSheet: true,
          ),
        ),
      ),
    );
  } else {
    showDialog<void>(
      context: context,
      barrierDismissible: true,
      builder: (_) => Dialog(
        clipBehavior: Clip.antiAlias,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        child: ConstrainedBox(
          constraints: BoxConstraints(
            maxWidth: MediaQuery.of(context).size.width * 0.5,
            minHeight: MediaQuery.of(context).size.height * 0.7,
            maxHeight: MediaQuery.of(context).size.height * 0.8,
          ),
          child: _AuthorDialogContent(
            author: author,
            fetchStories: fetchStories,
            onStoryTap: onStoryTap,
          ),
        ),
      ),
    );
  }
}

// ─── Content ──────────────────────────────────────────────────────────────────

class _AuthorDialogContent extends StatefulWidget {
  const _AuthorDialogContent({
    required this.author,
    required this.fetchStories,
    required this.onStoryTap,
    this.scrollController,
    this.isSheet = false,
  });

  final Author author;
  final Future<List<BookMinimal>> Function(int limit, int offset)? fetchStories;
  final void Function(int storyId) onStoryTap;
  final ScrollController? scrollController;
  final bool isSheet;

  @override
  State<_AuthorDialogContent> createState() => _AuthorDialogContentState();
}

class _AuthorDialogContentState extends State<_AuthorDialogContent> {
  static const int _pageSize = 20;

  final _scroll = ScrollController();
  final List<BookMinimal> _stories = [];
  int _offset = 0;
  bool _loading = false;
  bool _hasMore = true;
  bool _initialLoaded = false;

  ScrollController get _effectiveScroll => widget.scrollController ?? _scroll;

  @override
  void initState() {
    super.initState();
    _effectiveScroll.addListener(_onScroll);
    _loadMore();
  }

  @override
  void dispose() {
    if (widget.scrollController == null) _scroll.dispose();
    super.dispose();
  }

  void _onScroll() {
    if (_effectiveScroll.position.extentAfter < 400 && !_loading && _hasMore) {
      _loadMore();
    }
  }

  Future<void> _loadMore() async {
    if (_loading || !_hasMore || widget.fetchStories == null) {
      if (!_initialLoaded) setState(() => _initialLoaded = true);
      return;
    }
    setState(() => _loading = true);
    try {
      final page = await widget.fetchStories!(_pageSize, _offset);
      if (!mounted) return;
      setState(() {
        _stories.addAll(page);
        _offset += page.length;
        _hasMore = page.length == _pageSize;
        _initialLoaded = true;
      });
    } catch (_) {
      if (mounted) setState(() => _hasMore = false);
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Material(
      color: context.colors.background,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          if (widget.isSheet)
            Padding(
              padding: const EdgeInsets.only(top: 10, bottom: 4),
              child: Center(
                child: Container(
                  width: 40,
                  height: 4,
                  decoration: BoxDecoration(
                    color: context.colors.primaryLight,
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
              ),
            ),
          _AuthorHeader(author: widget.author),
          const Divider(height: 1),
          Expanded(child: _buildBody()),
        ],
      ),
    );
  }

  Widget _buildBody() {
    if (widget.fetchStories == null) {
      return Center(
        child: Text(
          'Stories not available yet',
          style: TextStyle(color: context.colors.gray),
        ),
      );
    }

    if (!_initialLoaded) {
      return const Center(child: CircularProgressIndicator());
    }

    if (_stories.isEmpty) {
      return Center(
        child: Text(
          'No stories found',
          style: TextStyle(color: context.colors.gray),
        ),
      );
    }

    return GridView.builder(
      controller: _effectiveScroll,
      padding: const EdgeInsets.all(12),
      physics: const AlwaysScrollableScrollPhysics(),
      gridDelegate: SliverGridDelegateWithMaxCrossAxisExtent(
        maxCrossAxisExtent: BookSize.m.maxExtent(),
        childAspectRatio: 0.6,
        crossAxisSpacing: 8,
        mainAxisSpacing: 8,
      ),
      itemCount: _stories.length + (_loading || _hasMore ? 1 : 0),
      itemBuilder: (context, i) {
        if (i >= _stories.length) {
          return const Center(child: CircularProgressIndicator());
        }
        return BookCoverCard.fromBook(
          book: _stories[i],
          onTap: () => widget.onStoryTap(_stories[i].storyId),
        );
      },
    );
  }
}

// ─── Reusable initials avatar ─────────────────────────────────────────────────

class AuthorAvatar extends StatelessWidget {
  const AuthorAvatar({super.key, required this.name, required this.size});

  final String name;
  final double size;

  String get _initials {
    final parts = name.trim().split(' ');
    if (parts.length >= 2) {
      return '${parts.first[0]}${parts.last[0]}'.toUpperCase();
    }
    return name.substring(0, name.length.clamp(0, 2)).toUpperCase();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        color: context.colors.primaryLight,
        shape: BoxShape.circle,
      ),
      alignment: Alignment.center,
      child: Text(
        _initials,
        style: TextStyle(
          fontSize: size * 0.35,
          fontWeight: FontWeight.w700,
          color: context.colors.primary,
        ),
      ),
    );
  }
}

// ─── Header ───────────────────────────────────────────────────────────────────

class _AuthorHeader extends StatelessWidget {
  const _AuthorHeader({required this.author});

  final Author author;

  @override
  Widget build(BuildContext context) {
    return Container(
      color: context.colors.surface,
      padding: const EdgeInsets.fromLTRB(20, 16, 20, 16),
      child: Row(
        spacing: 16,
        children: [
          AuthorAvatar(name: author.name, size: 56),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              spacing: 3,
              children: [
                Text(
                  author.name,
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w700,
                    color: context.colors.textPrimary,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                Text(
                  '@${author.username}',
                  style: TextStyle(
                    fontSize: 13,
                    color: context.colors.gray,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
