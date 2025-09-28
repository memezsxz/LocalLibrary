import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_json_view/flutter_json_view.dart';
import 'package:intl/intl.dart';

import '../../core/commen/widgets/loader.dart';
import '../../core/theme/app_palette.dart';
import '../bloc/base_scrape_bloc.dart';
import '../models/logs.dart';

// 1) Generic opener that works for any scrape bloc/result
void openScrapeEventsModal<TRes>({
  required BuildContext context,
  required BaseScrapeBloc<TRes> bloc,
}) {
  final width = MediaQuery.of(context).size.width / 1.5;
  final height = MediaQuery.of(context).size.height / 1.5;
  showGeneralDialog(
    context: context,
    barrierDismissible: false,
    barrierColor: Colors.black54,
    pageBuilder: (ctx, a1, a2) {
      return Center(
        child: ConstrainedBox(
          constraints: BoxConstraints(maxWidth: width, maxHeight: height),
          child: Material(
            elevation: 12,
            clipBehavior: Clip.antiAlias,
            borderRadius: BorderRadius.circular(16),
            // If anything inside uses context.read<T>(), provide the same bloc:
            child: BlocProvider.value(
              value: bloc,
              child: EventInspectorModal<TRes>(bloc: bloc),
            ),
          ),
        ),
      );
    },
  );
}

// void openScrapeStoryEventsInspector(BuildContext context) async {
//   showGeneralDialog(
//     context: context,
//     barrierDismissible: false,
//     barrierLabel: 'Add Story',
//     barrierColor: Colors.black54,
//     pageBuilder: (ctx, a1, a2) {
//       return Center(
//         child: ConstrainedBox(
//           constraints: const BoxConstraints(maxWidth: 920, maxHeight: 680),
//           child: Material(
//             elevation: 12,
//             clipBehavior: Clip.antiAlias,
//             borderRadius: BorderRadius.circular(16),
//             child: const EventInspectorModal(),
//           ),
//         ),
//       );
//     },
//   );
// }

// class EventInspectorModal extends StatefulWidget {
//   const EventInspectorModal();
//
//   @override
//   State<EventInspectorModal> createState() => _EventInspectorModalState();
// }
//
// class _EventInspectorModalState extends State<EventInspectorModal> {
//   // tracks which panels are expanded when using ExpansionPanelList
//   final Set<int> _expanded = {};
//
//   @override
//   Widget build(BuildContext context) {
//     return BlocBuilder<ScrapeStoryBloc, BaseScrapeState>(
//       bloc: sl.get<ScrapeStoryBloc>(),
//       buildWhen: (previous, current) =>
//           previous != current || previous.events.length < current.events.length,
//       builder: (BuildContext context, state) {
//         final events = state.events.reversed.toList();
//
//         return Container(
//           decoration: BoxDecoration(
//             color: AppPalette.primaryLight.withOpacity(0.5),
//             image: DecorationImage(
//               repeat: ImageRepeat.repeat,
//               image: AssetImage("assets/images/texture_5.png"),
//               fit: BoxFit.none,
//               opacity: 0.1,
//             ),
//           ),
//           height: MediaQuery.of(context).size.height * 0.80,
//           child: Column(
//             children: [
//               _InspectorHeader(
//                 count: events.length,
//                 onExpandAll: () => setState(
//                   () =>
//                       _expanded..addAll(List.generate(events.length, (i) => i)),
//                 ),
//                 onCollapseAll: () => setState(() => _expanded.clear()),
//                 onCopyAll: () async {
//                   final pretty = const JsonEncoder.withIndent(
//                     '  ',
//                   ).convert(events.map((e) => e.toJson()).toList());
//                   await Clipboard.setData(ClipboardData(text: pretty));
//                 },
//               ),
//               const Divider(height: 1, color: AppPalette.primary),
//               Expanded(
//                 child: Container(
//                   color: Colors.white,
//                   child: ListView.builder(
//                     padding: const EdgeInsets.only(bottom: 16),
//                     itemCount: events.length,
//                     itemBuilder: (context, index) {
//                       final vm = events[index];
//                       final isOpen = _expanded.contains(index);
//                       return _EventTile(
//                         vm: vm,
//                         isExpanded: isOpen,
//                         onToggle: () => setState(() {
//                           if (isOpen) {
//                             _expanded.remove(index);
//                           } else {
//                             _expanded.add(index);
//                           }
//                         }),
//                       );
//                     },
//                   ),
//                 ),
//               ),
//             ],
//           ),
//         );
//       },
//     );
//   }
// }

// A single modal that works with ANY BaseScrapeBloc<TRes>
class EventInspectorModal<TRes> extends StatefulWidget {
  const EventInspectorModal({super.key, required this.bloc});

  final BaseScrapeBloc<TRes> bloc;

  @override
  State<EventInspectorModal<TRes>> createState() =>
      _EventInspectorModalState<TRes>();
}

