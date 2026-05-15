import 'dart:convert';

import '../../../core/datasource.dart';
import '../../story/bloc/base_scrape_bloc.dart';
import '../../story/models/logs.dart';
import '../../story/models/story_entity.dart';
import '../../story/utils/scrape_json_utils.dart';
import '../../story/utils/scrape_url_utils.dart';

class ScrapeCommentsBloc extends BaseScrapeBloc<PartTxResult> {
  final AppApiDataSource api;
  final int storyId;

  ScrapeCommentsBloc({required this.api, required this.storyId})
    : super(
        startStream: (input) {
          final base = api.streamScrapeComments(
            partUrl: input,
            storyId: storyId,
            clearOutput: false,
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

  final head = segs.first;
  final hasId = RegExp(r'^\d+').hasMatch(head);
  return hasId ? null : 'Problem: missing numeric id after wattpad.com/';
}
