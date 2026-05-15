import 'package:flutter/material.dart';

import '../../../core/theme/app_palette.dart';

// ─── Shared types ─────────────────────────────────────────────────────────────

typedef FilterItem = ({String id, String label});

class AdvancedSearchHeader extends StatelessWidget {
  const AdvancedSearchHeader();

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      child: Row(
        children: [
          const Icon(Icons.tune, size: 18, color: AppPalette.primary),
          const SizedBox(width: 8),
          Text(
            'Advanced Search',
            style: Theme.of(context).textTheme.titleMedium,
          ),
          const Spacer(),
          IconButton(
            tooltip: 'Close',
            onPressed: () => Navigator.of(context).maybePop(),
            icon: const Icon(Icons.close, size: 18),
            color: AppPalette.primary,
            visualDensity: VisualDensity.compact,
          ),
        ],
      ),
    );
  }
}

// ─── Section label ────────────────────────────────────────────────────────────

class SectionLabel extends StatelessWidget {
  const SectionLabel({required this.label, required this.icon});

  final String label;
  final IconData icon;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Icon(icon, size: 16, color: AppPalette.primary),
        const SizedBox(width: 6),
        Text(
          label,
          style: Theme.of(
            context,
          ).textTheme.labelLarge?.copyWith(color: AppPalette.primary),
        ),
      ],
    );
  }
}

// ─── Expandable filter section ────────────────────────────────────────────────

class FilterSection extends StatefulWidget {
  const FilterSection({
    required this.title,
    required this.icon,
    required this.items,
    required this.selectedIds,
    required this.isLoading,
    required this.onToggle,
  });

  final String title;
  final IconData icon;
  final List<FilterItem> items;
  final Set<String> selectedIds;
  final bool isLoading;
  final ValueChanged<String> onToggle;

  @override
  State<FilterSection> createState() => _FilterSectionState();
}

class _FilterSectionState extends State<FilterSection> {
  String _search = '';

  @override
  Widget build(BuildContext context) {
    final selCount = widget.selectedIds.length;
    final filtered = _search.isEmpty
        ? widget.items
        : widget.items
              .where(
                (item) =>
                    item.label.toLowerCase().contains(_search.toLowerCase()),
              )
              .toList();

    return ExpansionTile(
      tilePadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 2),
      childrenPadding: const EdgeInsets.fromLTRB(16, 0, 16, 12),
      leading: Icon(widget.icon, size: 18, color: AppPalette.primary),
      title: Row(
        children: [
          Text(
            widget.title,
            style: Theme.of(
              context,
            ).textTheme.labelLarge?.copyWith(color: AppPalette.primary),
          ),
          if (selCount > 0) ...[
            const SizedBox(width: 8),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 1),
              decoration: BoxDecoration(
                color: AppPalette.primary,
                borderRadius: BorderRadius.circular(10),
              ),
              child: Text(
                '$selCount',
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 11,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ],
        ],
      ),
      children: [
        if (widget.isLoading)
          const Padding(
            padding: EdgeInsets.symmetric(vertical: 12),
            child: Center(
              child: SizedBox(
                width: 20,
                height: 20,
                child: CircularProgressIndicator(strokeWidth: 2),
              ),
            ),
          )
        else ...[
          if (widget.items.length > 10)
            Padding(
              padding: const EdgeInsets.only(bottom: 10),
              child: TextField(
                decoration: InputDecoration(
                  hintText: 'Search ${widget.title.toLowerCase()}…',
                  prefixIcon: const Icon(Icons.search, size: 18),
                  contentPadding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 8,
                  ),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                  isDense: true,
                ),
                onChanged: (v) => setState(() => _search = v),
              ),
            ),
          Wrap(
            spacing: 6,
            runSpacing: 4,
            children: filtered.map((item) {
              final isSelected = widget.selectedIds.contains(item.id);
              return FilterChip(
                label: Text(item.label, style: const TextStyle(fontSize: 12)),
                selected: isSelected,
                onSelected: (_) => widget.onToggle(item.id),
                selectedColor: AppPalette.primaryLight,
                checkmarkColor: AppPalette.primary,
                side: BorderSide(
                  color: isSelected
                      ? AppPalette.primary
                      : AppPalette.secondary.withAlpha(100),
                ),
                materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                visualDensity: VisualDensity.compact,
                showCheckmark: true,
              );
            }).toList(),
          ),
        ],
      ],
    );
  }
}
