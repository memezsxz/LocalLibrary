import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

import '../../core/theme/app_palette.dart';
import 'dashed_line.dart';

class MySearchBar extends StatelessWidget {
  const MySearchBar({super.key});

  @override
  Widget build(BuildContext context) {
    return Stack(
      alignment: AlignmentGeometry.bottomCenter,
      children: [
        Container(
          padding: EdgeInsetsGeometry.all(10),
          margin: EdgeInsetsGeometry.only(bottom: 5),
          width: double.infinity,
          height: 50,
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
          child: Expanded(
            child: Row(
              spacing: 10,
              children: [
                BaseButton(label: "Shelves", onPressed: () {}),
                BaseButton(label: "All Books", onPressed: () {}),
                // Expanded(child: NavBar.search()),
                // search part
                Expanded(
                  child: Container(
                    padding: EdgeInsetsGeometry.symmetric(
                      horizontal: 10,
                      vertical: 2,
                    ),
                    // width: double.infinity,
                    // height: double.infinity,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.all(Radius.circular(10)),
                      color: AppPalette.gray.withOpacity(0.3),
                      border: BoxBorder.all(
                        color: AppPalette.gray.withOpacity(0.01),
                        width: 1.5,
                      ),
                    ),
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
                            style: TextStyle(fontSize: 15),
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
            ),
          ),
        ),
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
