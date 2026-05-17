import 'dart:convert';

import '../../../core/api/scrape_service.dart';
import '../../story/bloc/base_scrape_bloc.dart';
import '../../story/models/dto/part_info.dart';
import '../../story/models/scrape/scrape_event_model.dart';
import '../../story/utils/scrape_json_utils.dart';
import '../../story/utils/scrape_url_utils.dart';

class ScrapePartBloc extends BaseScrapeBloc<PartInfo> {
  final ScrapeService api;
  final int storyId;
  final _WithCommentsHolder _holder;

  /// Set before firing [StartRequested] to include comments in the scrape.
  bool get withComments => _holder.value;

  set withComments(bool v) => _holder.value = v;

  factory ScrapePartBloc({required ScrapeService api, required int storyId}) {
    final holder = _WithCommentsHolder();
    return ScrapePartBloc._internal(
      api: api,
      storyId: storyId,
      holder: holder,
    );
  }

  ScrapePartBloc._internal({
    required this.api,
    required this.storyId,
    required _WithCommentsHolder holder,
  })
      : _holder = holder,
        super(
        startStream: (input) {
          final base = api.streamScrapePart(
            partUrl: input,
            clearOutput: false,
            storyId: storyId,
            withComments: holder.value,
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
            if (v is Map && v['ok'] == true) {
              final result = v['result'];
              if (result is List && result.isNotEmpty) {
                return PartInfo.fromJson(result[0] as Map<String, dynamic>);
              }
              if (result is Map<String, dynamic>) {
                return PartInfo.fromJson(result);
              }
            }
            if (v is Map<String, dynamic>) return PartInfo.fromJson(v);
            return null;
          } catch (_) {
            return null;
          }
        },
        extractError: defaultErrorExtractor,
      );
}

class _WithCommentsHolder {
  bool value = false;
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