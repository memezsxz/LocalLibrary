import 'package:auto_size_text/auto_size_text.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:scrollable_positioned_list/scrollable_positioned_list.dart';

import '../../../core/extensions/image.dart';
import '../../../core/theme/app_palette.dart';
import '../../library/cubit/navigation_cubit.dart';
import '../../library/cubit/navigation_state.dart';
import '../../story/bloc/story_bloc.dart';
import '../../story/bloc/story_event.dart';
import '../../story/bloc/story_state.dart';
import '../../story/models/domain/part_model.dart';
import '../../story/models/dto/story_bundle.dart';

class PartInfoSidePanel extends StatefulWidget {
  const PartInfoSidePanel({super.key, required this.storyId});

  final int storyId;

  @override
  State<PartInfoSidePanel> createState() => _PartInfoSidePanelState();
}

class _PartInfoSidePanelState extends State<PartInfoSidePanel> {
  final _itemScroll = ItemScrollController();
  final _positions = ItemPositionsListener.create();

  int? _currentIndex(StoryBundle b) {
    final current = b.currentPart;
    if (current == null) return null;
    final idx = b.parts.indexWhere((p) => p.partId == current.partId);
    return idx >= 0 ? idx : null;
  }

  @override
  Widget build(BuildContext context) {
    final isMobile = MediaQuery.of(context).size.width < 1200;

    return BlocBuilder<StoryBloc, StoryState>(
      buildWhen: (prev, next) =>
          prev.bundleFor(widget.storyId) != next.bundleFor(widget.storyId) ||
          prev.isLoading(widget.storyId) != next.isLoading(widget.storyId) ||
          prev.errorFor(widget.storyId) != next.errorFor(widget.storyId),
      builder: (context, state) {
        final bundle = state.bundleFor(widget.storyId);
        final loading = state.isLoading(widget.storyId);
        final error = state.errorFor(widget.storyId);

        if (bundle == null && !loading && error == null) {
          context.read<StoryBloc>().add(StoryRequested(widget.storyId));
          return const Center(child: CircularProgressIndicator());
        }
        if (bundle == null && loading) {
          return const Center(child: CircularProgressIndicator());
        }
        if (bundle == null && error != null) {
          return Padding(
            padding: const EdgeInsets.all(16),
            child: Text('Failed to load: $error'),
          );
        }

        final b = bundle!;
        final targetIndex = _currentIndex(b);

        return BlocListener<StoryBloc, StoryState>(
          listenWhen: (prev, next) {
            final prevPart = prev
                .bundleFor(widget.storyId)
                ?.currentPart
                ?.partId;
            final nextPart = next
                .bundleFor(widget.storyId)
                ?.currentPart
                ?.partId;
            return prevPart != nextPart && nextPart != null;
          },
          listener: (context, state) {
            final newBundle = state.bundleFor(widget.storyId);
            if (newBundle == null) return;
            final idx = _currentIndex(newBundle);
            if (idx != null && _itemScroll.isAttached) {
              _itemScroll.scrollTo(
                index: idx,
                duration: const Duration(milliseconds: 300),
                curve: Curves.easeOutCubic,
                alignment: 0.1,
              );
            }
          },
          child: Column(
            mainAxisSize: MainAxisSize.max,
            children: [
              // ── Header ──────────────────────────────────────────────────
              if (!isMobile)
                _DesktopHeader(storyId: widget.storyId, b: b)
              else
                _MobileHeader(storyId: widget.storyId, b: b),

              const Divider(height: 1),

              // ── Parts list ──────────────────────────────────────────────
              Expanded(
                child: ScrollablePositionedList.separated(
                  itemScrollController: _itemScroll,
                  itemPositionsListener: _positions,
                  initialScrollIndex: targetIndex ?? 0,
                  initialAlignment: 0.1,
                  separatorBuilder: (_, __) => const SizedBox(height: 4),
                  itemCount: b.parts.length,
                  itemBuilder: (ctx, i) {
                    final part = b.parts[i];
                    final isCurrent =
                        b.currentPart != null &&
                        b.currentPart!.partId == part.partId;
                    return _PartRow(
                      isCurrentPart: isCurrent,
                      storyId: widget.storyId,
                      part: part,
                    );
                  },
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}

// ── Desktop header: image + title + author side by side ───────────────────────

class _DesktopHeader extends StatelessWidget {
  const _DesktopHeader({required this.storyId, required this.b});

  final int storyId;
  final StoryBundle b;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Row(
        spacing: 12,
        children: [
          GestureDetector(
            onTap: () => context.read<NavigationCubit>().push(
              NavigationStoryState(storyId: storyId),
            ),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(5),
              child: LocalImage.relative(
                storageRoot: "/Users/meme/Desktop/storage",
                storyWattId: b.story.wattId,
                relativePath: b.image!.path!,
                height: MediaQuery.of(context).size.height / 5,
              ),
            ),
          ),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.start,
              children: [
                AutoSizeText(
                  b.story.title.trim(),
                  style: Theme.of(context).textTheme.titleLarge,
                  maxLines: 4,
                  minFontSize: 12,
                  stepGranularity: 0.5,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 4),
                AutoSizeText.rich(
                  TextSpan(
                    children: [
                      const TextSpan(
                        text: 'By ',
                        style: TextStyle(color: Colors.black54),
                      ),
                      TextSpan(
                        text: b.author.username,
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          color: Colors.black54,
                        ),
                        recognizer: TapGestureRecognizer()
                          ..onTap = () =>
                              debugPrint('author: ${b.author.username}'),
                      ),
                    ],
                  ),
                  maxLines: 1,
                  minFontSize: 10,
                  overflow: TextOverflow.ellipsis,
                  stepGranularity: 0.5,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

// ── Mobile header: compact title row, no image ────────────────────────────────

class _MobileHeader extends StatelessWidget {
  const _MobileHeader({required this.storyId, required this.b});

  final int storyId;
  final StoryBundle b;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: () => context.read<NavigationCubit>().push(
        NavigationStoryState(storyId: storyId),
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
        child: Row(
          spacing: 10,
          children: [
            ClipRRect(
              borderRadius: BorderRadius.circular(4),
              child: LocalImage.relative(
                storageRoot: "/Users/meme/Desktop/storage",
                storyWattId: b.story.wattId,
                relativePath: b.image!.path!,
                height: 56,
              ),
            ),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    b.story.title.trim(),
                    style: Theme.of(context).textTheme.titleMedium,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                  Text(
                    'By ${b.author.username}',
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: AppPalette.primaryLight,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            ),
            Icon(Icons.chevron_right, color: AppPalette.primaryLight, size: 18),
          ],
        ),
      ),
    );
  }
}

// ── Part row ──────────────────────────────────────────────────────────────────

class _PartRow extends StatelessWidget {
  const _PartRow({
    required this.isCurrentPart,
    required this.storyId,
    required this.part,
  });

  final bool isCurrentPart;
  final int storyId;
  final Part part;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: isCurrentPart
          ? AppPalette.primary.withOpacity(0.12)
          : Colors.transparent,
      child: InkWell(
        onTap: () => context.read<NavigationCubit>().push(
          NavigationPartState(storyId: storyId, partId: part.partId),
        ),
        child: ConstrainedBox(
          constraints: const BoxConstraints(minHeight: 44),
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 16),
            child: Row(
              spacing: 8,
              children: [
                Expanded(
                  child: Text(
                    part.title,
                    softWrap: true,
                    style: Theme.of(context).textTheme.labelMedium?.copyWith(
                      fontSize: 15,
                      color: isCurrentPart ? AppPalette.primary : Colors.black,
                      fontWeight: isCurrentPart
                          ? FontWeight.w600
                          : FontWeight.normal,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
