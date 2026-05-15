import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:locallibrary/core/extensions/scrape_status.dart';

import '../../../core/common/clipboard.dart';
import '../../../core/theme/app_palette.dart';
import '../../../dependency_injection.dart';
import '../../library/cubit/navigation_cubit.dart';
import '../bloc/base_scrape_bloc.dart';
import '../bloc/scrape_story_bloc.dart';
import '../models/story_dto.dart';
import '../widgets/scrape_logs_dialog.dart';

/// Full-page route variant — used by GoRouter (e.g. desktop sub-window).
class ScrapeStoryScreen extends StatelessWidget {
  const ScrapeStoryScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Add Story'),
        centerTitle: false,
        elevation: 0,
        backgroundColor: Colors.transparent,
      ),
      body: const _ScrapeStoryView(isSheet: false),
    );
  }
}

void showScrapeSheet(BuildContext context) {
  showModalBottomSheet<void>(
    context: context,
    isScrollControlled: true,
    useRootNavigator: true,
    shape: const RoundedRectangleBorder(
      borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
    ),
    builder: (_) =>
        BlocProvider.value(
          value: context.read<NavigationCubit>(),
          child: const _ScrapeStoryView(isSheet: true),
        ),
  );
}

class _ScrapeStoryView extends StatefulWidget {
  const _ScrapeStoryView({required this.isSheet});

  final bool isSheet;

  @override
  State<_ScrapeStoryView> createState() => _ScrapeStoryViewState();
}

