class ScrapeCommentsResult {
  final int commentsCount;

  const ScrapeCommentsResult({required this.commentsCount});

  factory ScrapeCommentsResult.fromJson(Map<String, dynamic> json) =>
      ScrapeCommentsResult(
        commentsCount: (json['comments_count'] as num).toInt(),
      );
}
