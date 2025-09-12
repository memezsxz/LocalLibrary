import 'package:flutter/material.dart';

class TwoPaneRow extends StatelessWidget {
  const TwoPaneRow({super.key, required this.sidebar, required this.content});

  final Widget sidebar;
  final Widget content;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        sidebar,
        Expanded(child: content),
      ],
    );
  }
}
