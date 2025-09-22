import 'package:flutter/material.dart';
import 'package:locallibrary/wattpad_publisher/widgets/input_bars.dart';

import '../widgets/shelves.dart';

class Dashboard extends StatelessWidget {
  const Dashboard({super.key});

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.start,
      children: [
        const MySearchBar(),
        SizedBox(height: 20),
        Expanded(
          child: ClipRect(
            // allows side & bottom overflow for shadows, but blocks the top
            clipper: const TopOnlyClip(expandSides: 24, expandBottom: 24),
            child: const DashboardShelves(),
          ),
        ),
      ],
    );
  }
}

// put this somewhere accessible
class TopOnlyClip extends CustomClipper<Rect> {
  final double expandSides;
  final double expandBottom;

  const TopOnlyClip({this.expandSides = 24, this.expandBottom = 24});

  @override
  Rect getClip(Size size) => Rect.fromLTRB(
    -expandSides,
    0,
    size.width + expandSides,
    size.height + expandBottom,
  );

  @override
  bool shouldReclip(TopOnlyClip old) =>
      expandSides != old.expandSides || expandBottom != old.expandBottom;
}
