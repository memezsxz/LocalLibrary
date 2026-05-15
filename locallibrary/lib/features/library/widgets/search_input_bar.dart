import 'package:flutter/material.dart';

import '../../../core/theme/app_palette.dart';

class SearchInputBar extends StatelessWidget {
  const SearchInputBar({
    super.key,
    this.onAdvancedSearch,
    this.onChanged,
    this.hasActiveFilters = false,
  });

  final VoidCallback? onAdvancedSearch;
  final ValueChanged<String>? onChanged;
  final bool hasActiveFilters;

  @override
  Widget build(BuildContext context) {
    return SearchBar(
      hintText: 'Search in My Library',
      leading: const Icon(Icons.search),
      shape: WidgetStatePropertyAll(
        RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
      ),
      trailing: [
        IconButton(
          icon: Icon(
            Icons.tune,
            color: hasActiveFilters ? AppPalette.primary : null,
          ),
          tooltip: 'Advanced search',
          onPressed: onAdvancedSearch,
        ),
      ],
      onChanged: onChanged,
      constraints: const BoxConstraints(),
      overlayColor: WidgetStateProperty.all(Colors.transparent),
      padding: WidgetStateProperty.all(
        const EdgeInsets.only(top: 2, bottom: 2, left: 10, right: 4),
      ),
    );
  }
}