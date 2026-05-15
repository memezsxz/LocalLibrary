import 'package:flutter/material.dart';

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
          if (!hideNav)
            NavigationRail(
              destinations: buildRailDestinations(),
              selectedIndex: selectedIndex,
              onDestinationSelected: onDestinationSelected,
              trailing: Expanded(
                child: Align(
                  alignment: Alignment.bottomCenter,
                  child: Padding(
                    padding: const EdgeInsets.only(bottom: 16),
                    child: Column(mainAxisSize: MainAxisSize.min),
                  ),
                ),
              ),
            ),
          if (!hideNav) const VerticalDivider(thickness: 1, width: 1),
          Expanded(child: body),
        ],
      ),
    );
  }
}
