import 'package:flutter/material.dart';

import '../../features/story/bloc/base_scrape_state.dart';
import '../theme/app_palette.dart';

extension ScrapeStatusAssociation on ScrapeStatus {
  String get title {
    switch (this) {
      case ScrapeStatus.idle:
        return 'Idle';
      case ScrapeStatus.connecting:
        return 'Connecting…';
      case ScrapeStatus.streaming:
        return 'Streaming…';
      case ScrapeStatus.done:
        return 'Completed';
      case ScrapeStatus.error:
        return 'Error';
    }
  }

  /// Tiny status indicator suited for buttons / list tiles.
  Widget indicator(BuildContext context) {
    switch (this) {
      case ScrapeStatus.idle:
        return Icon(
          Icons.cookie_outlined,
          size: 18,
          color: context.colors.primary,
        );
      case ScrapeStatus.connecting:
        return SizedBox(
          width: 18,
          height: 18,
          child: CircularProgressIndicator(
            strokeWidth: 2,
            color: context.colors.primary,
          ),
        );
      case ScrapeStatus.streaming:
        return SizedBox(
          width: 18,
          height: 18,
          child: CircularProgressIndicator(
            strokeWidth: 2,
            color: context.colors.primary,
          ),
        );
      case ScrapeStatus.done:
        return Icon(
          Icons.check_circle,
          size: 18,
          color: context.colors.primary,
        );
      case ScrapeStatus.error:
        return Icon(
          Icons.error_outline,
          size: 18,
          color: context.colors.primary,
        );
    }
  }

  /// Handy for disabling buttons / showing spinners.
  bool get isBusy {
    switch (this) {
      case ScrapeStatus.connecting:
      case ScrapeStatus.streaming:
        return true;
      case ScrapeStatus.idle:
      case ScrapeStatus.done:
      case ScrapeStatus.error:
        return false;
    }
  }
}
