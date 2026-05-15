import 'dart:convert';

import 'package:flutter/foundation.dart';

import '../../../core/datasource.dart';
import '../models/logs.dart';
import '../models/story_dto.dart';
import '../utils/scrape_json_utils.dart';
import '../utils/scrape_url_utils.dart';
import 'base_scrape_bloc.dart';

class ScrapeStoryBloc extends BaseScrapeBloc<ScrapeStoryRes> {
  final AppApiDataSource api;

  ScrapeStoryBloc({required this.api})
    : super(
        // 1) how to start the SSE stream
        startStream: (input) {
          print(input);
          final base = api.streamScrapeStory(
            storyUrl: input,
            clearOutput: false,
          ); // -> Stream<ScrapeEvent(name, payload)>
          // Fan-out if server batches multiple JSONs per payload
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

        // 2) validate input (used for hints + gating StartRequested)
        validateInput: validateStoryUrlMessage,

        // 3) parse the finished payload to a typed result
        parseFinished: (data) {
          try {
            final v = jsonDecode(data);
            final obj = (v is Map && v['ok'] == true && v['result'] is Map)
                ? v['result'] as Map<String, dynamic>
                : (v is Map<String, dynamic> ? v : null);
            if (obj == null) return null;
            // part_links may be absent/null if the server omits it —
            // the generated fromJson does a hard cast, so default it here.
            obj['part_links'] ??= <dynamic>[];
            return ScrapeStoryRes.fromJson(obj);
          } catch (e, st) {
            debugPrint('[ScrapeStoryBloc] parseFinished failed: $e\n$st');
            return null;
          }
        },

        // 4) extract human-friendly error messages
        extractError: defaultErrorExtractor,
      );
}

