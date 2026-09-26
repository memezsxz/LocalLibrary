import 'package:flutter/material.dart';

import '../../../core/theme/app_theme.dart';
import 'nav_items.dart';

class DesktopScaffold extends StatelessWidget {
  final int selectedIndex;
  final Widget body;
  final Widget? floatingActionButton;
  final bool hideNav;
  final ValueChanged<int> onDestinationSelected;

  const DesktopScaffold({
    super.key,
    required this.selectedIndex,
    required this.body,
    required this.onDestinationSelected,
    this.floatingActionButton,
    this.hideNav = false,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      floatingActionButton: floatingActionButton,
      body: Row(
        children: [
          if (!hideNav) _NavRail(selectedIndex: selectedIndex,
              onDestinationSelected: onDestinationSelected),
          if (!hideNav) const VerticalDivider(thickness: 1, width: 1),
          Expanded(child: body),
        ],
      ),
    );
  }
}

/// Replaces Flutter's stock [NavigationRail] — its selected indicator only
/// wraps the icon, leaving the label outside it. Here the selected
/// background wraps icon + label together, same as the reading dock.
class _NavRail extends StatelessWidget {
  final int selectedIndex;
  final ValueChanged<int> onDestinationSelected;

  const _NavRail({
    required this.selectedIndex,
    required this.onDestinationSelected,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 76,
      color: context.colors.surface,
      padding: const EdgeInsets.symmetric(vertical: 18),
      child: Column(
        children: [
          for (var i = 0; i < navItems.length; i++)
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 3),
              child: _RailItem(
                item: navItems[i],
                selected: i == selectedIndex,
                onTap: () => onDestinationSelected(i),
              ),
            ),
        ],
      ),
    );
  }
}

class _RailItem extends StatelessWidget {
  final ({String label, IconData icon, IconData selected}) item;
  final bool selected;
  final VoidCallback onTap;

  const _RailItem({
    required this.item,
    required this.selected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: selected ? context.colors.primaryExtraLight : Colors.transparent,
      borderRadius: BorderRadius.circular(14),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(14),
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 7, horizontal: 4),
          child: SizedBox(
            width: 56,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  selected ? item.selected : item.icon,
                  size: 19,
                  color: selected ? context.colors.primary : context.colors
                      .gray,
                ),
                const SizedBox(height: 4),
                Text(
                  item.label,
                  style: TextStyle(
                    fontSize: 10.5,
                    fontWeight: FontWeight.w600,
                    color: selected ? context.colors.primary : context.colors
                        .gray,
                  ),
                  textAlign: TextAlign.center,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
