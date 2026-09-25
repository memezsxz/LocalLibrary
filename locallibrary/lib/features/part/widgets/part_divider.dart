import 'package:flutter/material.dart';

import '../../../core/theme/app_palette.dart';

class PartDivider extends StatelessWidget {
  const PartDivider({super.key, required this.title});

  final String title;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 40),
      child: Row(
        children: [
          const Expanded(child: Divider()),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Text(
              title,
              style: Theme.of(context).textTheme.labelMedium?.copyWith(
                color: context.colors.primaryLight,
                fontFamily: 'Courier New',
              ),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ),
          const Expanded(child: Divider()),
        ],
      ),
    );
  }
}
