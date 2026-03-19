import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';
import 'package:locallibrary/wattpad_publisher/bloc/scrape_part_bloc.dart';
import 'package:locallibrary/wattpad_publisher/modals/logs_modal.dart';
import 'package:locallibrary/wattpad_publisher/widgets/split_filled_button.dart';

import '../../core/theme/app_palette.dart';
import '../bloc/base_scrape_bloc.dart';
import '../datasource.dart';
import '../models/models.dart';
import '../models/server_parsed_json_models.dart';
import '../models/store_models.dart';
import '../widgets/input_bars.dart';

/// Extends [ExpansionTile] directly so it can be used in [ExpansionTileList]
/// without a cast.  The [bloc] is created and disposed by the parent.
class ScrapedPartRow extends ExpansionTile {
  ScrapedPartRow({
    Key? key,
    required PartLink partLink,
    required ScrapePartBloc bloc,
    required BaseScrapeBloc<PartTxResult> commentsBloc,
    required ValueNotifier<bool> expansionNotifier,
    required int storyId,
    required AppApiDataSource api,
    Part? downloadedPart,
  }) : super(
         key: key ?? ValueKey('part_${partLink.url ?? partLink.wattId}'),
         maintainState: true,
         shape: const Border(),
         tilePadding: EdgeInsets.zero,
         childrenPadding: EdgeInsets.zero,
         onExpansionChanged: (expanded) => expansionNotifier.value = expanded,
         title: _PartRowHeader(
           partLink: partLink,
           bloc: bloc,
           commentsBloc: commentsBloc,
           expansionNotifier: expansionNotifier,
           storyId: storyId,
           api: api,
           downloadedPart: downloadedPart,
         ),
         children: const [],
       );
}

class _PartRowHeader extends StatelessWidget {
  final PartLink partLink;
  final ScrapePartBloc bloc;
  final BaseScrapeBloc<PartTxResult> commentsBloc;
  final ValueNotifier<bool> expansionNotifier;
  final int storyId;
  final AppApiDataSource api;
  final Part? downloadedPart;

  const _PartRowHeader({
    required this.partLink,
    required this.bloc,
    required this.commentsBloc,
    required this.expansionNotifier,
    required this.storyId,
    required this.api,
    this.downloadedPart,
  });

  bool _isActive(BaseScrapeState<PartTxResult> s) =>
      s.status == ScrapeStatus.connecting || s.status == ScrapeStatus.streaming;

