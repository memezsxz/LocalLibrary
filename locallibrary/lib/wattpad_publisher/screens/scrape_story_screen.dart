import 'package:desktop_multi_window/desktop_multi_window.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_window_close/flutter_window_close.dart';
import 'package:locallibrary/core/exstentions/scrape_status.dart';
import 'package:locallibrary/core/theme/theme.dart';
import 'package:locallibrary/wattpad_publisher/bloc/scrape_story_bloc.dart';

import '../../core/theme/app_palette.dart';
import '../../dependency_ingection.dart';
import '../modals/logs_modal.dart';
import '../widgets/inner_shadow_gradient_pane.dart';
import '../widgets/input_bars.dart';
import '../widgets/rounded_content_outer.dart';

class ScrapeStoryScreen extends StatelessWidget {
  const ScrapeStoryScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(body: _ScrapeStoryView());
  }
}

class _ScrapeStoryView extends StatefulWidget {
  const _ScrapeStoryView({super.key});

  @override
  State<_ScrapeStoryView> createState() => _ScrapeStoryViewState();
}

class _ScrapeStoryViewState extends State<_ScrapeStoryView> {
  final _urlCtrl = TextEditingController();

  int? parentId;

  @override
  void initState() {
    super.initState();
    _loadArgs();
    // Set a handler that runs whenever the window is asked to close.
    FlutterWindowClose.setWindowShouldCloseHandler(() async {
      // tell parent we're closing
      if (parentId != null) {
        try {
          await DesktopMultiWindow.invokeMethod(
            parentId!,
            'scrape_closed',
            null,
          );
        } catch (_) {}
      }
      // return true to proceed with closing; false to cancel
      return true;
    });
  }

  Future<void> _loadArgs() async {
    final raw = await DesktopMultiWindow.getAllSubWindowIds();
    parentId = raw[0];
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        image: DecorationImage(
          image: AssetImage("assets/images/texture_5.png"),
          fit: BoxFit.cover,
          opacity: 0.04,
        ),
      ),
      child: Stack(
        children: [
          // Main content and BLoC wiring
          BlocConsumer<ScrapeStoryBloc, ScrapeStoryState>(
            bloc: sl.get<ScrapeStoryBloc>(),
            listenWhen: (prev, next) =>
                prev.errorMessage != next.errorMessage ||
                prev.status != next.status ||
                prev.result != next.result,
            listener: (context, state) async {
              // 1) Show errors as a toast/snackbar (side-effect)
              if (state.errorMessage != null &&
                  state.errorMessage!.isNotEmpty) {}

              // // 2) React to status changes if you want to navigate/side-effect
              // switch (state.status) {
              //   case ScrapeStatus.done:
              //     // e.g., open story window or move to next step
              //     // final storyId = state.result?.story?.id as int?; // adapt if available
              //     // if (storyId != null) context.go('/stories/$storyId');
              //     break;
              //   default:
              //     break;
              // }
            },

            // Rebuild UI for URL / error / status / timeline changes
            buildWhen: (prev, next) =>
                prev.url != next.url ||
                prev.urlHint != next.urlHint ||
                prev.errorMessage != next.errorMessage ||
                prev.status != next.status,

            builder: (context, state) {
              final isBusy =
                  state.status == ScrapeStatus.connecting ||
                  state.status == ScrapeStatus.streaming;

              return RoundedContentOuter(
                child: InnerShadowGradientPane(
                  child: Column(
                    mainAxisSize: MainAxisSize.max,
                    // mainAxisAlignment: MainAxisAlignment.start,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    spacing: 16,
                    children: [
                      // Header
                      Text(
                        "Add Story",
                        style: AppTheme.lightMode.textTheme.titleLarge
                            ?.copyWith(
                              fontSize: 20,
                              fontWeight: FontWeight.w600,
                            ),
                      ),

                      // URL input
                      UrlWidget(
                        controller: _urlCtrl
                          ..text = state.url
                          ..selection = TextSelection.fromPosition(
                            TextPosition(offset: state.url.length),
                          ),
                        onChanged: (v) =>
                            sl.get<ScrapeStoryBloc>().add(UrlChanged(v)),
                        onSubmit: () =>
                            sl.get<ScrapeStoryBloc>().add(StartRequested()),
                        onPasteRequested: () async {
                          final data = await Clipboard.getData(
                            Clipboard.kTextPlain,
                          );
                          final txt = data?.text?.trim() ?? '';
                          if (txt.isEmpty) return;
                          final url = txt;
                          _urlCtrl.text = url;
                          sl.get<ScrapeStoryBloc>().add(UrlChanged(url));
                        },
                      ),

                      // Soft hint while typing (not red)
                      if (state.urlHint != null && state.urlHint!.isNotEmpty)
                        Text(
                          state.urlHint!,
                          style: TextStyle(color: AppPalette.error),
                        ),

                      // Top-container error (explicit, not TextField error)
                      if (state.errorMessage != null &&
                          state.errorMessage!.isNotEmpty)
                        Text(
                          state.errorMessage!,
                          style: TextStyle(color: AppPalette.error),
                        ),

                      // Actions row
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        spacing: 10,
                        children: [
                          SplitFilledButton(
                            status: state.status,
                            onPrimaryTap: () {
                              WidgetsBinding.instance.addPostFrameCallback((_) {
                                openScrapeStoryEventsInspector(context);
                              });
                            },
                            onCancel: () => sl.get<ScrapeStoryBloc>().add(
                              CancelRequested(),
                            ),
                          ),

                          if (state.status == ScrapeStatus.done &&
                              state.result != null)
                            Text(state.result!.story.genre.name),
                        ],
                      ),
                    ],
                  ),
                ),
              );
            },
          ),
        ],
      ),
    );
  }
}

