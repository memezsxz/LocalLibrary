import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_json_view/flutter_json_view.dart';
import 'package:intl/intl.dart';

import '../../../core/common/widgets/loader.dart';
import '../../../core/theme/app_palette.dart';
import '../bloc/base_scrape_bloc.dart';
import '../bloc/base_scrape_state.dart';
import '../models/scrape/scrape_event_model.dart';

// ─── open helper ──────────────────────────────────────────────────────────────

void openScrapeEventsModal<TRes>({
  required BuildContext context,
  required BaseScrapeBloc<TRes> bloc,
}) {
  final isMobile = MediaQuery.of(context).size.width < 600;

  if (isMobile) {
    showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      useSafeArea: true,
      useRootNavigator: true,
      backgroundColor: Colors.transparent,
      builder: (_) => DraggableScrollableSheet(
        initialChildSize: 0.75,
        minChildSize: 0.4,
        maxChildSize: 0.95,
        expand: false,
        builder: (_, scrollController) => ClipRRect(
          borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
          child: EventInspectorModal<TRes>(
            bloc: bloc,
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
            maxWidth: MediaQuery.of(context).size.width * 0.65,
            minHeight: MediaQuery.of(context).size.height * 0.75,
            maxHeight: MediaQuery.of(context).size.height * 0.75,
          ),
          child: EventInspectorModal<TRes>(bloc: bloc),
        ),
      ),
    );
  }
}

// ─── modal ────────────────────────────────────────────────────────────────────

class EventInspectorModal<TRes> extends StatefulWidget {
  const EventInspectorModal({
    super.key,
    required this.bloc,
    this.scrollController,
    this.isSheet = false,
  });

  final BaseScrapeBloc<TRes> bloc;
  final ScrollController? scrollController;
  final bool isSheet;

  @override
  State<EventInspectorModal<TRes>> createState() =>
      _EventInspectorModalState<TRes>();
}

class _EventInspectorModalState<TRes> extends State<EventInspectorModal<TRes>> {
  final Set<int> _expanded = {};

  void _expandAll(List<ScrapeEvent> events) {
    setState(() {
      _expanded.addAll(List.generate(events.length, (i) => i));
    });
  }

  void _collapseAll() {
    setState(() => _expanded.clear());
  }

