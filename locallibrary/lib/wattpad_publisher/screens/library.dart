import 'package:flutter/material.dart';
import 'package:locallibrary/wattpad_publisher/datasource.dart';
import 'package:locallibrary/wattpad_publisher/widgets/shelves.dart';

import '../../dependency_ingection.dart';
//
// class Library extends StatelessWidget {
//   const Library({super.key});
//
//   @override
//   Widget build(BuildContext context) {
//     int count = 6;
//
//     int countThreeRows = count * 3;
//
//     return Padding(
//       padding: const EdgeInsets.all(10).copyWith(top: 0),
//       child: SingleChildScrollView(
//         clipBehavior: Clip.none,
//         child: Column(
//           mainAxisSize: MainAxisSize.min,
//           children: [
//             for (int i = 0; i < countThreeRows; i++) Shelve(storyIds: [1]),
//           ],
//         ),
//       ),
//     );
//   }
// }

class Library extends StatefulWidget {
  const Library({super.key});

  @override
  State<Library> createState() => _LibraryState();
}

class _LibraryState extends State<Library> {
  final _scroll = ScrollController();

  // Fetch in multiples of 6 so shelves fill nicely (e.g., 30 = 5 shelves)
  static const int _pageSize = 30;

  final List<int> _storyIds = [];
  int _offset = 0;
  bool _loading = false;
  bool _hasMore = true;
  String? _error;

  @override
  void initState() {
    super.initState();
    _loadMore();
    _scroll.addListener(() {
      if (_scroll.position.extentAfter < 600 && !_loading && _hasMore) {
        _loadMore();
      }
    });
  }

  @override
  void dispose() {
    _scroll.dispose();
    super.dispose();
  }

  Future<void> _reload() async {
    setState(() {
      _storyIds.clear();
      _offset = 0;
      _hasMore = true;
      _error = null;
    });
    await _loadMore();
  }

  Future<void> _loadMore() async {
    if (_loading || !_hasMore) return;
    setState(() => _loading = true);

    try {
      final ds = sl<AppApiDataSource>();
      final stories = await ds.listStories(limit: _pageSize, offset: _offset);

      if (!mounted) return;
      if (stories.isEmpty) {
        setState(() => _hasMore = false);
      } else {
        setState(() {
          _storyIds.addAll(stories.map((s) => s.storyId));
          _offset += stories.length;
          _hasMore = stories.length == _pageSize;
        });
      }
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _error = e.toString();
        _hasMore = false; // stop auto-retrying; user can pull-to-refresh
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to load stories: $e')),
      );
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    // How many full/partial shelves of 6 do we have right now?
    final shelfCount = (_storyIds.length + 5) ~/ 6;
    final showBottomLoader = _hasMore || _loading;
    final itemCount = (_storyIds.isEmpty && _error != null)
        ? 1
        : shelfCount + (showBottomLoader ? 1 : 0);

    return RefreshIndicator(
      onRefresh: _reload,
      child: ListView.builder(
        controller: _scroll,
        padding: const EdgeInsets.symmetric(horizontal: 10).copyWith(top: 0, bottom: 16),
        physics: const AlwaysScrollableScrollPhysics(),
        itemCount: itemCount,
        itemBuilder: (context, index) {
          // Initial error state
          if (_storyIds.isEmpty && _error != null) {
            return Padding(
              padding: const EdgeInsets.all(16),
              child: Center(child: Text('Failed to load: $_error')),
            );
          }

          // Bottom loader row
          if (index >= shelfCount) {
            return const Padding(
              padding: EdgeInsets.symmetric(vertical: 16),
              child: Center(child: CircularProgressIndicator()),
            );
          }

          // Compute the story IDs for this shelf (6 per shelf)
          final start = index * 6;
          final end = (start + 6 <= _storyIds.length) ? start + 6 : _storyIds.length;
          final shelfStoryIds = _storyIds.sublist(start, end);

          // Render one shelf (expects up to 6 items)
          return Padding(
            padding: const EdgeInsets.only(top: 10),
            child: Shelve(storyIds: shelfStoryIds),
          );
        },
      ),
    );
  }
}
