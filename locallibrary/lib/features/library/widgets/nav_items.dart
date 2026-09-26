import 'package:flutter/material.dart';

const navItems = [
  (label: 'Library', icon: Icons.home_outlined, selected: Icons.home),
  (
  label: 'Alerts',
    icon: Icons.notifications_outlined,
    selected: Icons.notifications,
  ),
  (label: 'Saved', icon: Icons.book_outlined, selected: Icons.book),
  (label: 'Settings', icon: Icons.settings_outlined, selected: Icons.settings),
];

List<NavigationDestination> buildBottomDestinations() {
  return navItems
      .map(
        (i) => NavigationDestination(
          icon: Icon(i.icon),
          selectedIcon: Icon(i.selected),
          label: i.label,
        ),
      )
      .toList();
}
