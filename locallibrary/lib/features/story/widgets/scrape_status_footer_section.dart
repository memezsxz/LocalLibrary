import 'package:expansion_tile_list/expansion_tile_list.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';
import 'package:locallibrary/core/extensions/scrape_status.dart';

import '../../../core/api/scrape_service.dart';
import '../../../core/api/story_api_client.dart';
import '../../../core/theme/app_palette.dart';
import '../../../dependency_injection.dart';
import '../../comments/bloc/scrape_comments_bloc.dart';
import '../../comments/models/scrape_comments_result.dart';
import '../../library/cubit/navigation_cubit.dart';
import '../../library/cubit/navigation_state.dart';
import '../../part/bloc/scrape_part_bloc.dart';
import '../bloc/base_scrape_bloc.dart';
import '../bloc/base_scrape_event.dart';
import '../bloc/base_scrape_state.dart';
import '../models/dto/part_info.dart';
import '../models/dto/part_link.dart';
import '../models/dto/scrape_story_res.dart';
import '../models/dto/story_bundle.dart';
import 'scrape_logs_dialog.dart';
import 'story_footer_section.dart';

/// Bottom section for [ScrapeStoryViewScreen].
///
/// Owns all per-part blocs and the shared [includeComments] flag so that
/// [_ScrapeAllBar] and every individual row use the same setting.
class ScrapeDescriptionBottom extends StatefulWidget {
  final StoryBundle bundle;
  final ScrapeStoryRes scrapeRes;

  const ScrapeDescriptionBottom({
    super.key,
    required this.bundle,
    required this.scrapeRes,
  });

  @override
  State<ScrapeDescriptionBottom> createState() =>
      _ScrapeDescriptionBottomState();
}

class _ScrapeDescriptionBottomState extends State<ScrapeDescriptionBottom> {
  late final List<ScrapePartBloc> _blocs;
  late final List<ScrapeCommentsBloc> _commentBlocs;
  late final List<ValueNotifier<bool>> _expansionNotifiers;
  late final Future<List<PartInfo>> _partsInfoFuture;
  final _scrapeService = sl.get<ScrapeService>();

  bool _includeComments = false;

  @override
  void initState() {
    super.initState();
    final storyId = widget.bundle.story.storyId;
    _partsInfoFuture = sl.get<StoryApiClient>().getPartsInfo(storyId);
    _blocs = widget.scrapeRes.partLinks
        .map((_) => ScrapePartBloc(api: _scrapeService, storyId: storyId))
        .toList();
    _commentBlocs = widget.scrapeRes.partLinks
        .map((_) => ScrapeCommentsBloc(api: _scrapeService, storyId: storyId))
        .toList();
    _expansionNotifiers = List.generate(
      widget.scrapeRes.partLinks.length,
      (_) => ValueNotifier(false),
    );
  }

  @override
  void dispose() {
    for (final b in _blocs) b.close();
    for (final b in _commentBlocs) b.close();
    for (final n in _expansionNotifiers) n.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          widget.bundle.story.description,
          style: Theme.of(
            context,
          ).textTheme.labelMedium?.copyWith(fontSize: 18),
        ),
        const SizedBox(height: 24),
        StoryTagsWrap(tags: widget.bundle.tags),
        const SizedBox(height: 24),
        _ScrapeAllBar(
          partLinks: widget.scrapeRes.partLinks,
          blocs: _blocs,
          includeComments: _includeComments,
          onIncludeCommentsChanged: (v) => setState(() => _includeComments = v),
        ),
        const SizedBox(height: 24),
        _ScrapeModeToc(
          partLinks: widget.scrapeRes.partLinks,
          partsInfoFuture: _partsInfoFuture,
          blocs: _blocs,
          commentBlocs: _commentBlocs,
          expansionNotifiers: _expansionNotifiers,
          storyId: widget.bundle.story.storyId,
          includeComments: _includeComments,
        ),
      ],
    );
  }
}

// ---------------------------------------------------------------------------
// Global scrape-all bar
// ---------------------------------------------------------------------------

class _ScrapeAllBar extends StatefulWidget {
  final List<PartLink> partLinks;
  final List<ScrapePartBloc> blocs;
  final bool includeComments;
  final ValueChanged<bool> onIncludeCommentsChanged;

