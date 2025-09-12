import 'package:bloc/bloc.dart';
import 'package:meta/meta.dart';

import '../datasource.dart';
import '../models/models.dart';

@immutable
sealed class CommentsEvent {}

/// Load first page for a paragraph.
class LoadParagraphComments extends CommentsEvent {
  final int storyId;
  final int paragraphId;
  final int? limit;

  LoadParagraphComments(this.storyId, this.paragraphId, {this.limit});
}

/// Load first page for a part.
class LoadPartComments extends CommentsEvent {
  final int storyId;
  final int partId;
  final int? limit;

  LoadPartComments(this.storyId, this.partId, {this.limit});
}

/// Load next page of root comments (paragraph/part whichever is active).
class LoadMoreRootComments extends CommentsEvent {}

/// Load first (or next) page of replies for a parent comment.
class LoadReplies extends CommentsEvent {
  final int parentCommentId;
  final int? limit;

  LoadReplies(this.parentCommentId, {this.limit});
}

@immutable
sealed class CommentsState {}

/// Single-state model that holds roots + replies (with offsets/load flags).
class CommentsData extends CommentsState {
  final int storyId;
  final int? paragraphId; // when in paragraph mode
  final int? partId; // when in part mode

  final List<Comment> roots;
  final int rootOffset;
  final bool rootEnded;
  final bool loadingRoot;
  final bool loadingMoreRoot;

  /// Per parent comment:
  final Map<int, List<Comment>> replies;
  final Map<int, int> repliesOffset; // next offset to request, per parent
  final Map<int, bool> repliesEnded; // stop when true, per parent
  final Set<int> repliesLoading; // currently loading parent ids

  final String? error;

  CommentsData({
    required this.storyId,
    required this.paragraphId,
    required this.partId,
    required this.roots,
    required this.rootOffset,
    required this.rootEnded,
    required this.loadingRoot,
    required this.loadingMoreRoot,
    required this.replies,
    required this.repliesOffset,
    required this.repliesEnded,
    required this.repliesLoading,
    required this.error,
  });

  factory CommentsData.initial() => CommentsData(
    storyId: -1,
    paragraphId: null,
    partId: null,
    roots: <Comment>[],
    rootOffset: 0,
    rootEnded: false,
    loadingRoot: false,
    loadingMoreRoot: false,
    replies: <int, List<Comment>>{},
    repliesOffset: <int, int>{},
    repliesEnded: <int, bool>{},
    repliesLoading: <int>{},
    error: null,
  );

  bool get isParagraphMode => paragraphId != null;

  bool get isPartMode => partId != null;

  CommentsData copyWith({
    int? storyId,
    int? paragraphId,
    int? partId,
    List<Comment>? roots,
    int? rootOffset,
    bool? rootEnded,
    bool? loadingRoot,
    bool? loadingMoreRoot,
    Map<int, List<Comment>>? replies,
    Map<int, int>? repliesOffset,
    Map<int, bool>? repliesEnded,
    Set<int>? repliesLoading,
    String? error,
  }) {
    return CommentsData(
      storyId: storyId ?? this.storyId,
      paragraphId: paragraphId ?? this.paragraphId,
      partId: partId ?? this.partId,
      roots: roots ?? this.roots,
      rootOffset: rootOffset ?? this.rootOffset,
      rootEnded: rootEnded ?? this.rootEnded,
      loadingRoot: loadingRoot ?? this.loadingRoot,
      loadingMoreRoot: loadingMoreRoot ?? this.loadingMoreRoot,
      replies: replies ?? this.replies,
      repliesOffset: repliesOffset ?? this.repliesOffset,
      repliesEnded: repliesEnded ?? this.repliesEnded,
      repliesLoading: repliesLoading ?? this.repliesLoading,
      error: error ?? this.error,
    );
  }
}

class CommentsBloc extends Bloc<CommentsEvent, CommentsState> {
  final AppApiDataSource api;
  static const int _pageSize = 20;

