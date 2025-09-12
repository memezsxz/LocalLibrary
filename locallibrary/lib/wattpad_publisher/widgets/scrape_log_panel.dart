import 'dart:async';
import 'dart:convert';

import 'package:flutter/material.dart';

import '../../dependency_ingection.dart';
import '../datasource.dart';
import '../models/logs.dart';

class ScrapeLogsPanel extends StatefulWidget {
  const ScrapeLogsPanel({super.key});

  @override
  State<ScrapeLogsPanel> createState() => _ScrapeLogsPanelState();
}

class _ScrapeLogsPanelState extends State<ScrapeLogsPanel> {
  final _scroll = ScrollController();
  StreamSubscription<BaseLog>? _sub;   // <- typed to BaseLog hierarchy
  final List<BaseLog> _logs = [];
  bool _running = false;

  @override
  void dispose() {
    _sub?.cancel();
    _scroll.dispose();
    super.dispose();
  }

  void _start() {
    _sub?.cancel();
    _logs.clear();
    setState(() => _running = true);

    // Start the SSE stream and parse to BaseLog models.
    _sub = _toLogs(
      sl.get<AppApiDataSource>().streamScrapeStory(
        // storyUrl: "https://www.wattpad.com/story/17621876-%D8%A5%D9%85%D8%A8%D8%B1%D8%A7%D8%B7%D9%88%D8%B1-%D8%B9%D8%A7%D9%84%D9%85-%D8%A7%D9%84%D8%B4%D8%B1",
        // storyUrl: "https://www.wattpad.com/story/397544979-testing",
        storyUrl: "https://www.wattpad.com/story/85730570",
        clearOutput: true,
      ),
    ).listen(
          (log) {
        setState(() => _logs.add(log));
        _autoScroll();
      },
      onError: (_) {
        setState(() => _running = false);
        _autoScroll();
      },
      onDone: () {
        setState(() => _running = false);
        _autoScroll();
      },
      cancelOnError: false,
    );
  }

  /// Convert ScrapeEvent stream -> BaseLog models using json_serializable classes.
  Stream<BaseLog> _toLogs(Stream<ScrapeEvent> s) async* {
    await for (final evt in s) {
      if (evt.type != 'log') continue;

      Map<String, dynamic>? m;
      final data = evt.data;
      if (data is Map<String, dynamic>) {
        m = data;
      } else if (data is String) {
        try {
          final decoded = jsonDecode(data);
          if (decoded is Map<String, dynamic>) m = decoded;
        } catch (_) {/* ignore non-JSON */}
      }
      if (m == null) continue;

      // parseAnyLog chooses the right subclass based on m['event']
      yield parseAnyLog(m);
    }
  }

  void _autoScroll() {
    if (!_scroll.hasClients) return;
    final max = _scroll.position.maxScrollExtent;
    final current = _scroll.position.pixels;
    if ((max - current) < 200) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (_scroll.hasClients) {
          _scroll.jumpTo(_scroll.position.maxScrollExtent);
        }
      });
    }
  }

  // Render a single line for each log. You can turn these into rich rows later.
  String _render(BaseLog log) {
    if (log is JobStartLog) {
      final target = log.request.storyUrl ?? log.request.partUrl ?? '';
      return '[${log.level}] ${log.ts.toIso8601String()} job.start cmd=${log.cmd} dir=${log.jobDir} target=$target';
    }
    if (log is JobEndLog) {
      return '[${log.level}] ${log.ts.toIso8601String()} job.end cmd=${log.cmd} dir=${log.jobDir}';
    }
    if (log is SpiderOpenedLog) {
      final urls = log.startUrlsCount ?? 0;
      return '[${log.level}] ${log.ts.toIso8601String()} spider.opened name=${log.spiderName} urls=$urls';
    }
    if (log is SpiderClosedLog) {
      return '[${log.level}] ${log.ts.toIso8601String()} spider.closed reason=${log.reason}';
    }
    if (log is CommentsPageLog) {
      return '[${log.level}] ${log.ts.toIso8601String()} comments.page part=${log.partId} size=${log.pageSize} total=${log.totalSoFar}';
    }
    if (log is CommentsBatchingStartLog) {
      return '[${log.level}] ${log.ts.toIso8601String()} comments.batching.start part=${log.partId} total=${log.totalComments} size=${log.batchSize} batches=${log.batches}';
    }
    if (log is CommentsBatchSavedLog) {
      return '[${log.level}] ${log.ts.toIso8601String()} comments.batch.saved part=${log.partId} ${log.batchIndex}/${log.batches} count=${log.count} → ${log.filename}';
    }
    if (log is ItemScrapedLog) {
      final id = log.wattId ?? log.partId ?? '';
      final url = log.url ?? log.responseUrl ?? '';
      final cnt = log.commentsCount != null ? ' count=${log.commentsCount}' : '';
      return '[${log.level}] ${log.ts.toIso8601String()} item.scraped type=${log.itemType} id=$id url=$url$cnt';
    }

    // Unknown/Generic
    if (log is GenericLog) {
      return '[${log.level}] ${log.ts.toIso8601String()} ${log.logger} ${log.message ?? jsonEncode(log.extra ?? const {})}';
    }
    return '${log.ts.toIso8601String()} ${log.level} ${log.logger} ${log.event ?? ''}';
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Row(
          children: [
            ElevatedButton(
              onPressed: _running ? null : _start,
              child: Text(_running ? 'scraping…' : 'scrape'),
            ),
            const SizedBox(width: 12),
            if (_running)
              TextButton(
                onPressed: () async {
                  await _sub?.cancel();
                  setState(() => _running = false);
                },
                child: const Text('stop'),
              ),
          ],
        ),
        const SizedBox(height: 8),
        Expanded(
          child: Container(
            decoration: BoxDecoration(
              border: Border.all(color: Theme.of(context).dividerColor),
              borderRadius: BorderRadius.circular(8),
            ),
            child: ListView.separated(
              controller: _scroll,
              padding: const EdgeInsets.all(8),
              itemCount: _logs.length,
              separatorBuilder: (_, __) => const SizedBox(height: 6),
              itemBuilder: (_, i) => SelectableText(
                _render(_logs[i]),
                style: const TextStyle(fontFamily: 'monospace', fontSize: 12.5),
              ),
            ),
          ),
        ),
      ],
    );
  }
}