  const _ScrapeAllBar({
    required this.partLinks,
    required this.blocs,
    required this.includeComments,
    required this.onIncludeCommentsChanged,
  });

  @override
  State<_ScrapeAllBar> createState() => _ScrapeAllBarState();
}

class _ScrapeAllBarState extends State<_ScrapeAllBar> {
  bool _isRunning = false;
  int _doneCount = 0;

  Future<void> _scrapeAll() async {
    setState(() {
      _isRunning = true;
      _doneCount = 0;
    });

    final futures = <Future<void>>[];

    for (var i = 0; i < widget.partLinks.length; i++) {
      final link = widget.partLinks[i];
      final href = link.url;
      if (href == null || href.isEmpty) {
        setState(() => _doneCount++);
        continue;
      }

      final bloc = widget.blocs[i];
      bloc.withComments = widget.includeComments;
      bloc.add(InputChanged(href));
      bloc.add(StartRequested());

      futures.add(
        bloc.stream
            .firstWhere(
              (s) =>
                  s.status == ScrapeStatus.done ||
                  s.status == ScrapeStatus.error,
            )
            .then((_) {
              if (mounted && _isRunning) setState(() => _doneCount++);
            }),
      );
    }

    await Future.wait(futures, eagerError: false);
    if (mounted) setState(() => _isRunning = false);
  }

  void _stopAll() {
    for (final bloc in widget.blocs) {
      if (bloc.state.status.isBusy) bloc.add(CancelRequested());
    }
    setState(() => _isRunning = false);
  }

  @override
  Widget build(BuildContext context) {
    final total = widget.partLinks.length;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.08),
            blurRadius: 12,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        spacing: 12,
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              spacing: 2,
              children: [
                Text(
                  'Scrape All Parts',
                  style: Theme.of(context).textTheme.titleSmall,
                ),
                if (_isRunning)
                  Text(
                    '$_doneCount / $total parts done',
                    style: Theme.of(
                      context,
                    ).textTheme.labelSmall?.copyWith(color: AppPalette.primary),
                  )
                else
                  Text(
                    '$total parts',
                    style: Theme.of(
                      context,
                    ).textTheme.labelSmall?.copyWith(color: Colors.grey),
                  ),
              ],
            ),
          ),
          FilterChip(
            label: const Text('+ Comments'),
            selected: widget.includeComments,
            onSelected: _isRunning ? null : widget.onIncludeCommentsChanged,
            visualDensity: VisualDensity.compact,
          ),
          if (_isRunning)
            OutlinedButton(onPressed: _stopAll, child: const Text('Stop'),
            )
          else
            FilledButton.icon(
              onPressed: _scrapeAll,
              icon: const Icon(Icons.download, size: 16),
              label: const Text('Scrape All'),
            ),
        ],
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// TOC container
// ---------------------------------------------------------------------------

class _ScrapeModeToc extends StatelessWidget {
  final List<PartLink> partLinks;
  final Future<List<PartInfo>> partsInfoFuture;
  final List<ScrapePartBloc> blocs;
  final List<ScrapeCommentsBloc> commentBlocs;
  final List<ValueNotifier<bool>> expansionNotifiers;
  final int storyId;
  final bool includeComments;

  const _ScrapeModeToc({
    required this.partLinks,
    required this.partsInfoFuture,
    required this.blocs,
    required this.commentBlocs,
    required this.expansionNotifiers,
    required this.storyId,
    required this.includeComments,
  });

  @override
  Widget build(BuildContext context) {
    const padding = 40.0;

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.only(top: 30),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: const BorderRadius.all(Radius.circular(25)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.25),
            offset: Offset.zero,
            blurRadius: 20,
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(
              vertical: 10,
              horizontal: padding,
            ),
            child: Text(
              'Table Of Content',
              style: Theme.of(
                context,
              ).textTheme.titleLarge?.copyWith(fontSize: 20),
            ),
          ),
          const SizedBox(),
          FutureBuilder<List<PartInfo>>(
            future: partsInfoFuture,
            builder: (context, snapshot) {
              final localByWattId = {
                for (final p in snapshot.data ?? <PartInfo>[]) p.wattId: p,
              };
              return ExpansionTileList(
                shrinkWrap: true,
                primary: false,
                physics: const NeverScrollableScrollPhysics(),
                itemGapSize: 12,
                expansionMode: ExpansionMode.atMostOne,
                children: [
                  for (var i = 0; i < partLinks.length; i++)
                    _ScrapeModeTocRow(
                      partLink: partLinks[i],
                      localPart: localByWattId[partLinks[i].wattId],
                      bloc: blocs[i],
                      commentsBloc: commentBlocs[i],
                      expansionNotifier: expansionNotifiers[i],
                      storyId: storyId,
                      includeComments: includeComments,
                    ),
                ],
              );
            },
          ),
          const SizedBox(height: 10),
        ],
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// Individual TOC row — extends ExpansionTile for ExpansionTileList
// ---------------------------------------------------------------------------

