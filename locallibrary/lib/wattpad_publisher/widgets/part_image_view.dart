import 'package:carousel_slider/carousel_slider.dart';
import 'package:flutter/material.dart';

import '../../core/theme/app_palette.dart';

class PartImages extends StatelessWidget {
  const PartImages({super.key, required this.partImages});

  final List<Widget> partImages;

  @override
  Widget build(BuildContext context) {
    return Container(
      height: MediaQuery.of(context).size.height / 2,
      decoration: BoxDecoration(
        border: Border.all(color: AppPalette.primary, width: 2),
        color: AppPalette.primary.withOpacity(0.5),
      ),
      child: LayoutBuilder(
        builder: (context, constraints) {
          return CarouselSlider.builder(
            itemCount: partImages.length,
            itemBuilder: (context, index, realIndex) => Container(
              alignment: Alignment.center,
              child: partImages[index],
            ),
            options: CarouselOptions(
              height: constraints.maxHeight,
              viewportFraction: 0.9,
              enlargeCenterPage: true,
              autoPlay: false,
              initialPage: 0,
              enableInfiniteScroll: false,
            ),
          );
        },
      ),
    );
  }
}