  Future<void> _copyAll(List<ScrapeEvent> events) async {
    final pretty = const JsonEncoder.withIndent('  ')
        .convert(events.map((e) => e.toJson()).toList());
    await Clipboard.setData(ClipboardData(text: pretty));
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<BaseScrapeBloc<TRes>, BaseScrapeState<TRes>>(
      bloc: widget.bloc,
      buildWhen: (p, n) =>
      p.events.length != n.events.length || p.status != n.status,
      builder: (_, state) {
        final events = state.events.reversed.toList();

        return Material(
          color: Colors.white,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              if (widget.isSheet)
                Padding(
                  padding: const EdgeInsets.only(top: 10, bottom: 4),
                  child: Center(
                    child: Container(
                      width: 40,
                      height: 4,
                      decoration: BoxDecoration(
                        color: Colors.grey.shade300,
                        borderRadius: BorderRadius.circular(2),
                      ),
                    ),
                  ),
                ),
              _InspectorHeader(
                onExpandAll: () => _expandAll(events),
                onCollapseAll: _collapseAll,
                onCopyAll: () => _copyAll(events),
                onClose: () => Navigator.of(context).maybePop(),
              ),
              const Divider(height: 1),
              Flexible(
                child: ListView.builder(
                  controller: widget.scrollController,
                  shrinkWrap: widget.scrollController == null,
                  padding: const EdgeInsets.only(bottom: 16),
                  itemCount: events.isEmpty ? 1 : events.length,
                  itemBuilder: (context, index) {
                    if (events.isEmpty) {
                      return Padding(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 16, vertical: 12),
                        child: Text(
                          state.status == ScrapeStatus.idle
                              ? 'Not started'
                              : 'Waiting for events…',
                          style: const TextStyle(
                              fontSize: 12, color: AppPalette.gray),
                        ),
                      );
                    }
                    final isExpanded = _expanded.contains(index);
                    return _EventTile(
                      vm: events[index],
                      isExpanded: isExpanded,
                      onToggle: () => setState(() {
                        isExpanded
                            ? _expanded.remove(index)
                            : _expanded.add(index);
                      }),
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

// ─── header ───────────────────────────────────────────────────────────────────

class _InspectorHeader extends StatelessWidget {
  const _InspectorHeader({
    required this.onExpandAll,
    required this.onCollapseAll,
    required this.onCopyAll,
    required this.onClose,
  });

  final VoidCallback onExpandAll;
  final VoidCallback onCollapseAll;
  final VoidCallback onCopyAll;
  final VoidCallback onClose;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      child: Row(
        children: [
          const Icon(Icons.timeline, size: 18, color: AppPalette.primary),
          const SizedBox(width: 8),
          Text(
            'Scrape Logs',
            style: Theme.of(context).textTheme.titleMedium,
          ),
          const Spacer(),
          IconButton(
            tooltip: 'Expand all',
            onPressed: onExpandAll,
            icon: const Icon(Icons.unfold_more, size: 18),
            color: AppPalette.primary,
            visualDensity: VisualDensity.compact,
          ),
          IconButton(
            tooltip: 'Collapse all',
            onPressed: onCollapseAll,
            icon: const Icon(Icons.unfold_less, size: 18),
            color: AppPalette.primary,
            visualDensity: VisualDensity.compact,
          ),
          IconButton(
            tooltip: 'Copy all',
            onPressed: onCopyAll,
            icon: const Icon(Icons.copy_all, size: 18),
            color: AppPalette.primary,
            visualDensity: VisualDensity.compact,
          ),
          IconButton(
            tooltip: 'Close',
            onPressed: onClose,
            icon: const Icon(Icons.close, size: 18),
            color: AppPalette.primary,
            visualDensity: VisualDensity.compact,
          ),
        ],
      ),
    );
  }
}

// ─── event tile ───────────────────────────────────────────────────────────────

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
      padding: const EdgeInsets.symmetric(horizontal: 5),
      color: isExpanded ? Colors.grey.shade50 : Colors.white,
      child: Column(
        children: [
          GestureDetector(
            onTap: onToggle,
            child: ListTile(
              dense: true,
              title: Align(
                alignment: AlignmentGeometry.centerLeft,
                widthFactor: 1,
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    vertical: 1,
                    horizontal: 10,
                  ),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(5),
                    border: Border.all(color: color.withAlpha(100)),
                    color: color.withAlpha(20),
                  ),
                  child: Text(
                    vm.name,
                    maxLines: 1,
                    style: TextStyle(
                      fontSize: 12,
                      fontFamily: 'IBM_Plex_Mono',
                      color: color,
                      fontWeight: FontWeight.w500,
                    ),
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ),
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
                      DateFormat('HH:mm:ss.SSS').format(vm.receivedAt),
                      style:
                      Theme
                          .of(context)
                          .textTheme
                          .labelSmall
                          ?.copyWith(
                        fontSize: 10,
                        color: Colors.black,
                        fontFamily: 'IBM_Plex_Mono',
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
                      child: _isJsonObject(vm.payload)
                          ? JsonView.string(
                        _sanitizeNulls(vm.payload),
                        theme: JsonViewTheme(
                          loadingWidget: Loader(),
                          backgroundColor: AppPalette.transparent,
                          separator: const Divider(),
                          intStyle: TextStyle(color: _postmanGreen),
                          doubleStyle: TextStyle(color: _postmanGreen),
                          boolStyle: TextStyle(
                            color: _postmanBlue,
                            fontWeight: FontWeight.bold,
                          ),
                          stringStyle: TextStyle(color: _postmanBlue),
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
                          defaultTextStyle: const TextStyle(
                            color: Colors.black,
                            fontSize: 12,
                            fontFamily: 'IBM_Plex_Mono',
                          ),
                        ),
                      )
                          : SingleChildScrollView(
                        child: Text(
                          vm.payload,
                          style: const TextStyle(
                            fontSize: 12,
                            fontFamily: 'IBM_Plex_Mono',
                            color: Colors.black87,
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
                      await Clipboard.setData(
                          ClipboardData(text: vm.payload));
                    },
                    icon: const Icon(Icons.copy),
                  ),
                ],
              ),
            ),
          Divider(height: 1.2, color: Colors.grey.shade200),
        ],
      ),
    );
  }

  static bool _isJsonObject(String s) {
    try {
      final v = jsonDecode(s);
      return v is Map || v is List;
    } catch (_) {
      return false;
    }
  }

  static String _sanitizeNulls(String s) {
    try {
      final v = jsonDecode(s);
      return jsonEncode(_replaceNulls(v));
    } catch (_) {
      return s;
    }
  }

  static dynamic _replaceNulls(dynamic v) {
    if (v == null) return 'null';
    if (v is Map) {
      return {for (final e in v.entries) e.key: _replaceNulls(e.value)};
    }
    if (v is List) return v.map(_replaceNulls).toList();
    return v;
  }

  static final Color _postmanBlue = const Color.fromARGB(255, 34, 80, 159);
  static final Color _postmanRed = const Color.fromARGB(255, 159, 58, 52);
  static final Color _postmanGreen = const Color.fromARGB(255, 66, 136, 97);

  static final Color _blue = const Color(0xFF084288);
  static final Color _red = const Color(0xFF5E0E08);
  static final Color _orange = const Color(0xFF8E2700);
  static final Color _lightGreen = const Color(0xFF638E71);
  static final Color _darkGreen = const Color(0xFF15522E);
  static final Color _pink = const Color(0xFFA40259);
  static final Color _purple = const Color(0xFF482975);
  static final Color _aqua = const Color(0xFF0C5E66);
  static final Color _mustered = const Color(0xFF7F5F00);

  Color _getEventColor(String eventName) {
    switch (eventName) {
      case 'started':
        return _blue;
      case 'story.scrape.start':
        return _orange;
      case 'log':
        return _lightGreen;
      case 'story.scrape.done':
        return _purple;
      case 'story.db.insert.start':
        return _pink;
      case 'story.db.insert.done':
        return _mustered;
      case 'story.db.schema.start':
        return _red;
      case 'story.db.schema.done':
        return _darkGreen;
      case 'story.fs.mkdir.start':
        return _blue;
      case 'story.fs.mkdir.done':
        return _orange;
      case 'story.fs.move.start':
        return _aqua;
      case 'story.fs.move.done':
        return _purple;
      case 'cleanup.start':
        return _pink;
      case 'cleanup.done':
        return _mustered;
      case 'finished':
        return _red;
      default:
        return Colors.black;
    }
  }
}