class _ScrapeModeTocRow extends ExpansionTile {
  _ScrapeModeTocRow({
    Key? key,
    required PartLink partLink,
    required PartInfo? localPart,
    required ScrapePartBloc bloc,
    required BaseScrapeBloc<ScrapeCommentsResult> commentsBloc,
    required ValueNotifier<bool> expansionNotifier,
    required int storyId,
    required bool includeComments,
  }) : super(
         key: key ?? ValueKey('scrape_toc_${partLink.wattId}'),
         maintainState: true,
         shape: const Border(),
         tilePadding: EdgeInsets.zero,
         childrenPadding: EdgeInsets.zero,
         trailing: const SizedBox.shrink(),
         onExpansionChanged: (expanded) => expansionNotifier.value = expanded,
         title: _ScrapeModeTocRowHeader(
           partLink: partLink,
           localPart: localPart,
           bloc: bloc,
           commentsBloc: commentsBloc,
           expansionNotifier: expansionNotifier,
           storyId: storyId,
           includeComments: includeComments,
         ),
         children: const [],
       );
}

// ---------------------------------------------------------------------------
// Row header (collapsed + animated expanded section)
// ---------------------------------------------------------------------------

class _ScrapeModeTocRowHeader extends StatelessWidget {
  final PartLink partLink;
  final PartInfo? localPart;
  final ScrapePartBloc bloc;
  final BaseScrapeBloc<ScrapeCommentsResult> commentsBloc;
  final ValueNotifier<bool> expansionNotifier;
  final int storyId;
  final bool includeComments;

  const _ScrapeModeTocRowHeader({
    required this.partLink,
    required this.localPart,
    required this.bloc,
    required this.commentsBloc,
    required this.expansionNotifier,
    required this.storyId,
    required this.includeComments,
  });

  @override
  Widget build(BuildContext context) {
    final title = partLink.title ?? partLink.wattId;
    final titleStyle = Theme.of(
      context,
    ).textTheme.titleMedium?.copyWith(fontSize: 16, color: AppPalette.primary);

    return BlocBuilder<ScrapePartBloc, BaseScrapeState<PartInfo>>(
      bloc: bloc,
      buildWhen: (p, n) => p.status != n.status,
      builder: (context, scrapeState) {
        return Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              child: Row(
                children: [
                  Expanded(
                    child: Text(
                      title,
                      style: titleStyle,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  _QuickScrapeActions(
                    bloc: bloc,
                    commentsBloc: commentsBloc,
                    partLink: partLink,
                    localPart: localPart,
                    includeComments: includeComments,
                  ),
                ],
              ),
            ),
            ClipRect(
              child: AnimatedSize(
                duration: const Duration(milliseconds: 220),
                curve: Curves.easeInOut,
                child: ValueListenableBuilder<bool>(
                  valueListenable: expansionNotifier,
                  builder: (context, isExpanded, _) {
                    return AnimatedOpacity(
                      opacity: isExpanded ? 1.0 : 0.0,
                      duration: const Duration(milliseconds: 180),
                      child: isExpanded
                          ? _ScrapeModeTocRowExpanded(
                              partLink: partLink,
                              localPart: localPart,
                              bloc: bloc,
                              commentsBloc: commentsBloc,
                              storyId: storyId,
                              includeComments: includeComments,
                            )
                          : const SizedBox(width: double.infinity),
                    );
                  },
                ),
              ),
            ),
          ],
        );
      },
    );
  }
}

// ---------------------------------------------------------------------------
// Quick-action icon button(s) shown in the collapsed row
// ---------------------------------------------------------------------------