  CommentsBloc({required this.api}) : super(CommentsData.initial()) {
    on<CommentsEvent>((event, emit) {
      // top-level hook to trace events entering the bloc
      // keep lightweight; leave logic to specific handlers
      // ignore: avoid_print
      print('[CommentsBloc] onEvent: ${event.runtimeType} -> $event');
      return null;
    }, transformer: (events, mapper) {
      // pass-through transformer
      return events.asyncExpand(mapper);
    });
    on<LoadParagraphComments>(_onLoadParagraphComments);
    on<LoadPartComments>(_onLoadPartComments);
    on<LoadMoreRootComments>(_onLoadMoreRootComments);
    on<LoadReplies>(_onLoadReplies);
  }

  // ---------------- roots: paragraph ----------------
  // 1) Paragraph first page
  Future<void> _onLoadParagraphComments(
    LoadParagraphComments e,
    Emitter<CommentsState> emit,
  ) async {
    // ignore: avoid_print
    print('[CommentsBloc] LoadParagraphComments storyId=${e.storyId} paragraphId=${e.paragraphId} limit=${e.limit ?? _pageSize}');
    final loading = CommentsData(
      storyId: e.storyId,
      paragraphId: e.paragraphId,
      partId: null,
      roots: const [],
      rootOffset: 0,
      rootEnded: false,
      loadingRoot: true,
      loadingMoreRoot: false,
      replies: const {},
      repliesOffset: const {},
      repliesEnded: const {},
      repliesLoading: const {},
      error: null,
    );
    emit(loading);

    try {
      final page = await api.fetchParagraphComments(
        storyId: e.storyId,
        paragraphId: e.paragraphId,
        limit: e.limit ?? _pageSize,
        offset: 0,
      );
      final items = page.items; // <-- unwrap

      emit(
        loading.copyWith(
          roots: items,
          rootOffset: items.length,
          loadingRoot: false,
          // per your rule: stop when API returns 0 items
          rootEnded: items.isEmpty,
        ),
      );
      // ignore: avoid_print
      print('[CommentsBloc] Loaded paragraph roots count=${items.length}');
    } catch (err) {
      emit(
        loading.copyWith(
          loadingRoot: false,
          rootEnded: true,
          error: err.toString(),
        ),
      );
      // ignore: avoid_print
      print('[CommentsBloc] LoadParagraphComments ERROR: $err');
    }
  }

  // ---------------- roots: part ----------------
  // 2) Part first page
  Future<void> _onLoadPartComments(
    LoadPartComments e,
    Emitter<CommentsState> emit,
  ) async {
    // ignore: avoid_print
    print('[CommentsBloc] LoadPartComments storyId=${e.storyId} partId=${e.partId} limit=${e.limit ?? _pageSize}');
    final loading = CommentsData(
      storyId: e.storyId,
      paragraphId: null,
      partId: e.partId,
      roots: const [],
      rootOffset: 0,
      rootEnded: false,
      loadingRoot: true,
      loadingMoreRoot: false,
      replies: const {},
      repliesOffset: const {},
      repliesEnded: const {},
      repliesLoading: const {},
      error: null,
    );
    emit(loading);

    try {
      final page = await api.fetchPartComments(
        storyId: e.storyId,
        partId: e.partId,
        limit: e.limit ?? _pageSize,
        offset: 0,
      );
      final items = page.items; // <-- unwrap

      emit(
        loading.copyWith(
          roots: items,
          rootOffset: items.length,
          loadingRoot: false,
          rootEnded: items.isEmpty,
        ),
      );
      // ignore: avoid_print
      print('[CommentsBloc] Loaded part roots count=${items.length}');
    } catch (err) {
      emit(
        loading.copyWith(
          loadingRoot: false,
          rootEnded: true,
          error: err.toString(),
        ),
      );
      // ignore: avoid_print
      print('[CommentsBloc] LoadPartComments ERROR: $err');
    }
  }

