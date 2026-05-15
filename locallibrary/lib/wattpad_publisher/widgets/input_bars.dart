import 'package:flutter/material.dart';

import '../../core/theme/app_palette.dart';

class MySearchBar extends StatelessWidget {
  final VoidCallback? onAdvancedSearch;
  final ValueChanged<String>? onChanged;

  const MySearchBar({super.key, this.onAdvancedSearch, this.onChanged});

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

class BaseButton extends StatelessWidget {
  final String label;
  final VoidCallback onPressed;

  const BaseButton({super.key, required this.label, required this.onPressed});

  @override
  Widget build(BuildContext context) {
    return OutlinedButton(
      onPressed: onPressed,
      style: OutlinedButton.styleFrom(
        // minimumSize: const Size(double.infinity, 55),
        alignment: Alignment.center,
        side: BorderSide(color: AppPalette.primary, width: 1.5),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
        padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 15),
        overlayColor: AppPalette.primary.withOpacity(0.1),
      ),
      child: Text(
        label,
        style: TextStyle(
          color: AppPalette.primary,
          fontWeight: FontWeight.normal,
        ),
      ),
    );
  }
}