class _ScrapeStoryViewState extends State<_ScrapeStoryView> {
  final _urlCtrl = TextEditingController();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) =>
        _prefillFromClipboard());
  }

  @override
  void dispose() {
    _urlCtrl.dispose();
    sl.get<ScrapeStoryBloc>().reset();
    super.dispose();
  }

  Future<void> _prefillFromClipboard() async {
    final bloc = sl.get<ScrapeStoryBloc>();
    if (_urlCtrl.text
        .trim()
        .isNotEmpty || bloc.state.input
        .trim()
        .isNotEmpty) {
      return;
    }
    final raw = (await ClipboardService().getFromClipboard())?.trim() ?? '';
    if (raw.isEmpty) return;
    if (validateStoryUrlMessage(raw) != null) return;
    _urlCtrl.text = raw;
    bloc.add(InputChanged(raw));
  }

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<ScrapeStoryBloc, BaseScrapeState<ScrapeStoryRes>>(
      bloc: sl.get<ScrapeStoryBloc>(),
      listenWhen: (prev, next) => prev.status != next.status,
      listener: (context, state) {
        if (state.status == ScrapeStatus.done && state.result != null) {
          final res = state.result!;
          if (widget.isSheet) {
            final nav = context.read<NavigationCubit>();
            Navigator.of(context).popUntil((route) => route.isFirst);
            nav.push(NavigationScrapeStoryCubit(
              storyId: res.story.story.storyId,
              scrapeRes: res,
            ));
          } else {
            context.read<NavigationCubit>().push(NavigationScrapeStoryCubit(
              storyId: res.story.story.storyId,
              scrapeRes: res,
            ));
          }
        }
      },
      buildWhen: (prev, next) =>
      prev.input != next.input ||
          prev.inputHint != next.inputHint ||
          prev.errorMessage != next.errorMessage ||
          prev.status != next.status,
      builder: (context, state) {
        final isSheet = widget.isSheet;
        final bottomInset = isSheet ? MediaQuery
            .of(context)
            .viewInsets
            .bottom : 0.0;
        return Padding(
          padding: EdgeInsets.fromLTRB(
              24, isSheet ? 0 : 16, 24, 24 + bottomInset),
          child: Column(
            mainAxisSize: isSheet ? MainAxisSize.min : MainAxisSize.max,
            crossAxisAlignment: CrossAxisAlignment.start,
            spacing: 16,
            children: [
              if (isSheet) ...[
                Center(
                  child: Container(
                    margin: const EdgeInsets.symmetric(vertical: 12),
                    width: 40,
                    height: 4,
                    decoration: BoxDecoration(
                      color: Colors.grey.shade300,
                      borderRadius: BorderRadius.circular(2),
                    ),
                  ),
                ),
                Text('Add Story', style: Theme
                    .of(context)
                    .textTheme
                    .titleLarge),
              ],
              TextField(
                controller: _urlCtrl
                  ..text = state.input
                  ..selection = TextSelection.fromPosition(
                    TextPosition(offset: state.input.length),
                  ),
                onChanged: (v) =>
                    sl.get<ScrapeStoryBloc>().add(InputChanged(v)),
                onSubmitted: (_) =>
                    sl.get<ScrapeStoryBloc>().add(StartRequested()),
                decoration: InputDecoration(
                  hintText: 'https://www.wattpad.com/story/...',
                  hintStyle: TextStyle(color: AppPalette.gray),
                  border: const OutlineInputBorder(),
                  suffixIcon: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      IconButton(
                        tooltip: 'Paste',
                        icon: const Icon(Icons.content_paste, size: 18),
                        onPressed: () async {
                          final data =
                              await ClipboardService().getFromClipboard();
                          final txt = data?.trim() ?? '';
                          if (txt.isEmpty) return;
                          _urlCtrl.text = txt;
                          sl.get<ScrapeStoryBloc>().add(InputChanged(txt));
                        },
                      ),
                      IconButton(
                        tooltip: 'Go',
                        icon: const Icon(Icons.arrow_forward, size: 18),
                        onPressed: () =>
                            sl.get<ScrapeStoryBloc>().add(StartRequested()),
                      ),
                    ],
                  ),
                ),
              ),
              if (state.inputHint != null && state.inputHint!.isNotEmpty)
                Text(
                  state.inputHint!,
                  style: TextStyle(color: AppPalette.error),
                ),
              if (state.errorMessage != null && state.errorMessage!.isNotEmpty)
                Text(
                  state.errorMessage!,
                  style: TextStyle(color: AppPalette.error),
                ),
              Center(
                child: _ScrapeActions(
                  status: state.status,
                  onStart: () =>
                      sl.get<ScrapeStoryBloc>().add(StartRequested()),
                  onViewLogs: () =>
                      WidgetsBinding.instance
                          .addPostFrameCallback(
                            (_) =>
                            openScrapeEventsModal<ScrapeStoryRes>(
                              context: context,
                              bloc: sl.get<ScrapeStoryBloc>(),
                            ),
                      ),
                  onCancel: () =>
                      sl.get<ScrapeStoryBloc>().add(CancelRequested()),
                  onReset: () => sl.get<ScrapeStoryBloc>().reset(),
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}

class _ScrapeActions extends StatelessWidget {
  const _ScrapeActions({
    required this.status,
    required this.onStart,
    required this.onViewLogs,
    required this.onCancel,
    required this.onReset,
  });

  final ScrapeStatus status;
  final VoidCallback onStart;
  final VoidCallback onViewLogs;
  final VoidCallback onCancel;
  final VoidCallback onReset;

  @override
  Widget build(BuildContext context) {
    return AnimatedSwitcher(
      duration: const Duration(milliseconds: 220),
      child: switch (status) {
        ScrapeStatus.idle =>
            FilledButton.icon(
              key: const ValueKey('idle'),
              onPressed: onStart,
              icon: status.indicator,
              label: const Text('Scrape'),
            ),
        ScrapeStatus.connecting || ScrapeStatus.streaming =>
            Row(
              key: const ValueKey('active'),
              mainAxisSize: MainAxisSize.min,
              spacing: 8,
              children: [
                FilledButton.icon(
                  onPressed: onViewLogs,
                  icon: status.indicator,
                  label: const Text('View Logs'),
                ),
                OutlinedButton(
                  onPressed: onCancel,
                  child: const Text('Cancel'),
                ),
              ],
            ),
        ScrapeStatus.done =>
            Row(
              key: const ValueKey('done'),
              mainAxisSize: MainAxisSize.min,
              spacing: 8,
              children: [
                FilledButton.icon(
                  onPressed: onViewLogs,
                  icon: status.indicator,
                  label: const Text('View Logs'),
                ),
                TextButton(
                  onPressed: onReset,
                  child: const Text('Start Over'),
                ),
              ],
            ),
        ScrapeStatus.error =>
            Row(
              key: const ValueKey('error'),
              mainAxisSize: MainAxisSize.min,
              spacing: 8,
              children: [
                FilledButton.icon(
                  onPressed: onViewLogs,
                  icon: status.indicator,
                  label: const Text('View Logs'),
                ),
                TextButton(
                  onPressed: onReset,
                  child: const Text('Try Again'),
                ),
              ],
            ),
      },
    );
  }
}