class _QuickScrapeActions extends StatelessWidget {
  final ScrapePartBloc bloc;
  final BaseScrapeBloc<ScrapeCommentsResult> commentsBloc;
  final PartLink partLink;
  final PartInfo? localPart;
  final bool includeComments;

  const _QuickScrapeActions({
    required this.bloc,
    required this.commentsBloc,
    required this.partLink,
    required this.localPart,
    required this.includeComments,
  });

  String? get _href => partLink.url;

  void _scrape(BuildContext context) {
    final href = _href;
    if (href == null || href.isEmpty) return;
    bloc.withComments = includeComments;
    bloc.add(InputChanged(href));
    bloc.add(StartRequested());
  }

  void _openLogs(BuildContext context) {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!context.mounted) return;
      openScrapeEventsModal<PartInfo>(context: context, bloc: bloc);
    });
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<ScrapePartBloc, BaseScrapeState<PartInfo>>(
      bloc: bloc,
      buildWhen: (p, n) => p.status != n.status,
      builder: (context, scrapeState) {
        if (scrapeState.status.isBusy) {
          return _FilledIconBtn(
            icon: Icons.list_alt,
            tooltip: 'View logs',
            onPressed: () => _openLogs(context),
          );
        }

        if (scrapeState.status == ScrapeStatus.error) {
          return Row(
            mainAxisSize: MainAxisSize.min,
            spacing: 4,
            children: [
              _FilledIconBtn(
                icon: Icons.list_alt,
                tooltip: 'View logs',
                color: AppPalette.error,
                onPressed: () => _openLogs(context),
              ),
              _FilledIconBtn(
                icon: Icons.replay,
                tooltip: 'Retry',
                color: AppPalette.error,
                onPressed: () => _scrape(context),
              ),
            ],
          );
        }

        final hasUrl = _href != null && _href!.isNotEmpty;
        final isScraped = localPart != null;
        return _FilledIconBtn(
          icon: isScraped ? Icons.refresh : Icons.download,
          tooltip: isScraped ? 'Rescrape part' : 'Scrape part',
          color: isScraped ? AppPalette.primary : Colors.grey,
          onPressed: hasUrl ? () => _scrape(context) : null,
        );
      },
    );
  }
}

class _FilledIconBtn extends StatelessWidget {
  final IconData icon;
  final String tooltip;
  final VoidCallback? onPressed;
  final Color? color;

  const _FilledIconBtn({
    required this.icon,
    required this.tooltip,
    this.onPressed,
    this.color,
  });

