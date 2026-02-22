import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:locallibrary/wattpad_publisher/bloc/scrape_part_bloc.dart';
import 'package:locallibrary/wattpad_publisher/datasource.dart';
import 'package:locallibrary/wattpad_publisher/modals/logs_modal.dart';
import 'package:locallibrary/wattpad_publisher/widgets/split_filled_button.dart';

import '../../core/theme/app_palette.dart';
import '../../dependency_ingection.dart';
import '../bloc/base_scrape_bloc.dart';
import '../models/server_parsed_json_models.dart';
import '../models/store_models.dart';
import '../widgets/input_bars.dart';

class ScrapedPartRow extends StatefulWidget {
  final int storyId;
  final PartLink partLink; // has: String wattId; String? url;

  const ScrapedPartRow({
    super.key,
    required this.storyId,
    required this.partLink,
  });

  @override
  State<ScrapedPartRow> createState() => _ScrapedPartRowState();
}

class _ScrapedPartRowState extends State<ScrapedPartRow> {
  late final ScrapePartBloc _bloc;

  @override
  void initState() {
    super.initState();
    _bloc = ScrapePartBloc(
      api: sl.get<AppApiDataSource>(),
      storyId: widget.storyId, // if your bloc supports ctor capture
    );
  }

  @override
  void dispose() {
    _bloc.close();
    super.dispose();
  }

  bool _isActive(BaseScrapeState<PartTxResult> s) =>
      s.status == ScrapeStatus.connecting || s.status == ScrapeStatus.streaming;

  void _openEventsModal() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      openScrapeEventsModal<PartTxResult>(context: context, bloc: _bloc);
    });
  }

  void _onPrimaryTap(BaseScrapeState<PartTxResult> s) {
    if (_isActive(s)) {
      // already scraping -> show live events
      _openEventsModal();
      return;
    }

    final href = widget.partLink.url;
    if (href == null || href.isEmpty) return;

    // If your bloc uses the custom event that carries storyId + input:
    _bloc.add(InputChanged(href));
    _bloc.add(StartRequested());

    // Optionally open the inspector immediately:
    _openEventsModal();
  }

  void _onCancel(BaseScrapeState<PartTxResult> s) {
    if (_isActive(s)) _bloc.add(CancelRequested());
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<ScrapePartBloc, BaseScrapeState<PartTxResult>>(
      bloc: _bloc,
      buildWhen: (p, n) => p.status != n.status,
      builder: (context, state) {
        final partTitle = widget.partLink.title ?? widget.partLink.wattId;
        final partUrl = widget.partLink.url;
        final hasUrl = partUrl != null && partUrl.isNotEmpty;
        final titleStyle = Theme.of(context).textTheme.titleMedium?.copyWith(
          fontSize: 16,
          color: AppPalette.primary,
        );

        final actionButton = SplitFilledButton(
          status: state.status,
          onPrimaryTap: () {
            _onPrimaryTap(_bloc.state);
          },
          onSecondary: () {
            _onCancel(state);
          },
          secondaryActions: [
            SecondaryAction(
              label: 'Open logs',
              icon: Icons.list_alt,
              onTap: _openEventsModal,
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
                onTap: () => _onPrimaryTap(state),
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
          ],
        );
      },
    );
  }
}

// class ScrapedPartLinkRow extends StatefulWidget {
//   final int storyId;
//   final PartLink partLink;
//
//   const ScrapedPartLinkRow({
//     super.key,
//     required this.storyId,
//     required this.partLink,
//   });
//
//   @override
//   State<ScrapedPartLinkRow> createState() => _ScrapedPartLinkRowState();
// }
//
// class _ScrapedPartLinkRowState extends State<ScrapedPartLinkRow> {
//   late final ScrapePartBloc _bloc;
//
//   @override
//   void initState() {
//     super.initState();
//     _bloc = ScrapePartBloc(api: sl.get<AppApiDataSource>(), storyId: widget.storyId);
//   }
//
//   @override
//   void dispose() {
//     _bloc.close();
//     super.dispose();
//   }
//
//   bool _isActive(BaseScrapeState<PartTxResult> s) =>
//       s.status == ScrapeStatus.connecting || s.status == ScrapeStatus.streaming;
//
//   void _onPrimaryTap(BaseScrapeState<PartTxResult> s) {
//     if (_isActive(s)) {
//       openScrapeEventsModal<PartTxResult>(context: context, bloc: _bloc);
//       return;
//     }
//
//     final href = widget.partLink.url;
//     if (href == null || href.isEmpty) return;
//
//     _bloc.add(InputChanged(href));
//     _bloc.add(StartRequested());
//     openScrapeEventsModal<PartTxResult>(context: context, bloc: _bloc);
//   }
//
//   @override
//   Widget build(BuildContext context) {
//     return BlocBuilder<ScrapePartBloc, BaseScrapeState<PartTxResult>>(
//       bloc: _bloc,
//       buildWhen: (p, n) =>
//           p.status != n.status || p.events.length != n.events.length,
//       builder: (context, state) {
//         return Row(
//           spacing: 20,
//           children: [
//             Expanded(
//               flex: 90,
//               child: WhiteContainer(
//                 spacing: 10,
//                 children: [
//                   Expanded(
//                     child: Row(
//                       mainAxisAlignment: MainAxisAlignment.spaceBetween,
//                       children: [
//                         Text(
//                           widget.partLink.wattId,
//                           style: Theme.of(context).textTheme.titleMedium?.copyWith(
//                             fontSize: 16,
//                             color: AppPalette.primary,
//                           ),
//                         ),
//                         SplitFilledButton(
//                           status: state.status,
//                           onPrimaryTap: () => _onPrimaryTap(_bloc.state),
//                           onSecondary: () =>
//                               context.read<ScrapePartBloc>().add(CancelRequested()),
//                           secondaryActions: [
//                             SecondaryAction(
//                               label: 'Open logs',
//                               icon: Icons.list_alt,
//                               onTap: () => openScrapeEventsModal<PartTxResult>(
//                                 context: context,
//                                 bloc: _bloc,
//                               ),
//                             ),
//                             SecondaryAction(
//                               label: 'Copy part URL',
//                               icon: Icons.copy,
//                               onTap: () {
//                                 final href = widget.partLink.url;
//                                 if (href == null || href.isEmpty) return;
//                                 Clipboard.setData(ClipboardData(text: href));
//                               },
//                             ),
//                           ],
//                         ),
//                       ],
//                     ),
//                   ),
//                 ],
//               ),
//             ),
//             Expanded(
//               flex: 5,
//               child: WhiteContainer(
//                 mainAxisAlignment: MainAxisAlignment.center,
//                 children: [SvgPicture.asset("assets/icons/adult_icon.svg")],
//               ),
//             ),
//             Expanded(
//               flex: 5,
//               child: WhiteContainer(
//                 mainAxisAlignment: MainAxisAlignment.center,
//                 children: [SvgPicture.asset("assets/icons/adult_icon.svg")],
//               ),
//             ),
//           ],
//         );
//       },
//     );
//   }
// }
