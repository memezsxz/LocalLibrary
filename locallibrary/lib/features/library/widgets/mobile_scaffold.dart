import 'package:flutter/material.dart';

import 'nav_items.dart';

class MobileScaffold extends StatelessWidget {
  final int selectedIndex;
  final Widget body;
  final Widget? floatingActionButton;
  final bool hideNav;
  final ValueChanged<int> onDestinationSelected;

  const MobileScaffold({
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
      bottomNavigationBar: hideNav
          ? null
          : NavigationBar(
              labelBehavior:
                  NavigationDestinationLabelBehavior.onlyShowSelected,
              destinations: buildBottomDestinations(),
              selectedIndex: selectedIndex,
              onDestinationSelected: onDestinationSelected,
            ),
      body: body,
    );
  }
}
