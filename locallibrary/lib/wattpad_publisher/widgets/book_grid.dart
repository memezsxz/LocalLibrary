import 'package:flutter/material.dart';
import 'package:locallibrary/dependency_ingection.dart';
import 'package:locallibrary/wattpad_publisher/cubit/settings_cubit.dart';
import 'package:locallibrary/wattpad_publisher/models/book_size.dart';
import 'package:locallibrary/wattpad_publisher/widgets/book_minimal_view.dart';

class BookGrid extends StatefulWidget {
  final Future<List<int>> Function(int limit, int offset) fetch;
  final int pageSize;

  const BookGrid({super.key, required this.fetch, this.pageSize = 30});

  @override
  State<BookGrid> createState() => _BookGridState();
}

class _BookGridState extends State<BookGrid> {
  final _scroll = ScrollController();
  final List<int> _storyIds = [];
  int _offset = 0;
  bool _loading = false;
  bool _hasMore = true;

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
    });
    await _loadMore();
  }

  Future<void> _loadMore() async {
    if (_loading || !_hasMore) return;
    setState(() => _loading = true);
    try {
      final ids = await widget.fetch(widget.pageSize, _offset);
      if (!mounted) return;
      if (ids.isEmpty) {
        setState(() => _hasMore = false);
      } else {
        setState(() {
          _storyIds.addAll(ids);
          _offset += ids.length;
          _hasMore = ids.length == widget.pageSize;
        });
      }
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _hasMore = false;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Failed to load: $e'),
          action: SnackBarAction(label: 'Retry', onPressed: _loadMore),
        ),
      );
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final bookSize = sl<SettingsCubit>().state.bookSize;

    return RefreshIndicator(
      onRefresh: _reload,
      child: GridView.builder(
        controller: _scroll,
        padding: const EdgeInsets.all(10),
        physics: const AlwaysScrollableScrollPhysics(),
        gridDelegate: SliverGridDelegateWithMaxCrossAxisExtent(
          maxCrossAxisExtent: bookSize.maxExtent(),
          childAspectRatio: 0.6,
          crossAxisSpacing: 8,
          mainAxisSpacing: 8,
        ),
        itemCount: _storyIds.length + (_hasMore || _loading ? 1 : 0),
        itemBuilder: (context, i) {
          if (i >= _storyIds.length)
            return const Center(child: CircularProgressIndicator());
          return BookMinimalView(storyId: _storyIds[i]);
        },
      ),
    );
  }
}
