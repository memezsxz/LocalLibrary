import 'package:flutter/material.dart';

import '../../core/theme/app_palette.dart';
import 'dashed_line.dart';

class Aside extends StatelessWidget {
  const Aside({
    super.key,
    required this.top,
    required this.bottom,
    this.width = 88,
  });

  final Widget top;
  final Widget bottom;
  final double width;

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Container(
        width: width,
        height: double.infinity,
        decoration: BoxDecoration(
          boxShadow: [
            BoxShadow(
              offset: Offset(3, 0),
              blurRadius: 10,
              color: Colors.black.withOpacity(0.1),
            ),
          ],
          color: AppPalette.background,
          borderRadius: BorderRadius.only(
            topLeft: Radius.circular(25),
            bottomLeft: Radius.circular(25),
          ),
        ),

        // padding: EdgeInsets.symmetric(vertical: 40, horizontal: 20),
        child: Row(
          // spacing: 10,
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: [
            Expanded(
              child: Padding(
                padding: EdgeInsets.symmetric(vertical: 40, horizontal: 20),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Image.asset('assets/images/icon.png', height: 50),
                    SizedBox(height: 30),
                    top,
                    Spacer(),
                    bottom,
                  ],
                ),
              ),
            ),

            // SizedBox(width: 10),
            DashImageLine(
              assetPath: "assets/images/dash.png",
              thickness: 2.5,
              axis: Axis.vertical,
              dashExtent: 6,
              gap: 5,
            ),
            SizedBox(width: 5),
          ],
        ),
      ),
    );
  }
}
