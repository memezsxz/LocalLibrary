import 'dart:convert';

import 'package:flutter/cupertino.dart';

import '../../../core/datasource.dart';
import '../../story/bloc/base_scrape_bloc.dart';
import '../../story/bloc/scrape_story_bloc.dart';
import '../../story/models/logs.dart';
import '../../story/models/store_models.dart';

part 'scrape_part_event.dart';
part 'scrape_part_state.dart';

class ScrapePartBloc extends BaseScrapeBloc<PartTxResult> {
  final AppApiDataSource api;
  final int storyId;

  /// Accept either a full part URL or "storyId:partId"
  ScrapePartBloc({required this.api, required this.storyId})
    : super(
        startStream: (input) {
          final base = api.streamScrapePart(
            partUrl: input,
            clearOutput: false,
            storyId: storyId,
          );

          return base.asyncExpand((evt) async* {
            if (evt.name == 'log' ||
                evt.name == 'error' ||
                evt.name == 'info') {
              for (final piece in splitNdjsonOrConcatenated(evt.payload)) {
                yield ScrapeEvent(evt.name, piece);
              }
            } else {
              yield evt;
            }
          });
        },

        validateInput: _validateUrlMessage,
        parseFinished: (data) {
          try {
            final v = jsonDecode(data);
            final obj = (v is Map && v['ok'] == true && v['result'] is Map)
                ? v['result'] as Map<String, dynamic>
                : (v is Map<String, dynamic> ? v : null);
            return obj == null ? null : PartTxResult.fromJson(obj);
          } catch (_) {
            return null;
          }
        },
        extractError: defaultErrorExtractor,
      );
}

String? _validateUrlMessage(String raw) {
  final v = normalizeUrl(raw);
  if (v.isEmpty) return 'Problem: Url is required';

  final uri = Uri.tryParse(v);
  if (uri == null || !uri.host.toLowerCase().endsWith('wattpad.com')) {
    return 'Problem: not a wattpad.com URL';
  }

  final segs = uri.pathSegments;
  if (segs.isEmpty) return 'Problem: expected a Wattpad path';

  // Case 1: /<id>-slug   (part pages)
  final head = segs.first;
  final hasId = RegExp(r'^\d+').hasMatch(head);
  return hasId ? null : 'Problem: missing numeric id after wattpad.com/';
}
