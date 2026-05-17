import 'package:bloc/bloc.dart';
import 'package:meta/meta.dart';

import '../../../core/api/story_api_client.dart';
import '../../story/models/domain/comment_model.dart';

part 'comments_event.dart';
part 'comments_state.dart';

class CommentsBloc extends Bloc<CommentsEvent, CommentsState> {
  final StoryApiClient api;
  static const int _pageSize = 20;

  CommentsBloc({required this.api}) : super(CommentsData.initial()) {
    on<CommentsEvent>(
      (event, emit) {
        // top-level hook to trace events entering the bloc
        // keep lightweight; leave logic to specific handlers
        // ignore: avoid_print
        print('[CommentsBloc] onEvent: ${event.runtimeType} -> $event');
        return null;
      },
      transformer: (events, mapper) {
        // pass-through transformer
        return events.asyncExpand(mapper);
      },
    );
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
    print(
      '[CommentsBloc] LoadParagraphComments storyId=${e.storyId} paragraphId=${e.paragraphId} limit=${e.limit ?? _pageSize}',
    );
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
      final items = await api.fetchParagraphComments(
        e.storyId,
        e.paragraphId,
        limit: e.limit ?? _pageSize,
        offset: 0,
      );

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
    print(
      '[CommentsBloc] LoadPartComments storyId=${e.storyId} partId=${e.partId} limit=${e.limit ?? _pageSize}',
    );
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
      final items = await api.fetchPartComments(
        e.storyId,
        e.partId,
        limit: e.limit ?? _pageSize,
        offset: 0,
      );

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
    print(
      '[CommentsBloc] LoadMoreRootComments mode=${s.isParagraphMode
          ? 'paragraph'
          : s.isPartMode
          ? 'part'
          : 'none'} offset=${s.rootOffset}',
    );
    emit(s.copyWith(loadingMoreRoot: true));

    try {
      final limit = _pageSize;
      final offset = s.rootOffset;

      List<Comment> next;
      if (s.isParagraphMode) {
        next = await api.fetchParagraphComments(
          s.storyId,
          s.paragraphId!,
          limit: limit,
          offset: offset,
        );
      } else if (s.isPartMode) {
        next = await api.fetchPartComments(
          s.storyId,
          s.partId!,
          limit: limit,
          offset: offset,
        );
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
      print(
        '[CommentsBloc] Paginated roots added=${next.length} newOffset=${s.rootOffset + next.length} ended=${next.isEmpty}',
      );
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
      print(
        '[CommentsBloc] LoadReplies parent=$id skipped (loading=${s.repliesLoading.contains(id)} ended=${s.repliesEnded[id] ?? false})',
      );
      return;
    }

    // ignore: avoid_print
    print(
      '[CommentsBloc] LoadReplies parent=$id offset=${(s.replies[id] ?? const <Comment>[]).length}',
    );
    emit(s.copyWith(repliesLoading: {...s.repliesLoading, id}));

    try {
      final current = s.replies[id] ?? const <Comment>[];
      final next = await api.fetchCommentReplies(
        s.storyId,
        id,
        limit: e.limit ?? _pageSize,
        offset: current.length,
      );

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
      print(
        '[CommentsBloc] Loaded replies parent=$id added=${next.length} total=${updatedReplies[id]?.length} ended=${updatedEnded[id]}',
      );
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
