import 'package:flutter/material.dart';
import 'package:locallibrary/core/theme/app_palette.dart';

class BaseButton extends StatelessWidget {
  final String label;
  final VoidCallback onPressed;

  const BaseButton({super.key, required this.label, required this.onPressed});

  @override
  Widget build(BuildContext context) {
    return OutlinedButton(
      onPressed: onPressed,
      style: OutlinedButton.styleFrom(
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
