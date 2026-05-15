import 'package:flutter/material.dart';

const navItems = [
  (label: 'Home', icon: Icons.home_outlined, selected: Icons.home),
  (label: 'Library', icon: Icons.book_outlined, selected: Icons.book),
  (
    label: 'Notifications',
    icon: Icons.notifications_outlined,
    selected: Icons.notifications,
  ),
  (label: 'Settings', icon: Icons.settings_outlined, selected: Icons.settings),
];

List<NavigationRailDestination> buildRailDestinations() {
  return navItems
      .map(
        (i) => NavigationRailDestination(
          icon: Icon(i.icon),
          selectedIcon: Icon(i.selected),
          label: Text(i.label),
        ),
      )
      .toList();
}

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
