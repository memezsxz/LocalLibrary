import 'package:flutter/material.dart';

class SearchInputBar extends StatelessWidget {
  final VoidCallback? onAdvancedSearch;
  final ValueChanged<String>? onChanged;

  const SearchInputBar({super.key, this.onAdvancedSearch, this.onChanged});

  @override
  Widget build(BuildContext context) {
    // TODO: add search anchor
    return SearchBar(
      hintText: 'Search in My Library',
      leading: const Icon(Icons.search),
      shape: WidgetStatePropertyAll(
        RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
      ),
      trailing: [
        IconButton(
          icon: const Icon(Icons.tune),
          tooltip: 'Advanced search',
          onPressed: onAdvancedSearch,
        ),
      ],
      onChanged: onChanged,
      constraints: const BoxConstraints(),
      overlayColor: WidgetStateProperty.all(Colors.transparent),
      padding: WidgetStateProperty.all(
        EdgeInsets.only(top: 2, bottom: 2, left: 10, right: 4),
      ),
    );
  }
}