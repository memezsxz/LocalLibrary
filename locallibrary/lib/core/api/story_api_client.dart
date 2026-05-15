import 'package:dio/dio.dart';
import 'package:retrofit/retrofit.dart';

import '../../features/story/models/domain/book_cover_model.dart';
import '../../features/story/models/domain/part_model.dart';
import '../../features/story/models/dto/part_full_info.dart';
import '../../features/story/models/dto/story_bundle.dart';
import 'dto/comment_page.dart';
import 'dto/count_response.dart';

part 'story_api_client.g.dart';

@RestApi()
abstract class StoryApiClient {
  factory StoryApiClient(Dio dio, {String baseUrl}) = _StoryApiClient;

  @GET('/app/stories/{storyId}')
  Future<StoryBundle> getFullStoryInfo(@Path('storyId') int storyId);

  @GET('/app/stories/{storyId}/parts/{partId}')
  Future<PartFullInfo> getFullPartInfo(
    @Path('storyId') int storyId,
    @Path('partId') int partId,
  );

  @GET('/stories/{storyId}/min')
  Future<BookMinimal> fetchMinimal(@Path('storyId') int storyId);

  @GET('/stories/{storyId}/parts/{partId}/paragraphs')
  Future<List<Paragraph>> fetchPartParagraphs(
    @Path('storyId') int storyId,
    @Path('partId') int partId,
    @Query('limit') int limit,
    @Query('offset') int offset,
  );

  @GET('/app/stories/{storyId}/paragraphs/{paragraphId}/comments')
  Future<CommentPage> fetchParagraphComments(
    @Path('storyId') int storyId,
    @Path('paragraphId') int paragraphId, {
    @Query('limit') int? limit,
    @Query('offset') int? offset,
  });

  @GET('/app/stories/{storyId}/parts/{partId}/comments')
  Future<CommentPage> fetchPartComments(
    @Path('storyId') int storyId,
    @Path('partId') int partId, {
    @Query('limit') int? limit,
    @Query('offset') int? offset,
  });

  @GET('/app/stories/{storyId}/comments/{commentId}/replies')
  Future<CommentPage> fetchCommentReplies(
    @Path('storyId') int storyId,
    @Path('commentId') int commentId, {
    @Query('limit') int? limit,
    @Query('offset') int? offset,
  });

  @GET('/app/stories/{storyId}/parts/{partId}/paragraphs/count')
  Future<CountResponse> getPartParagraphsCount(
    @Path('storyId') int storyId,
    @Path('partId') int partId,
  );

  @GET('/app/stories/{storyId}/parts/{partId}/comments/count')
  Future<CountResponse> getPartCommentsCount(
    @Path('storyId') int storyId,
    @Path('partId') int partId,
  );
}
