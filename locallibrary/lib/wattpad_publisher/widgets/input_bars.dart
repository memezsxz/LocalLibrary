import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

import '../../core/theme/app_palette.dart';
import 'dashed_line.dart';

class WhiteContainer extends StatelessWidget {
  final Axis axis;
  final List<Widget> children;
  final MainAxisAlignment mainAxisAlignment;
  final MainAxisSize mainAxisSize;
  final CrossAxisAlignment crossAxisAlignment;
  final bool withDash;

  final double spacing;
  final EdgeInsetsGeometry padding;
  final EdgeInsetsGeometry margin;

  const WhiteContainer({
    super.key,
    this.axis = Axis.horizontal,
    required this.children,
    this.mainAxisSize = MainAxisSize.max,
    this.mainAxisAlignment = MainAxisAlignment.start,
    this.crossAxisAlignment = CrossAxisAlignment.center,
    this.withDash = false,
    this.padding = const EdgeInsetsGeometry.all(10),
    this.spacing = 10,
    this.margin = const EdgeInsetsGeometry.only(bottom: 5),
  });

  @override
  Widget build(BuildContext context) {
    return Stack(
      alignment: AlignmentGeometry.bottomCenter,
      children: [
        Expanded(
          child: Container(
            padding: padding,
            margin: margin,
            width: double.infinity,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.all(Radius.circular(10)),
              color: Colors.white,
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.1),
                  offset: const Offset(0, 8),
                  blurRadius: 9.4,
                  spreadRadius: 0,
                ),
              ],
            ),
            child: axis == Axis.horizontal
                ? Row(
                    mainAxisSize: mainAxisSize,
                    mainAxisAlignment: mainAxisAlignment,
                    crossAxisAlignment: crossAxisAlignment,
                    spacing: spacing,
                    children: children,
                  )
                : Column(
                    mainAxisSize: mainAxisSize,
                    mainAxisAlignment: mainAxisAlignment,
                    crossAxisAlignment: crossAxisAlignment,
                    spacing: spacing,
                    children: children,
                  ),
          ),
        ),
        if (withDash)
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: DashImageLine(
              assetPath: "assets/images/vDash.png",
              thickness: 10,
              axis: Axis.horizontal,
              dashExtent: 1.5,
              gap: 8,
            ),
          ),
      ],
    );
  }
}

class GrayContainer extends StatelessWidget {
  final Widget child;
  final EdgeInsets padding;
  final double borderRadius;

  const GrayContainer({
    super.key,
    required this.child,
    this.padding = const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
    this.borderRadius = 10,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: padding,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(borderRadius),
        color: AppPalette.gray.withOpacity(0.2),
        border: Border.all(
          color: AppPalette.gray.withOpacity(0.01),
          width: 1.5,
        ),
      ),

      child: child,
    );
  }
}

class MySearchBar extends StatelessWidget {
  const MySearchBar({super.key});

  @override
  Widget build(BuildContext context) {
    return WhiteContainer(
      withDash: true,
      children: [
        BaseButton(label: "Shelves", onPressed: () {}),
        BaseButton(label: "All Books", onPressed: () {}),
        Expanded(
          child: GrayContainer(
            child: Row(
              mainAxisSize: MainAxisSize.max,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                GestureDetector(
                  onTap: () {
                    print("preform search");
                  },
                  child: SvgPicture.asset(
                    "assets/icons/search_icon.svg",
                    width: 16,
                  ),
                ),
                SizedBox(width: 7),
                Expanded(
                  child: TextField(
                    decoration: const InputDecoration(
                      hintText: "Search in My library",
                      isDense: true,
                      border: InputBorder.none,
                      contentPadding: EdgeInsets.zero,
                      hintStyle: TextStyle(
                        color: AppPalette.gray,
                        fontSize: 15,
                      ),
                    ),
                    cursorWidth: 2.0,
                    cursorHeight: 18.0,
                    cursorRadius: const Radius.circular(3),
                    style: TextStyle(fontSize: 15, color: AppPalette.primary),
                    // TODO: convert the cursor icon to an ink pen icon
                  ),
                ),
                Spacer(),
                GestureDetector(
                  onTap: () {
                    print("change color and show advance options");
                  },
                  child: SvgPicture.asset(
                    "assets/icons/advance_search_icon.svg",
                    width: 16,
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
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

class UrlWidget extends StatelessWidget {
  final TextEditingController controller;
  final VoidCallback onSubmit;
  final ValueChanged<String>? onChanged;
  final Future<void> Function()? onPasteRequested;

  const UrlWidget({
    super.key,
    required this.controller,
    required this.onSubmit,
    this.onChanged,
    this.onPasteRequested,
  });

  @override
  Widget build(BuildContext context) {
    return WhiteContainer(
      withDash: true,
      children: [
        Text("Story URL:", style: TextStyle(color: AppPalette.primary)),
        Expanded(
          child: GrayContainer(
            child: Row(
              spacing: 10,
              children: [
                Expanded(
                  child: TextField(
                    controller: controller,
                    onSubmitted: (_) => onSubmit(),
                    onChanged: onChanged,
                    decoration: const InputDecoration(
                      hintText:
                          "example: https://www.wattpad.com/story/85730570",
                      isDense: true,
                      border: InputBorder.none,
                      contentPadding: EdgeInsets.zero,
                      hintStyle: TextStyle(
                        color: AppPalette.gray,
                        fontSize: 15,
                      ),
                    ),
                    cursorWidth: 2,
                    cursorHeight: 18,
                    cursorRadius: Radius.circular(3),
                    style: TextStyle(fontSize: 15, color: AppPalette.primary),
                  ),
                ),
                IconButton(
                  tooltip: 'Paste URL',
                  onPressed: onPasteRequested,
                  icon: const Icon(Icons.content_paste),
                  iconSize: 16,
                  padding: EdgeInsets.zero,
                  constraints: const BoxConstraints.tightFor(
                    width: 24,
                    height: 24,
                  ),
                  visualDensity: const VisualDensity(
                    horizontal: -4,
                    vertical: -4,
                  ),
                  splashRadius: 14,
                ),
                IconButton(
                  tooltip: 'Start',
                  onPressed: onSubmit,
                  icon: const Icon(Icons.arrow_forward),
                  iconSize: 16,

                  padding: EdgeInsets.zero,
                  constraints: const BoxConstraints.tightFor(
                    width: 24,
                    height: 24,
                  ),
                  visualDensity: const VisualDensity(
                    horizontal: -4,
                    vertical: -4,
                  ),
                  splashRadius: 14,
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}

class InfoContainer extends StatelessWidget {
  final String title;
  final Widget rowContent;
  final EdgeInsets padding;

  const InfoContainer({
    super.key,
    required this.title,
    required this.rowContent,
    this.padding = const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
  });

  @override
  Widget build(BuildContext context) {
    return WhiteContainer(
      children: [
        Text(title, style: TextStyle(color: AppPalette.primary)),
        Expanded(
          child: GrayContainer(child: rowContent, padding: padding),
        ),
      ],
    );
  }
}
