import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:locallibrary/wattpad_publisher/bloc/base_scrape_bloc.dart';

import '../../core/commen/clipboard.dart';
import '../../core/theme/app_palette.dart';
import '../../core/theme/theme.dart';
import '../../dependency_ingection.dart';
import '../bloc/scrape_story_bloc.dart';
import '../modals/logs_modal.dart';
import '../models/server_models.dart';
import '../widgets/inner_shadow_gradient_pane.dart';
import '../widgets/input_bars.dart';
import '../widgets/rounded_content_outer.dart';
import '../widgets/scraped_story_info_view.dart';
import '../widgets/split_filled_button.dart';

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

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback(
      (_) => _prefillFromClipboard(),
    );
  }

  Future<void> _prefillFromClipboard() async {
    final bloc = sl.get<ScrapeStoryBloc>();

    // Don’t overwrite if user or state already has something
    if (_urlCtrl.text.trim().isNotEmpty || bloc.state.input.trim().isNotEmpty)
      return;

    final raw = (await ClipboardService().getFromClipboard())?.trim() ?? '';
    if (raw.isEmpty) return;

    final msg = validateStoryUrlMessage(raw);
    if (msg != null) return; // not a Wattpad story link

    final url = raw;
    _urlCtrl.text = url;
    bloc.add(InputChanged(url));
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
      child:
          // Main content and BLoC wiring
          BlocConsumer<ScrapeStoryBloc, BaseScrapeState<ScrapeStoryRes>>(
            bloc: sl.get<ScrapeStoryBloc>(),
            listenWhen: (prev, next) =>
                prev.errorMessage != next.errorMessage ||
                prev.status != next.status ||
                prev.result != next.result,
            listener: (context, state) async {
              if (state.status == ScrapeStatus.done && state.result != null) {
                final storyId = state.result!.story.story.storyId;

                // await openStory(storyId);
                // sl.get<WindowsBloc>().add(OpenWindowRequested.story(storyId));
                // AppWindows.openStoryWindow(
                //   storyId: state.result!.story.story.storyId,
                // );

                // await closeNamed("scrape");
                // _closeThisWindow();

                // debugPrint("parent id : $parentId");
                // // 2) Optionally tell parent which story opened
                // if (parentId != null) {
                //   try {
                //     await DesktopMultiWindow.invokeMethod(
                //       parentId!,
                //       'scrape_closed',
                //       {'story_id': storyId},
                //     );
                //   } catch (_) {}
                // }

                // ScrapeStoryAppWindow.I.markClosed(ScrapeStoryAppWindow.I.id.value!);
              }
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
                prev.input != next.input ||
                prev.inputHint != next.inputHint ||
                prev.errorMessage != next.errorMessage ||
                prev.status != next.status,

            builder: (context, state) {
              final showButton =
                  state.status == ScrapeStatus.connecting ||
                  state.status == ScrapeStatus.streaming ||
                  state.status == ScrapeStatus.error;

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
                          ..text = state.input
                          ..selection = TextSelection.fromPosition(
                            TextPosition(offset: state.input.length),
                          ),
                        onChanged: (v) =>
                            sl.get<ScrapeStoryBloc>().add(InputChanged(v)),
                        onSubmit: () =>
                            sl.get<ScrapeStoryBloc>().add(StartRequested()),
                        onPasteRequested: () async {
                          final data = await ClipboardService()
                              .getFromClipboard();
                          final txt = data?.trim() ?? '';
                          if (txt.isEmpty) return;
                          final url = txt;
                          _urlCtrl.text = url;
                          sl.get<ScrapeStoryBloc>().add(InputChanged(url));
                        },
                      ),

                      // Soft hint while typing (not red)
                      if (state.inputHint != null &&
                          state.inputHint!.isNotEmpty)
                        Text(
                          state.inputHint!,
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
                      // if (showButton)
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        spacing: 10,
                        children: [
                          SplitFilledButton(
                            status: state.status,
                            onPrimaryTap: () {
                              WidgetsBinding.instance.addPostFrameCallback((_) {
                                openScrapeEventsModal<ScrapeStoryRes>(
                                  context: context,
                                  bloc: sl.get<ScrapeStoryBloc>(),
                                );
                              });
                            },
                            onSecondary: () => sl.get<ScrapeStoryBloc>().add(
                              CancelRequested(),
                            ),
                          ),
                        ],
                      ),

                      if (state.status == ScrapeStatus.done &&
                          state.result != null)
                        Expanded(child: ScrapedStoryInfo(res: state.result!)),
                    ],
                  ),
                ),
              );
            },
          ),
    );
  }
}
