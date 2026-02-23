import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:locallibrary/wattpad_publisher/bloc/scrape_part_bloc.dart';
import 'package:locallibrary/wattpad_publisher/modals/logs_modal.dart';
import 'package:locallibrary/wattpad_publisher/widgets/split_filled_button.dart';

import '../../core/theme/app_palette.dart';
import '../bloc/base_scrape_bloc.dart';
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
    required ValueNotifier<bool> expansionNotifier,
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
           expansionNotifier: expansionNotifier,
         ),
         children: const [],
       );
}

class _PartRowHeader extends StatelessWidget {
  final PartLink partLink;
  final ScrapePartBloc bloc;
  final ValueNotifier<bool> expansionNotifier;

  const _PartRowHeader({
    required this.partLink,
    required this.bloc,
    required this.expansionNotifier,
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

        final actionButton = SplitFilledButton(
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
                          child: actionButton,
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
                      actionButton,
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
                          ? _PartRowExpanded(partLink: partLink, bloc: bloc)
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

class _PartRowExpanded extends StatelessWidget {
  final PartLink partLink;
  final ScrapePartBloc bloc;

  const _PartRowExpanded({required this.partLink, required this.bloc});

  @override
  Widget build(BuildContext context) {
    final partUrl = partLink.url;
    if (partUrl == null) return const SizedBox.shrink();

    return Column(
      children: [
        Text(
          partUrl,
          style: Theme.of(context).textTheme.labelSmall?.copyWith(
            color: AppPalette.primary.withOpacity(0.8),
          ),
        ),
        Text("dasdsa"),
      ],
    );
  }
}
