import 'package:flutter/material.dart';
import 'package:flutter_inner_shadow/flutter_inner_shadow.dart';
import 'package:locallibrary/core/theme/app_palette.dart';

import '../../core/exstentions/image.dart';
import '../../dependency_ingection.dart';
import '../bloc/windows_bloc.dart';
import '../datasource.dart';
import '../models/server_models.dart';

class DashboardShelves extends StatelessWidget {
  const DashboardShelves({super.key});

  @override
  Widget build(BuildContext context) {
    final since = DateTime.now().toUtc().subtract(const Duration(days: 7));

    return Padding(
      padding: const EdgeInsets.all(10).copyWith(top: 0),
      child: SingleChildScrollView(
        clipBehavior: Clip.none,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            _ShelfSection(
              title: "Currently Reading",
              future: sl.get<AppApiDataSource>().listCurrentlyReadingStories(
                since: since,
                limit: 6,
              ),
            ),
            const SizedBox(height: 12),
            _ShelfSection(
              title: "Next",
              future: sl.get<AppApiDataSource>().listRecentlyAddedStories(
                since: since,
                limit: 6,
              ),
            ),
            const SizedBox(height: 12),
            _ShelfSection(
              title: "Finished",
              future: sl.get<AppApiDataSource>().listRecentlyFinishedStories(
                since: since,
                limit: 6,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _ShelfSection extends StatelessWidget {
  final String title;
  final Future<List<int>> future;

  const _ShelfSection({required this.title, required this.future, super.key});

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<List<int>>(
      future: future,
      builder: (context, snap) {
        if (snap.connectionState == ConnectionState.waiting) {
          return SizedBox(
            height: 160, // typical shelve height
            child: const Center(child: CircularProgressIndicator()),
          );
        }
        if (snap.hasError) {
          // TODO: show a toast/snackbar if you want
          return Shelve(title: title, storyIds: const []);
        }
        final ids = snap.data ?? const <int>[];
        return Shelve(title: title, storyIds: ids);
      },
    );
  }
}

class Shelve extends StatelessWidget {
  final String? title;
  final List<int> storyIds;

  const Shelve({super.key, this.title, required this.storyIds});

  @override
  Widget build(BuildContext context) {
    // print(storyIds);
    final tileW = MediaQuery.of(context).size.width / 20;
    final tileH = tileW * 1.75;

    return Column(
      mainAxisSize: MainAxisSize.max,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (title != null)
          Padding(
            padding: const EdgeInsets.all(8).copyWith(bottom: 20),
            child: Text(
              title!,
              style: Theme.of(
                context,
              ).textTheme.titleMedium?.copyWith(color: AppPalette.primary),
            ),
          ),
        // Give the shadow room below the shelf *inside* the panel
        Padding(
          padding: const EdgeInsets.only(bottom: 28), // space for blur
          child: SizedBox(
            height: tileH,
            child: Stack(
              clipBehavior: Clip.none,
              alignment: Alignment.bottomLeft,
              children: [
                // 1) Base strip (visible "shelf")
                Positioned(
                  left: 0,
                  right: 0,
                  bottom: 0,
                  child: InnerShadow(
                    shadows: [
                      Shadow(
                        color: Colors.black.withOpacity(0.12),
                        offset: const Offset(1, -1),
                        blurRadius: 4,
                      ),
                    ],
                    child: Container(
                      height: 20,
                      decoration: BoxDecoration(
                        gradient: const LinearGradient(
                          colors: [
                            Color(0xffFCF3E7),
                            Color(0xffF4EADD),
                            Color(0xffF1E6D8),
                          ],
                          begin: Alignment.topCenter,
                          end: Alignment.bottomCenter,
                        ),
                        borderRadius: BorderRadius.circular(2),
                      ),
                    ),
                  ),
                ),

                // 2) OUTER shadow kept *inside* the panel (not overflowing)
                //    Make it slightly above bottom so its blur remains visible.
                Positioned(
                  left: 0,
                  right: 0,
                  bottom: 2,
                  child: Container(
                    height: 20,
                    decoration: BoxDecoration(
                      // color: Colors.transparent, // not required with BoxDecoration
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.2),
                          offset: const Offset(-8, 20), // smaller offset
                          blurRadius: 30, // smaller blur
                          spreadRadius: 0,
                        ),
                      ],
                      borderRadius: BorderRadius.circular(2),
                    ),
                  ),
                ),

                // 3) Books on top
                Padding(
                  padding: const EdgeInsets.only(left: 20, bottom: 5),
                  child: Row(
                    spacing: 70,
                    children: storyIds
                        .map((id) => BookMinimalView(storyId: id))
                        .toList(),
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}

class BookMinimalView extends StatelessWidget {
  final int storyId;
  late Future<BookMinimal> book;

  // BookMinimalView({super.key, required this.storyId});

  BookMinimalView({super.key, required this.storyId})
    : book = sl<StoryRemoteDataSource>().fetchMinimal(storyId: storyId);

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<BookMinimal>(
      future: book,
      builder: (context, snap) {
        if (snap.connectionState == ConnectionState.waiting) {
          return _sizeContent(
            context,
            const Center(child: CircularProgressIndicator()),
          );
        }

        if (snap.hasError) {
          // print("snap error: ${snap.error}");

          return _sizeContent(
            context,
            Padding(
              padding: const EdgeInsets.all(16),

              child: Text('Failed to load'),
            ),
          );
        }

        final book = snap.data!;
        // print("data: ${snap.data?.image.path}");

        Widget content = Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Expanded(
              child: ClipRect(
                clipper: const _BottomOnlyClip(expand: 40),
                // allow side/top glow
                child: DecoratedBox(
                  decoration: BoxDecoration(
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.25),
                        offset: const Offset(-10, 10),
                        blurRadius: 10,
                        spreadRadius: 0,
                      ),
                    ],
                  ),
                  child: GestureDetector(
                    onTap: () {
                      // print(book.wattId);
                      // print(book.storyId);

                      sl.get<WindowsBloc>().add(
                        OpenWindowRequested.story(storyId),
                      );

                      // AppWindows.openStoryWindow(storyId: book.storyId);

                      // context.pushNamed(
                      //   'story',
                      //   pathParameters: {'story_id': '${book.storyId}'},
                      //   extra:'window', // triggers new window only when you pass it
                      // );
                    },
                    child: SizedBox.expand(
                      child: LocalImage.relative(
                        storageRoot: "/Users/meme/Desktop/storage",
                        storyWattId: book.wattId,
                        relativePath: book.image.path!,
                        // height: MediaQuery.of(context).size.height / 4,
                        fit: BoxFit.cover,
                      ),
                    ),
                  ),
                ),
              ),
            ),
            const SizedBox(height: 5),
            BookProgressBar(progress: 0.5),
          ],
        );

        return _sizeContent(context, content);
      },
    );
  }

  Widget _sizeContent(BuildContext context, Widget content) {
    final tileW = MediaQuery.of(context).size.width / 20;
    final tileH = tileW * 1.75;

    return SizedBox(width: tileW, height: tileH, child: content);
  }
}

class BookProgressBar extends StatelessWidget {
  double progress;

  BookProgressBar({super.key, this.progress = 0});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      height: 10,
      child: InnerShadow(
        shadows: [
          Shadow(
            color: Colors.black.withOpacity(0.25),
            blurRadius: 2,
            offset: Offset(0, 1),
          ),
        ],
        child: LinearProgressIndicator(
          color: AppPalette.primaryLight,
          value: progress,
          backgroundColor: AppPalette.primaryExtraLight,
          borderRadius: BorderRadius.all(Radius.circular(2)),
        ),
      ),
    );
  }
}

class _BottomOnlyClip extends CustomClipper<Rect> {
  final double expand;

  const _BottomOnlyClip({this.expand = 20});

  @override
  Rect getClip(Size size) =>
      Rect.fromLTRB(-expand, -expand, size.width + expand, size.height);

  @override
  bool shouldReclip(covariant _BottomOnlyClip old) => old.expand != expand;
}