class SplitFilledButton extends StatelessWidget {
  const SplitFilledButton({
    super.key,
    required this.status,
    required this.onPrimaryTap, // openEventInspector
    required this.onCancel, // dispatch CancelRequested
  });

  final ScrapeStatus status;
  final VoidCallback onPrimaryTap;
  final VoidCallback onCancel;

  bool get _canCancel =>
      status == ScrapeStatus.connecting || status == ScrapeStatus.streaming;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final bg = AppPalette.primaryLight;
    final fg = AppPalette.primary;

    return Material(
      color: bg,
      borderRadius: BorderRadius.circular(12),
      child: InkWell(
        // Enable ink on the whole pill (primary action area still gets its own handler)
        borderRadius: BorderRadius.circular(12),
        onTap: onPrimaryTap,
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Primary side (status + label)
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  // status indicator (your extension getter)
                  AnimatedSwitcher(
                    duration: const Duration(milliseconds: 180),
                    child: IconTheme.merge(
                      data: IconThemeData(color: fg, size: 18),
                      child: KeyedSubtree(
                        key: ValueKey(status),
                        child: status.indicator,
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  AnimatedSwitcher(
                    duration: const Duration(milliseconds: 180),
                    child: Text(
                      status.title,
                      key: ValueKey(status.title),
                      style: theme.textTheme.labelLarge?.copyWith(
                        color: fg,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ],
              ),
            ),

            // Divider between primary/secondary
            Container(
              width: 1,
              height: 24,
              margin: const EdgeInsets.symmetric(horizontal: 4),
              color: fg.withOpacity(0.16),
            ),

            // Secondary side (Stop)
            InkResponse(
              onTap: _canCancel ? onCancel : null,
              radius: 24,
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
                child: Icon(
                  Icons.stop,
                  size: 20,
                  color: _canCancel ? fg : fg.withOpacity(0.38),
                ),
              ),
            ),
            const SizedBox(width: 2),
          ],
        ),
      ),
    );
  }
}
