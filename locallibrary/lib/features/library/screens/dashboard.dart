import 'package:flutter/material.dart';
import 'package:locallibrary/features/story/models/book_size.dart';

import '../../../core/datasource.dart';
import '../../../dependency_injection.dart';
import '../../settings/cubit/settings_cubit.dart';
import '../widgets/book_minimal_view.dart';
import '../widgets/input_bars.dart';

class Dashboard extends StatefulWidget {
  const Dashboard({super.key});

  @override
  State<Dashboard> createState() => _DashboardState();
}

class _DashboardState extends State<Dashboard> {
  final _scroll = ScrollController();

  int _pageSize = 30; // recalculated from screen size on first frame
  bool _initialized = false;

  final List<int> _storyIds = [];
  int _offset = 0;
  bool _loading = false;
  bool _hasMore = true;

  int _computePageSize(BuildContext context) {
    final size = MediaQuery.sizeOf(context);
    final bookMaxExtent = sl<SettingsCubit>().state.bookSize.maxExtent();
    final cols = (size.width / bookMaxExtent).ceil().clamp(1, 20);
    final itemHeight = bookMaxExtent / 0.6;
    final rows = (size.height / itemHeight).ceil().clamp(1, 20);
    return (cols * rows * 2).clamp(10, 50);
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (!_initialized) {
      _initialized = true;
      _pageSize = _computePageSize(context);
      _loadMore();
    }
  }

  @override
  void initState() {
    super.initState();
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
        _hasMore = false; // stop auto-retrying; user can pull-to-refresh
      });
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Failed to load stories: $e')));
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final bookSize = sl<SettingsCubit>().state.bookSize;

    return Column(
      spacing: 10,
      children: [
        Padding(
          padding: const EdgeInsets.only(bottom: 5),
          child: MySearchBar(),
        ),
        // the list
        Expanded(
          child: RefreshIndicator(
            onRefresh: _reload,
            child: GridView.builder(
              controller: _scroll,
              padding: const EdgeInsets.only(left: 10, right: 10, bottom: 10),
              physics: const AlwaysScrollableScrollPhysics(),
              gridDelegate: SliverGridDelegateWithMaxCrossAxisExtent(
                maxCrossAxisExtent: bookSize.maxExtent(),
                // max book width — auto-fits columns
                childAspectRatio: 0.6,
                // book cover ratio
                crossAxisSpacing: 25,
                mainAxisSpacing: 25,
              ),
              itemCount: _storyIds.length + (_hasMore || _loading ? 1 : 0),
              itemBuilder: (context, i) {
                if (i >= _storyIds.length) {
                  return const Center(child: CircularProgressIndicator());
                }
                return BookMinimalView(storyId: _storyIds[i]);
              },
            ),
          ),
        ),
      ],
    );
  }
}
