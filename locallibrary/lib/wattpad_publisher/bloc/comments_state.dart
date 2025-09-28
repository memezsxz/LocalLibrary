part of 'comments_bloc.dart';


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
