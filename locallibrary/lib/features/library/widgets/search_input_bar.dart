import 'package:flutter/material.dart';

import '../../../core/theme/app_palette.dart';

class SearchInputBar extends StatefulWidget {
  const SearchInputBar({
    super.key,
    this.onAdvancedSearch,
    this.onChanged,
    this.onClear,
    this.hasActiveFilters = false,
    this.showClear = false,
  });

  final VoidCallback? onAdvancedSearch;
  final ValueChanged<String>? onChanged;
  final VoidCallback? onClear;
  final bool hasActiveFilters;
  final bool showClear;

  @override
  State<SearchInputBar> createState() => _SearchInputBarState();
}

class _SearchInputBarState extends State<SearchInputBar> {
  final _controller = SearchController();

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _handleClear() {
    _controller.clear();
    widget.onClear?.call();
  }

  @override
  Widget build(BuildContext context) {
    return SearchBar(
      controller: _controller,
      hintText: 'Search in My Library',
      leading: const Icon(Icons.search),
      shape: WidgetStatePropertyAll(
        RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
      ),
      trailing: [
        if (widget.showClear)
          IconButton(
            icon: const Icon(Icons.close),
            tooltip: 'Clear search',
            onPressed: _handleClear,
          ),
        IconButton(
          icon: Icon(
            Icons.tune,
            color: widget.hasActiveFilters ? context.colors.primary : null,
          ),
          tooltip: 'Advanced search',
          onPressed: widget.onAdvancedSearch,
        ),
      ],
      onChanged: widget.onChanged,
      constraints: const BoxConstraints(),
      overlayColor: WidgetStateProperty.all(Colors.transparent),
      padding: WidgetStateProperty.all(
        const EdgeInsets.only(top: 2, bottom: 2, left: 10, right: 4),
      ),
    );
  }
}
