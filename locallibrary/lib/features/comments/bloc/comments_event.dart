part of 'comments_bloc.dart';

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
