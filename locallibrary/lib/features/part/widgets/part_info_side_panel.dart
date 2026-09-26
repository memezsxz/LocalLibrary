import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:scrollable_positioned_list/scrollable_positioned_list.dart';

import '../../../core/extensions/image.dart';
import '../../../core/secrets/app_secrets.dart';
import '../../../core/theme/app_theme.dart';
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
              _StoryHeader(storyId: widget.storyId, b: b),
              Divider(height: 1, color: context.colors.primaryExtraLight),
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.symmetric(vertical: 8),
                  child: ScrollablePositionedList.separated(
                    itemScrollController: _itemScroll,
                    itemPositionsListener: _positions,
                    initialScrollIndex: targetIndex ?? 0,
                    initialAlignment: 0.1,
                    separatorBuilder: (_, __) => const SizedBox(height: 6),
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
              ),
            ],
          ),
        );
      },
    );
  }
}

// ── Header: cover + title + author, tap through to the story screen ───────────

class _StoryHeader extends StatelessWidget {
  const _StoryHeader({required this.storyId, required this.b});

  final int storyId;
  final StoryBundle b;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: () => context.read<NavigationCubit>().push(
        NavigationStoryState(storyId: storyId),
      ),
      child: Padding(
        padding: const EdgeInsets.all(14),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            ClipRRect(
              borderRadius: BorderRadius.circular(5),
              child: SizedBox(
                width: 42,
                height: 63,
                child: b.image?.path != null
                    ? LocalImage.relative(
                  storageRoot: AppSecrets.storageRoot,
                  storyWattId: b.story.wattId,
                  relativePath: b.image!.path!,
                  fit: BoxFit.cover,
                )
                    : Container(color: context.colors.surfaceAlt),
              ),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    b.story.title.trim(),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      fontSize: 13.5,
                      fontWeight: FontWeight.w600,
                      height: 1.25,
                      color: context.colors.textPrimary,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    'by ${b.author.username}',
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(fontSize: 11, color: context.colors.gray),
                  ),
                ],
              ),
            ),
            Icon(
              Icons.chevron_right,
              size: 18,
              color: context.colors.primaryLight,
            ),
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
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 14),
      child: Container(
        decoration: BoxDecoration(
          color: isCurrentPart
              ? context.colors.background
              : context.colors.primaryExtraLight,
          borderRadius: BorderRadius.circular(9),
          border: isCurrentPart
              ? Border(
            left: BorderSide(color: context.colors.primary, width: 3),
          )
              : Border.all(color: context.colors.primaryExtraLight),
        ),
        clipBehavior: Clip.hardEdge,
        child: Material(
          color: Colors.transparent,
          child: InkWell(
            onTap: () =>
                context.read<NavigationCubit>().push(
                  NavigationPartState(storyId: storyId, partId: part.partId),
                ),
            child: Padding(
              padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 12),
              child: Row(
                children: [
                  Expanded(
                    child: Text(
                      part.title,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        fontSize: 12.5,
                        color: isCurrentPart
                            ? context.colors.primary
                            : context.colors.textPrimary,
                        fontWeight: isCurrentPart
                            ? FontWeight.w700
                            : FontWeight.normal,
                      ),
                    ),
                  ),
                  if (isCurrentPart)
                    Icon(
                      Icons.play_arrow_rounded,
                      size: 16,
                      color: context.colors.primary,
                    ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
