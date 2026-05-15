import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:locallibrary/wattpad_publisher/bloc/base_scrape_bloc.dart';

import '../../core/commen/clipboard.dart';
import '../../core/exstentions/scrape_status.dart';
import '../../core/theme/app_palette.dart';
import '../../dependency_ingection.dart';
import '../bloc/scrape_story_bloc.dart';
import '../cubit/navigation_cubit.dart';
import '../datasource.dart';
import '../modals/logs_modal.dart';
import '../models/server_models.dart';
import '../widgets/scraped_story_info_view.dart';

class ScrapeStoryScreen extends StatelessWidget {
  const ScrapeStoryScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => context.read<NavigationCubit>().pop(),
        ),
        title: const Text('Add Story'),
        centerTitle: false,
        elevation: 0,
        backgroundColor: Colors.transparent,
      ),
      body: _ScrapeStoryView(),
    );
  }
}

class _ScrapeStoryView extends StatefulWidget {
  const _ScrapeStoryView();

  @override
  State<_ScrapeStoryView> createState() => _ScrapeStoryViewState();
}

class _ScrapeStoryViewState extends State<_ScrapeStoryView> {
  final _urlCtrl = TextEditingController();
  StoryBundle? _bundle;

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
      listenWhen: (prev, next) =>
      prev.errorMessage != next.errorMessage ||
          prev.status != next.status ||
          prev.result != next.result,
      listener: (context, state) async {
        if (state.status == ScrapeStatus.connecting) {
          setState(() => _bundle = null);
        }
        if (state.status == ScrapeStatus.done && state.result != null) {
          final storyId = state.result!.story.story.storyId;
          try {
            final bundle =
            await sl.get<AppApiDataSource>().getFullStoryInfo(storyId);
            if (mounted) setState(() => _bundle = bundle);
          } catch (_) {}
        }
      },
      buildWhen: (prev, next) =>
      prev.input != next.input ||
          prev.inputHint != next.inputHint ||
          prev.errorMessage != next.errorMessage ||
          prev.status != next.status,
      builder: (context, state) {
        if (state.status == ScrapeStatus.done && state.result != null) {
          return SizedBox.expand(
            child: ScrapedStoryInfo(res: state.result!, bundle: _bundle),
          );
        }

        return Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
            child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                spacing: 16,
                children: [
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
                  if (state.errorMessage != null &&
                      state.errorMessage!.isNotEmpty)
                    Text(
                      state.errorMessage!,
                      style: TextStyle(color: AppPalette.error),
                    ),
                  Center(child: _ScrapeActions(
                    status: state.status,
                    onStart: () =>
                        sl.get<ScrapeStoryBloc>().add(StartRequested()),
                    onViewLogs: () =>
                        WidgetsBinding.instance
                            .addPostFrameCallback((_) =>
                            openScrapeEventsModal<ScrapeStoryRes>(
                              context: context,
                              bloc: sl.get<ScrapeStoryBloc>(),
                            )),
                    onCancel: () =>
                        sl.get<ScrapeStoryBloc>().add(CancelRequested()),
                    onReset: () => sl.get<ScrapeStoryBloc>().reset(),
                  )
                  )
                ]
            )
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