  @override
  Widget build(BuildContext context) {
    final bg = color ?? AppPalette.primary;
    final effectiveBg = onPressed == null ? bg.withOpacity(0.3) : bg;
    return Tooltip(
      message: tooltip,
      child: Material(
        color: effectiveBg,
        borderRadius: BorderRadius.circular(6),
        child: InkWell(
          onTap: onPressed,
          borderRadius: BorderRadius.circular(6),
          child: SizedBox(
            width: 30,
            height: 30,
            child: Icon(icon, size: 16, color: Colors.white),
          ),
        ),
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// Expanded section (metadata + action buttons)
// ---------------------------------------------------------------------------

class _ScrapeModeTocRowExpanded extends StatefulWidget {
  final PartLink partLink;
  final PartInfo? localPart;
  final ScrapePartBloc bloc;
  final BaseScrapeBloc<ScrapeCommentsResult> commentsBloc;
  final int storyId;
  final bool includeComments;

  const _ScrapeModeTocRowExpanded({
    required this.partLink,
    required this.localPart,
    required this.bloc,
    required this.commentsBloc,
    required this.storyId,
    required this.includeComments,
  });

  @override
  State<_ScrapeModeTocRowExpanded> createState() =>
      _ScrapeModeTocRowExpandedState();
}

class _ScrapeModeTocRowExpandedState extends State<_ScrapeModeTocRowExpanded> {

  void _openPartLogs(BuildContext context) {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!context.mounted) return;
      openScrapeEventsModal<PartInfo>(
          context: context, bloc: widget.bloc);
    });
  }

  void _openCommentsLogs(BuildContext context) {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!context.mounted) return;
      openScrapeEventsModal<ScrapeCommentsResult>(
          context: context, bloc: widget.commentsBloc);
    });
  }

  String? get _href => widget.partLink.url;

  void _startScrape(BuildContext context) {
    final href = _href;
    if (href == null || href.isEmpty) return;
    widget.bloc.withComments = widget.includeComments;
    widget.bloc.add(InputChanged(href));
    widget.bloc.add(StartRequested());
    _openPartLogs(context);
  }

  void _startScrapeComments(BuildContext context) {
    final href = _href;
    if (href == null || href.isEmpty) return;
    widget.commentsBloc.add(InputChanged(href));
    widget.commentsBloc.add(StartRequested());
    _openCommentsLogs(context);
  }

  @override
  Widget build(BuildContext context) {
    final dateFmt = DateFormat('MMM d, yyyy');
    final labelStyle = Theme.of(context).textTheme.labelSmall?.copyWith(
      color: AppPalette.primary.withOpacity(0.7),
    );

    return Padding(
      padding: const EdgeInsets.fromLTRB(12, 4, 12, 12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        spacing: 10,
        children: [
          // Metadata
          if (widget.localPart != null)
            Wrap(
              spacing: 16,
              runSpacing: 4,
              children: [
                Text(
                  'Published: ${dateFmt.format(
                      widget.localPart!.datePublished.toLocal())}',
                  style: labelStyle,
                ),
                Text(
                  'Votes: ${NumberFormat.compact().format(
                      widget.localPart!.votes)}',
                  style: labelStyle,
                ),
                Text(
                  'Paragraphs: ${widget.localPart!.paragraphCount}',
                  style: labelStyle,
                ),
                Text(
                  'Comments: ${widget.localPart!.commentCount}',
                  style: labelStyle,
                ),
                if (widget.localPart!.isDeleted)
                  Text(
                    'Deleted',
                    style: labelStyle?.copyWith(color: AppPalette.error),
                  ),
              ],
            )
          else if (widget.partLink.url != null)
            Text(widget.partLink.url!, style: labelStyle),

          // Action buttons
          BlocBuilder<ScrapePartBloc, BaseScrapeState<PartInfo>>(
            bloc: widget.bloc,
            buildWhen: (p, n) => p.status != n.status,
            builder: (context, scrapeState) {
              return BlocBuilder<
                  BaseScrapeBloc<ScrapeCommentsResult>,
                  BaseScrapeState<ScrapeCommentsResult>
              >(
                bloc: widget.commentsBloc,
                buildWhen: (p, n) => p.status != n.status,
                builder: (context, commentsState) {
                  final scrapeBusy = scrapeState.status.isBusy;
                  final commentsBusy = commentsState.status.isBusy;

                  return Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    alignment: WrapAlignment.center,
                    children: [
                      // Read — only for already-scraped parts
                      if (widget.localPart != null)
                        OutlinedButton.icon(
                          onPressed: () => context.read<NavigationCubit>().push(
                            NavigationPartState(
                              storyId: widget.storyId,
                              partId: widget.localPart!.partId,
                            ),
                          ),
                          icon: const Icon(Icons.menu_book, size: 16),
                          label: const Text('Read'),
                        ),

                      // Scrape / Rescrape — chains comments if flag is on
                      FilledButton.icon(
                        onPressed: scrapeBusy
                            ? () => _openPartLogs(context)
                            : () => _startScrape(context),
                        icon: scrapeBusy
                            ? const SizedBox(
                                width: 14,
                                height: 14,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2,
                                  color: Colors.white,
                                ),
                              )
                            : Icon(
                                widget.localPart != null
                                    ? Icons.refresh
                                    : Icons.download,
                                size: 16,
                              ),
                        label: Text(
                          scrapeBusy
                              ? 'View Logs'
                              : widget.localPart != null
                              ? 'Rescrape Part'
                              : 'Scrape Part',
                        ),
                      ),

                      // Scrape Comments (always available independently)
                      OutlinedButton.icon(
                        onPressed: commentsBusy
                            ? () => _openCommentsLogs(context)
                            : () => _startScrapeComments(context),
                        icon: commentsBusy
                            ? const SizedBox(
                                width: 14,
                                height: 14,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2,
                                ),
                              )
                            : const Icon(Icons.comment, size: 16),
                        label: Text(
                          commentsBusy ? 'View Logs' : 'Scrape Comments',
                        ),
                      ),
                    ],
                  );
                },
              );
            },
          ),
        ],
      ),
    );
  }
}
