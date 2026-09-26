import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../../core/api/library_api_client.dart';
import '../../../core/extensions/image.dart';
import '../../../core/secrets/app_secrets.dart';
import '../../../core/theme/app_theme.dart';
import '../../../dependency_injection.dart';
import '../../library/bloc/search_bloc.dart';
import '../../library/bloc/search_event.dart';
import '../../library/cubit/navigation_cubit.dart';
import '../../library/cubit/navigation_state.dart';
import '../../library/cubit/search_cubit.dart';
import '../../library/cubit/search_state.dart';
import '../models/domain/story_model.dart';
import '../models/dto/story_bundle.dart';
import '../screens/scrape_story_screen.dart';
import 'author_dialog.dart';
import 'story_layout.dart';
import 'story_tags_wrap.dart';

export 'story_tags_wrap.dart';

class StoryDescriptionTop extends StatelessWidget {
  const StoryDescriptionTop({
    super.key,
    required this.margin,
    required this.story,
  });

  final EdgeInsetsGeometry margin;
  final StoryBundle story;

  @override
  Widget build(BuildContext context) {
    final isMobile = MediaQuery.of(context).size.width < 600;

    if (isMobile) {
      return Container(
        margin: margin,
        color: context.colors.background,
        width: double.infinity,
        child: _StoryHero(story: story, mobile: true),
      );
    }

    return ContentContainer(
      margin: margin,
      width: double.infinity,
      height: double.infinity,
      color: context.colors.background,
      child: Align(
        alignment: Alignment.centerLeft,
        child: _StoryHero(story: story, mobile: false),
      ),
    );
  }
}

class _StoryHero extends StatelessWidget {
  const _StoryHero({required this.story, required this.mobile});

  final StoryBundle story;
  final bool mobile;

  void _openAuthor(BuildContext context) =>
      showAuthorDialog(
        context: context,
        author: story.author,
        fetchStories: (limit, offset) =>
            sl<LibraryApiClient>().getStoriesByAuthor(
              story.author.authorId,
              limit,
              offset,
            ),
      );

  void _reload(BuildContext context) {
    final url =
        story.story.url ??
            'https://www.wattpad.com/story/${story.story.wattId}';
    showScrapeSheet(context, url: url, autoStart: true);
  }

  void _continue(BuildContext context) {
    final partId =
        story.currentPart?.partId ??
            (story.parts.isNotEmpty ? story.parts[0].partId : null);
    if (partId == null) return;
    context.read<NavigationCubit>().push(
      NavigationPartState(storyId: story.story.storyId, partId: partId),
    );
  }

  void _searchByTag(BuildContext context, Tag tag) {
    final cubit = sl<SearchCubit>();
    cubit.setParams(AdvancedSearchParams(tagIds: {tag.tagId}));
    sl<SearchBloc>().add(SearchRequested(cubit.state.toFilterParams()));
    context.read<NavigationCubit>().pop();
  }

  Widget _cover(BuildContext context, {
    required double width,
    required double height,
  }) {
    return SizedBox(
      width: width,
      height: height,
      child: ClipRRect(
        borderRadius: BorderRadius.circular(8),
        child: story.image?.path != null
            ? LocalImage.relative(
          storageRoot: AppSecrets.storageRoot,
          storyWattId: story.story.wattId,
          relativePath: story.image!.path!,
          fit: BoxFit.cover,
        )
            : Container(color: context.colors.surfaceAlt),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final info = _StoryInfo(
      story: story,
      mobile: mobile,
      onAuthorTap: () => _openAuthor(context),
      onReload: () => _reload(context),
      onContinue: () => _continue(context),
      onTagTap: (t) => _searchByTag(context, t),
    );

    if (mobile) {
      const coverWidth = 220.0;
      return Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          _cover(context, width: coverWidth, height: coverWidth * 3 / 2),
          const SizedBox(height: 20),
          info,
        ],
      );
    }

    // The cover's size is derived from the *available* hero-band height
    // (capped) rather than a guessed width, so it can never be squeezed by
    // StoryLayout's fixed band and lose its 2:3 ratio — both dimensions are
    // always computed together from one number.
    return LayoutBuilder(
      builder: (context, constraints) {
        final availableHeight = constraints.maxHeight.isFinite
            ? constraints.maxHeight
            : 480.0;
        // Floor at 300 so the info column (title/author/tags/stats/buttons)
        // always has enough room and the button row doesn't get squeezed
        // out of its normal size on short windows.
        final coverHeight = availableHeight.clamp(300.0, 480.0);
        final coverWidth = coverHeight * 2 / 3;

        return SizedBox(
          height: coverHeight,
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              _cover(context, width: coverWidth, height: coverHeight),
              const SizedBox(width: 28),
              Expanded(child: info),
            ],
          ),
        );
      },
    );
  }
}

