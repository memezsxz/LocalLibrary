import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_inner_shadow/flutter_inner_shadow.dart';
import 'package:flutter_svg/flutter_svg.dart';

import '../../core/theme/app_palette.dart';
import '../cubit/navigation_cubit.dart';

class NavBar extends StatefulWidget {
  const NavBar._({super.key, required this.items});

  factory NavBar.defaults({Key? key}) {
    const labels = ["Home", "Library", "Notifications"];
    const iconsDefault = [
      "assets/icons/home_icon_light.svg",
      "assets/icons/library_icon_light.svg",
      "assets/icons/notification_icon_light.svg",
    ];
    const iconsSelected = [
      "assets/icons/home_icon_dark.svg",
      "assets/icons/library_icon_dark.svg",
      "assets/icons/notification_icon_dark.svg",
    ];

    final screens = [
      NavigationDashboardCubit(),
      NavigationLibraryCubit(),
      NavigationNotificationsCubit(),
    ];

    final items = List.generate(
      3,
      (i) => NavItem(
        label: labels[i],
        defaultAsset: iconsDefault[i],
        selectedAsset: iconsSelected[i],
        screen: screens[i],
      ),
    );

    return NavBar._(key: key, items: items);
  }

  factory NavBar.search({Key? key}) {
    const labels = ["Shelves", "All Books"];

    final screens = [NavigationDashboardCubit(), NavigationLibraryCubit()];

    final items = List.generate(
      2,
      (i) => NavItem(label: labels[i], screen: screens[i]),
    );

    return NavBar._(key: key, items: items);
  }

  final List<NavItem> items;

  @override
  State<NavBar> createState() => _NavBarState();
}

class _NavBarState extends State<NavBar> {
  int selectedIndex = 0;

  // void _resetAll() {
  //   setState(() {
  //     selectedIndex = 0;
  //   });
  // }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<NavigationCubit, NavigationScreenCubit>(
      builder: (context, state) {
        return Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: List.generate(widget.items.length, (i) {
            final it = widget.items[i];
            return Padding(
              padding: const EdgeInsets.only(bottom: 10),
              child: ToggleButton(
                label: it.label,
                selectedImage: it.selectedAsset,
                defaultImage: it.defaultAsset,
                isSelected: selectedIndex == i,
                onPressed: () {
                  setState(() {
                    selectedIndex = i; // reset others automatically
                  });
                  context.read<NavigationCubit>().changeContent(it.screen);
                },
              ),
            );
          }),
        );
      },
    );
  }
}

class NavItem {
  final String label;
  final String? selectedAsset;
  final String? defaultAsset;
  final NavigationScreenCubit screen;

  const NavItem({
    required this.label,
    this.selectedAsset,
    this.defaultAsset,
    required this.screen,
  });
}

class ToggleButton extends StatelessWidget {
  final String label;
  final String? selectedImage; // nullable
  final String? defaultImage; // nullable
  final bool isSelected;
  final VoidCallback onPressed;

  const ToggleButton({
    super.key,
    required this.label,
    this.selectedImage,
    this.defaultImage,
    required this.isSelected,
    required this.onPressed,
  });

  @override
  Widget build(BuildContext context) {
    return InnerShadow(
      shadows: [
        if (isSelected)
          Shadow(
            color: AppPalette.primary.withOpacity(0.15),
            blurRadius: 8,
            offset: const Offset(2, 5),
          ),
      ],
      child: TextButton(
        onPressed: onPressed,
        style: TextButton.styleFrom(
          backgroundColor: isSelected ? AppPalette.fiddle : Colors.white,
          minimumSize: const Size(double.infinity, 55),
          alignment: Alignment.centerLeft,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(13),
          ),
          padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 15),
          overlayColor: AppPalette.transparent,
        ),
        child: Row(
          children: [
            // only show icon if provided
            if (selectedImage != null && defaultImage != null) ...[
              SvgPicture.asset(
                isSelected ? selectedImage! : defaultImage!,
                width: 24,
              ),
              const SizedBox(width: 8),
            ],
            Text(
              label,
              style: TextStyle(
                color: isSelected
                    ? AppPalette.primary
                    : AppPalette.primaryLight,
                fontWeight: FontWeight.normal,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