  void _openEventsModal(BuildContext context) {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!context.mounted) return;
      openScrapeEventsModal<PartTxResult>(context: context, bloc: bloc);
    });
  }

  void _onPrimaryTap(BuildContext context, BaseScrapeState<PartTxResult> s) {
    if (_isActive(s)) {
      _openEventsModal(context);
      return;
    }
    final href = partLink.url;
    if (href == null || href.isEmpty) return;
    bloc.add(InputChanged(href));
    bloc.add(StartRequested());
    _openEventsModal(context);
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<ScrapePartBloc, BaseScrapeState<PartTxResult>>(
      bloc: bloc,
      buildWhen: (p, n) => p.status != n.status,
      builder: (context, state) {
        final partTitle = partLink.title ?? partLink.wattId;
        final partUrl = partLink.url;
        final hasUrl = partUrl != null && partUrl.isNotEmpty;
        final titleStyle = Theme.of(context).textTheme.titleMedium?.copyWith(
          fontSize: 16,
          color: AppPalette.primary,
        );

        final Widget actionWidget;
        if (downloadedPart != null) {
          final formatted = DateFormat(
            'MMM d, yyyy',
          ).format(downloadedPart!.updatedAt.toLocal());
          actionWidget = Text(
            'Updated $formatted',
            style: Theme.of(context).textTheme.labelSmall?.copyWith(
              color: AppPalette.primary.withOpacity(0.6),
            ),
          );
        } else {
          actionWidget = SplitFilledButton(
            status: state.status,
            onPrimaryTap: () => _onPrimaryTap(context, bloc.state),
            onSecondary: () {
              if (_isActive(state)) bloc.add(CancelRequested());
            },
            secondaryActions: [
              SecondaryAction(
                label: 'Open logs',
                icon: Icons.list_alt,
                onTap: () => _openEventsModal(context),
              ),
              if (hasUrl)
                SecondaryAction(
                  label: 'Copy part URL',
                  icon: Icons.copy,
                  onTap: () => Clipboard.setData(ClipboardData(text: partUrl)),
                ),
              if (hasUrl)
                SecondaryAction(
                  label: 'Rescrape',
                  icon: Icons.refresh,
                  onTap: () => _onPrimaryTap(context, state),
                ),
            ],
          );
        }

        return WhiteContainer(
          axis: Axis.vertical,
          spacing: 0,
          children: [
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              child: LayoutBuilder(
                builder: (context, constraints) {
                  if (constraints.maxWidth < 700) {
                    return Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(partTitle, style: titleStyle),
                        const SizedBox(height: 10),
                        Align(
                          alignment: Alignment.centerRight,
                          child: actionWidget,
                        ),
                      ],
                    );
                  }
                  return Row(
                    children: [
                      Expanded(
                        child: Text(
                          partTitle,
                          style: titleStyle,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      const SizedBox(width: 12),
                      actionWidget,
                    ],
                  );
                },
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
                          ? _PartRowExpanded(
                              partLink: partLink,
                              bloc: bloc,
                              commentsBloc: commentsBloc,
                              storyId: storyId,
                              api: api,
                              downloadedPart: downloadedPart,
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

class _PartRowExpanded extends StatefulWidget {
  final PartLink partLink;
  final ScrapePartBloc bloc;
  final BaseScrapeBloc<PartTxResult> commentsBloc;
  final int storyId;
  final AppApiDataSource api;
  final Part? downloadedPart;

  const _PartRowExpanded({
    required this.partLink,
    required this.bloc,
    required this.commentsBloc,
    required this.storyId,
    required this.api,
    this.downloadedPart,
  });

  @override
  State<_PartRowExpanded> createState() => _PartRowExpandedState();
}

class _PartRowExpandedState extends State<_PartRowExpanded> {
  Future<(int, int)>? _countsFuture;

  @override
  void initState() {
    super.initState();
    final part = widget.downloadedPart;
    if (part != null) {
      _countsFuture = Future.wait([
        widget.api.getPartParagraphsCount(
          storyId: widget.storyId,
          partId: part.partId,
        ),
        widget.api.getPartCommentsCount(
          storyId: widget.storyId,
          partId: part.partId,
        ),
      ]).then((results) => (results[0], results[1]));
    }
  }

  void _openEventsModal(BuildContext context) {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!context.mounted) return;
      openScrapeEventsModal<PartTxResult>(context: context, bloc: widget.bloc);
    });
  }

  void _openCommentsEventsModal(BuildContext context) {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!context.mounted) return;
      openScrapeEventsModal<PartTxResult>(
        context: context,
        bloc: widget.commentsBloc,
      );
    });
  }

  void _startRescrape(BuildContext context) {
    final href = widget.partLink.url;
    if (href == null || href.isEmpty) return;
    widget.bloc.add(InputChanged(href));
    widget.bloc.add(StartRequested());
    _openEventsModal(context);
  }

  Future<void> _startScrapeComments(BuildContext context) async {
    final href = widget.partLink.url;
    if (href == null || href.isEmpty) return;

    // Subscribe BEFORE adding events so we don't miss any state transitions.
    // waitUntilDone() is unreliable here: the SSE connection may stay open
    // after the server finishes, so onDone never fires and the Completer hangs.
    final partFinished = widget.bloc.stream.firstWhere(
      (s) => s.status == ScrapeStatus.done || s.status == ScrapeStatus.error,
    );

    // Step 1: run the part scrape and open its log modal
    widget.bloc.add(InputChanged(href));
    widget.bloc.add(StartRequested());
    _openEventsModal(context);
    await partFinished;
    if (!context.mounted) return;

    // Step 2: run the comments scrape and switch the modal to it
    widget.commentsBloc.add(InputChanged(href));
    widget.commentsBloc.add(StartRequested());
    _openCommentsEventsModal(context);
  }

  @override
  Widget build(BuildContext context) {
    final labelStyle = Theme.of(context).textTheme.labelSmall?.copyWith(
      color: AppPalette.primary.withOpacity(0.7),
    );

    if (widget.downloadedPart == null) {
      final partUrl = widget.partLink.url;
      if (partUrl == null) return const SizedBox.shrink();
      return Padding(
        padding: const EdgeInsets.fromLTRB(12, 0, 12, 10),
        child: BlocBuilder<ScrapePartBloc, BaseScrapeState<PartTxResult>>(
          bloc: widget.bloc,
          buildWhen: (p, n) => p.result != n.result,
          builder: (context, scrapeState) {
            return BlocBuilder<
              BaseScrapeBloc<PartTxResult>,
              BaseScrapeState<PartTxResult>
            >(
              bloc: widget.commentsBloc,
              buildWhen: (p, n) => p.result != n.result,
              builder: (context, commentsState) {
                final paragraphsCount = scrapeState.result?.paragraphs.length;
                final commentsCount = commentsState.result?.comments.length;
                return Wrap(
                  spacing: 16,
                  runSpacing: 4,
                  children: [
                    Text(partUrl, style: labelStyle),
                    if (paragraphsCount != null)
                      Text('Paragraphs: $paragraphsCount', style: labelStyle),
                    if (commentsCount != null)
                      Text('Comments: $commentsCount', style: labelStyle),
                  ],
                );
              },
            );
          },
        ),
      );
    }

    final part = widget.downloadedPart!;
    final dateFmt = DateFormat('MMM d, yyyy');

    return Padding(
      padding: const EdgeInsets.fromLTRB(12, 4, 12, 12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        spacing: 10,
        children: [
          // Details row
          FutureBuilder<(int, int)>(
            future: _countsFuture,
            builder: (context, snapshot) {
              final paragraphsCount = snapshot.data?.$1;
              final commentsCount = snapshot.data?.$2;
              return Wrap(
                spacing: 16,
                runSpacing: 4,
                children: [
                  Text(
                    'Published: ${dateFmt.format(part.datePublished.toLocal())}',
                    style: labelStyle,
                  ),
                  Text(
                    'Votes: ${NumberFormat.compact().format(part.votes)}',
                    style: labelStyle,
                  ),
                  Text(
                    'Scraped: ${dateFmt.format(part.updatedAt.toLocal())}',
                    style: labelStyle,
                  ),
                  if (paragraphsCount != null)
                    Text('Paragraphs: $paragraphsCount', style: labelStyle),
                  if (commentsCount != null)
                    Text('Comments: $commentsCount', style: labelStyle),
                  if (part.isDeleted)
                    Text(
                      'Deleted',
                      style: labelStyle?.copyWith(color: AppPalette.error),
                    ),
                ],
              );
            },
          ),

          // Action buttons
          BlocBuilder<ScrapePartBloc, BaseScrapeState<PartTxResult>>(
            bloc: widget.bloc,
            buildWhen: (p, n) => p.status != n.status,
            builder: (context, scrapeState) {
              return BlocBuilder<
                BaseScrapeBloc<PartTxResult>,
                BaseScrapeState<PartTxResult>
              >(
                bloc: widget.commentsBloc,
                buildWhen: (p, n) => p.status != n.status,
                builder: (context, commentsState) {
                  return Row(
                    spacing: 8,
                    children: [
                      SplitFilledButton(
                        status: scrapeState.status,
                        onPrimaryTap: () => _startRescrape(context),
                        onSecondary: () => widget.bloc.add(CancelRequested()),
                        secondaryActions: [
                          SecondaryAction(
                            label: 'Open logs',
                            icon: Icons.list_alt,
                            onTap: () => _openEventsModal(context),
                          ),
                          if (widget.partLink.url != null &&
                              widget.partLink.url!.isNotEmpty)
                            SecondaryAction(
                              label: 'Copy part URL',
                              icon: Icons.copy,
                              onTap: () => Clipboard.setData(
                                ClipboardData(text: widget.partLink.url!),
                              ),
                            ),
                        ],
                      ),
                      SplitFilledButton(
                        status: commentsState.status,
                        onPrimaryTap: () => _startScrapeComments(context),
                        onSecondary: () =>
                            widget.commentsBloc.add(CancelRequested()),
                        secondaryActions: [
                          SecondaryAction(
                            label: 'Open logs',
                            icon: Icons.list_alt,
                            onTap: () => _openCommentsEventsModal(context),
                          ),
                        ],
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