class _EventInspectorModalState<TRes> extends State<EventInspectorModal<TRes>> {
  final Set<int> _expanded = {};

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<BaseScrapeBloc<TRes>, BaseScrapeState<TRes>>(
      bloc: widget.bloc, // << pass the specific instance
      buildWhen: (prev, next) =>
          prev.events.length != next.events.length ||
          prev.status != next.status ||
          !identical(prev.result, next.result),
      builder: (_, state) {
        final events = state.events.reversed.toList();

        // print("len events ${events.length}");
        return Container(
          decoration: BoxDecoration(
            color: AppPalette.primaryLight.withOpacity(0.5),
            image: const DecorationImage(
              repeat: ImageRepeat.repeat,
              image: AssetImage("assets/images/texture_5.png"),
              fit: BoxFit.none,
              opacity: 0.1,
            ),
          ),
          height: MediaQuery.of(context).size.height * 0.80,
          child: Column(
            children: [
              _InspectorHeader(
                // title: widget.title ?? 'Events',
                count: events.length,
                onExpandAll: () => setState(
                  () =>
                      _expanded..addAll(List.generate(events.length, (i) => i)),
                ),
                onCollapseAll: () => setState(() => _expanded.clear()),
                onCopyAll: () async {
                  final pretty = const JsonEncoder.withIndent(
                    '  ',
                  ).convert(events.map((e) => e.toJson()).toList());
                  await Clipboard.setData(ClipboardData(text: pretty));
                },
              ),
              const Divider(height: 1, color: AppPalette.primary),
              Expanded(
                child: Container(
                  color: Colors.white,
                  child: ListView.builder(
                    padding: const EdgeInsets.only(bottom: 16),
                    itemCount: events.length,
                    itemBuilder: (context, index) {
                      final vm = events[index];
                      final isOpen = _expanded.contains(index);
                      return _EventTile(
                        vm: vm,
                        isExpanded: isOpen,
                        onToggle: () => setState(() {
                          isOpen
                              ? _expanded.remove(index)
                              : _expanded.add(index);
                        }),
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

class _InspectorHeader extends StatelessWidget {
  const _InspectorHeader({
    required this.count,
    required this.onExpandAll,
    required this.onCollapseAll,
    required this.onCopyAll,
  });

  final int count;
  final VoidCallback onExpandAll;
  final VoidCallback onCollapseAll;
  final VoidCallback onCopyAll;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(),
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      child: Row(
        children: [
          const Icon(Icons.timeline, color: AppPalette.primary),
          const SizedBox(width: 8),
          Text(
            'Events ($count)',
            style: Theme.of(context).textTheme.titleMedium,
          ),
          const Spacer(),
          Tooltip(
            message: 'Expand all',
            child: IconButton(
              onPressed: onExpandAll,
              icon: const Icon(Icons.unfold_more, color: AppPalette.primary),
            ),
          ),
          Tooltip(
            message: 'Collapse all',
            child: IconButton(
              onPressed: onCollapseAll,
              icon: const Icon(Icons.unfold_less, color: AppPalette.primary),
            ),
          ),
          Tooltip(
            message: 'Copy all',
            child: IconButton(
              onPressed: onCopyAll,
              icon: const Icon(Icons.copy_all, color: AppPalette.primary),
            ),
          ),
          const SizedBox(width: 4),
          IconButton(
            tooltip: 'Close',
            onPressed: () => Navigator.of(context).maybePop(),
            icon: const Icon(Icons.close, color: AppPalette.primary),
          ),
        ],
      ),
    );
  }
}

class _EventTile extends StatelessWidget {
  const _EventTile({
    required this.vm,
    required this.isExpanded,
    required this.onToggle,
  });

  final ScrapeEvent vm;
  final bool isExpanded;
  final VoidCallback onToggle;

  @override
  Widget build(BuildContext context) {
    final color = _getEventColor(vm.name);

    return Container(
      padding: EdgeInsets.symmetric(horizontal: 5),
      color: isExpanded ? Colors.grey.shade100 : Colors.white,
      child: Column(
        children: [
          GestureDetector(
            onTap: onToggle,
            child: ListTile(
              dense: true,
              // leading: Icon(vm.icon, color: iconColor),
              title: Align(
                alignment: AlignmentGeometry.centerLeft,
                widthFactor: 1,
                child: Container(
                  padding: EdgeInsets.symmetric(vertical: 1, horizontal: 10),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(5),
                    border: BoxBorder.all(color: color.withAlpha(100)),
                    color: color.withAlpha(20),
                  ),
                  child: Text(
                    vm.name,
                    maxLines: 1,
                    style: TextStyle(
                      fontSize: 12,
                      fontFamily: "IBM_Plex_Mono",
                      color: color,
                      fontWeight: FontWeight.w500,
                    ),
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ),
              // subtitle: Text(vm.subtitle ?? ''),
              trailing: Row(
                mainAxisSize: MainAxisSize.min,
                spacing: 10,
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 8,
                      vertical: 2,
                    ),
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(12),
                      color: Colors.black12,
                    ),
                    child: Text(
                      DateFormat(
                        "HH:mm:ss.SSS",
                      ).format(vm.receivedAt).toString(),
                      style: Theme.of(context).textTheme.labelSmall?.copyWith(
                        fontSize: 10,
                        color: Colors.black,
                        fontFamily: "IBM_Plex_Mono",
                      ),
                    ),
                  ),
                  IconButton(
                    tooltip: isExpanded ? 'Collapse' : 'Expand',
                    icon: Icon(
                      isExpanded ? Icons.expand_less : Icons.expand_more,
                    ),
                    iconSize: 16,
                    padding: EdgeInsets.zero,
                    constraints: const BoxConstraints.tightFor(
                      width: 24,
                      height: 24,
                    ),

                    onPressed: onToggle,
                  ),
                ],
              ),
            ),
          ),
          if (isExpanded) const Divider(height: 1),
          if (isExpanded)
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 10, 8, 12),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(
                    child: ConstrainedBox(
                      constraints: BoxConstraints(
                        maxHeight: MediaQuery.of(context).size.height / 2,
                      ),

                      child: JsonView.string(
                        vm.payload,

                        theme: JsonViewTheme(
                          loadingWidget: Loader(),
                          // errorBuilder: (ctx, err) => ,
                          backgroundColor: AppPalette.transparent,
                          separator: Divider(),

                          intStyle: TextStyle(color: _postmanGreen),
                          doubleStyle: TextStyle(color: _postmanGreen),
                          boolStyle: TextStyle(
                            color: _postmanBlue,
                            fontWeight: FontWeight.bold,
                          ),
                          stringStyle: TextStyle(
                            color: _postmanBlue,
                            // fontWeight: FontWeight.bold
                          ),
                          keyStyle: TextStyle(color: _postmanRed),

                          openIcon: const Icon(
                            Icons.keyboard_arrow_right_outlined,
                            size: 16,
                            color: Colors.black,
                          ),
                          closeIcon: const Icon(
                            Icons.keyboard_arrow_down_outlined,
                            size: 16,
                            color: Colors.black,
                          ),
                          viewType: JsonViewType.collapsible,
                          defaultTextStyle: TextStyle(
                            color: Colors.black,
                            fontSize: 12,
                            // color: Color.fromARGB(1, 34, 80, 159),
                            fontFamily: "IBM_Plex_Mono",
                          ),
                        ),
                      ),
                    ),
                  ),

                  IconButton(
                    iconSize: 16,
                    padding: EdgeInsets.zero,
                    constraints: const BoxConstraints.tightFor(
                      width: 24,
                      height: 24,
                    ),

                    tooltip: 'Copy',
                    onPressed: () async {
                      // final text = vm.isJson
                      //     ? (vm.payloadAsPrettyJson ?? '{}')
                      //     : (vm.payloadAsText ?? '');
                      final text = vm.payload;

                      await Clipboard.setData(ClipboardData(text: text));
                    },
                    icon: const Icon(Icons.copy),
                  ),
                ],
              ),
            ),
          Divider(height: 1.2, color: Colors.grey.shade300),
        ],
      ),
    );
  }

  static final Color _postmanBlue = Color.fromARGB(255, 34, 80, 159);
  static final Color _postmanRed = Color.fromARGB(255, 159, 58, 52);
  static final Color _postmanGreen = Color.fromARGB(255, 66, 136, 97);

  static final Color _blue = Color(0xFF084288);
  static final Color _red = Color(0xFF5E0E08);
  static final Color _orange = Color(0xFF8E2700);
  static final Color _lightGreen = Color(0xFF638E71);
  static final Color _darkGreen = Color(0xFF15522E);
  static final Color _pink = Color(0xFFA40259);
  static final Color _purple = Color(0xFF482975);
  static final Color _aqua = Color(0xFF0C5E66);
  static final Color _mustered = Color(0xFF7F5F00);

  Color _getEventColor(String eventName) {
    switch (eventName) {
      case "started":
        return _blue;
      case "story.scrape.start":
        return _orange;
      case "log":
        return _lightGreen;
      case "story.scrape.done":
        return _purple;
      case "story.db.insert.start":
        return _pink;
      case "story.db.insert.done":
        return _mustered;
      case "story.db.schema.start":
        return _red;
      case "story.db.schema.done":
        return _darkGreen;
      case "story.fs.mkdir.start":
        return _blue;
      case "story.fs.mkdir.done":
        return _orange;
      case "story.fs.move.start":
        return _aqua;
      case "story.fs.move.done":
        return _purple;
      case "cleanup.start":
        return _pink;
      case "cleanup.done":
        return _mustered;
      case "finished":
        return _red;
      default:
        return Colors.black;
    }
  }
}