class _StoryInfo extends StatelessWidget {
  const _StoryInfo({
    required this.story,
    required this.mobile,
    required this.onAuthorTap,
    required this.onReload,
    required this.onContinue,
    required this.onTagTap,
  });

  final StoryBundle story;
  final bool mobile;
  final VoidCallback onAuthorTap;
  final VoidCallback onReload;
  final VoidCallback onContinue;
  final ValueChanged<Tag> onTagTap;

  @override
  Widget build(BuildContext context) {
    final crossAlign = mobile
        ? CrossAxisAlignment.center
        : CrossAxisAlignment.start;
    final textAlign = mobile ? TextAlign.center : TextAlign.start;

    final flags = <String>[
      if (!story.story.isFamilyFriendly) 'For Adults',
      if (story.story.isDeleted) 'Deleted',
      if (!story.story.isFree) 'Paid',
    ];

    final topGroup = Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: crossAlign,
      children: [
        Text(
          story.story.title,
          textAlign: textAlign,
          style: GoogleFonts.sourceSerif4(
            fontSize: mobile ? 26 : 32,
            fontWeight: FontWeight.w600,
            height: 1.2,
            color: context.colors.textPrimary,
          ),
        ),
        const SizedBox(height: 6),
        GestureDetector(
          onTap: onAuthorTap,
          child: Text(
            'by ${story.author.name}',
            textAlign: textAlign,
            style: TextStyle(fontSize: 15, color: context.colors.gray),
          ),
        ),
        const SizedBox(height: 14),
        StoryTagsWrap(
          tags: story.tags,
          fontSize: 15,
          alignment: mobile ? WrapAlignment.center : WrapAlignment.start,
          onTagTap: onTagTap,
        ),
        const SizedBox(height: 16),
        Wrap(
          alignment: mobile ? WrapAlignment.center : WrapAlignment.start,
          crossAxisAlignment: WrapCrossAlignment.center,
          children: [
            _Stat(bold: '${story.parts.length}', label: 'parts'),
            _StatDot(),
            _Stat(label: story.story.language.toUpperCase()),
            for (final f in flags) ...[_StatDot(), _Stat(label: f)],
          ],
        ),
      ],
    );

    final buttonRow = Row(
      mainAxisSize: MainAxisSize.min,
      mainAxisAlignment: mobile
          ? MainAxisAlignment.center
          : MainAxisAlignment.start,
      children: [
        FilledButton(
          onPressed: onContinue,
          style: FilledButton.styleFrom(
            backgroundColor: context.colors.primary,
            foregroundColor: context.colors.surface,
            padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 11),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(9),
            ),
            textStyle: const TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w700,
            ),
          ),
          child: Text(
            story.storyProgress.progress == null ? 'Read' : 'Continue',
          ),
        ),
        const SizedBox(width: 10),
        _IconBtn(icon: Icons.refresh, onTap: onReload),
        const SizedBox(width: 10),
        _IconBtn(icon: Icons.download_rounded, onTap: () => print('export')),
      ],
    );

    if (mobile) {
      return Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: crossAlign,
        children: [topGroup, const SizedBox(height: 18), buttonRow],
      );
    }

    // Stretches to the cover's full height (via the parent IntrinsicHeight +
    // Expanded) so the top content group pins to the top and the button row
    // pins to the bottom, instead of both huddling together under the title.
    return Column(
      crossAxisAlignment: crossAlign,
      children: [topGroup, const Spacer(), buttonRow],
    );
  }
}

class _Stat extends StatelessWidget {
  const _Stat({this.bold, required this.label});

  final String? bold;
  final String label;

  @override
  Widget build(BuildContext context) {
    return Text.rich(
      TextSpan(
        style: TextStyle(fontSize: 14, color: context.colors.gray),
        children: [
          if (bold != null)
            TextSpan(
              text: '$bold ',
              style: TextStyle(
                color: context.colors.textPrimary,
                fontWeight: FontWeight.w700,
              ),
            ),
          TextSpan(text: label),
        ],
      ),
    );
  }
}

class _StatDot extends StatelessWidget {
  const _StatDot();

  @override
  Widget build(BuildContext context) {
    return Text(
      ' · ',
      style: TextStyle(fontSize: 11, color: context.colors.gray),
    );
  }
}

class _IconBtn extends StatelessWidget {
  const _IconBtn({required this.icon, required this.onTap});

  final IconData icon;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(10),
      child: Container(
        width: 40,
        height: 40,
        alignment: Alignment.center,
        decoration: BoxDecoration(
          border: Border.all(color: context.colors.primaryExtraLight),
          borderRadius: BorderRadius.circular(10),
        ),
        child: Icon(icon, size: 18, color: context.colors.gray),
      ),
    );
  }
}