  // ---------------- pagination for roots (paragraph or part) ----------------
  // 3) Roots pagination (paragraph or part)
  Future<void> _onLoadMoreRootComments(
    LoadMoreRootComments e,
    Emitter<CommentsState> emit,
  ) async {
    final s = state;
    if (s is! CommentsData) return;
    if (s.loadingMoreRoot || s.rootEnded) return;

    // ignore: avoid_print
    print('[CommentsBloc] LoadMoreRootComments mode=${s.isParagraphMode ? 'paragraph' : s.isPartMode ? 'part' : 'none'} offset=${s.rootOffset}');
    emit(s.copyWith(loadingMoreRoot: true));

    try {
      final limit = _pageSize;
      final offset = s.rootOffset;

      List<Comment> next;
      if (s.isParagraphMode) {
        final page = await api.fetchParagraphComments(
          storyId: s.storyId,
          paragraphId: s.paragraphId!,
          limit: limit,
          offset: offset,
        );
        next = page.items; // <-- unwrap
      } else if (s.isPartMode) {
        final page = await api.fetchPartComments(
          storyId: s.storyId,
          partId: s.partId!,
          limit: limit,
          offset: offset,
        );
        next = page.items; // <-- unwrap
      } else {
        next = const <Comment>[];
      }

      emit(
        s.copyWith(
          roots: [...s.roots, ...next],
          rootOffset: s.rootOffset + next.length,
          loadingMoreRoot: false,
          // stop when API returns 0 items
          rootEnded: next.isEmpty,
        ),
      );
      // ignore: avoid_print
      print('[CommentsBloc] Paginated roots added=${next.length} newOffset=${s.rootOffset + next.length} ended=${next.isEmpty}');
    } catch (err) {
      emit(s.copyWith(loadingMoreRoot: false, error: err.toString()));
      // ignore: avoid_print
      print('[CommentsBloc] LoadMoreRootComments ERROR: $err');
    }
  }

  // ---------------- replies pagination (per parent) ----------------
  // 4) Replies pagination
  Future<void> _onLoadReplies(
    LoadReplies e,
    Emitter<CommentsState> emit,
  ) async {
    final s = state;
    if (s is! CommentsData) return;

    final id = e.parentCommentId;
    if (s.repliesLoading.contains(id) || (s.repliesEnded[id] ?? false)) {
      // ignore: avoid_print
      print('[CommentsBloc] LoadReplies parent=$id skipped (loading=${s.repliesLoading.contains(id)} ended=${s.repliesEnded[id] ?? false})');
      return;
    }

    // ignore: avoid_print
    print('[CommentsBloc] LoadReplies parent=$id offset=${(s.replies[id] ?? const <Comment>[]).length}');
    emit(s.copyWith(repliesLoading: {...s.repliesLoading, id}));

    try {
      final current = s.replies[id] ?? const <Comment>[];
      final page = await api.fetchCommentReplies(
        storyId: s.storyId,
        commentId: id,
        limit: e.limit ?? _pageSize,
        offset: current.length,
      );
      final next = page.items; // <-- unwrap

      final updatedReplies = Map<int, List<Comment>>.from(s.replies)
        ..[id] = [...current, ...next];

      final updatedOffsets = Map<int, int>.from(s.repliesOffset)
        ..[id] = current.length + next.length;

      final updatedEnded = Map<int, bool>.from(s.repliesEnded)
        ..[id] = next.isEmpty; // stop when API returns 0

      emit(
        s.copyWith(
          replies: updatedReplies,
          repliesOffset: updatedOffsets,
          repliesEnded: updatedEnded,
          repliesLoading: s.repliesLoading.where((x) => x != id).toSet(),
        ),
      );
      // ignore: avoid_print
      print('[CommentsBloc] Loaded replies parent=$id added=${next.length} total=${updatedReplies[id]?.length} ended=${updatedEnded[id]}');
    } catch (err) {
      emit(
        s.copyWith(
          repliesLoading: s.repliesLoading.where((x) => x != id).toSet(),
          error: err.toString(),
        ),
      );
      // ignore: avoid_print
      print('[CommentsBloc] LoadReplies ERROR parent=$id: $err');
    }
  }
}
