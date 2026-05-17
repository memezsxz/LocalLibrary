import 'package:dio/dio.dart';
import 'package:retrofit/retrofit.dart';

import '../../features/story/models/domain/book_cover_model.dart';
import '../../features/story/models/domain/story_model.dart';
import 'dto/filter_stories_params.dart';

part 'library_api_client.g.dart';

@RestApi()
abstract class LibraryApiClient {
  factory LibraryApiClient(Dio dio, {String baseUrl}) = _LibraryApiClient;

  @GET('/stories')
  Future<List<Story>> listStories(
    @Query('limit') int limit,
    @Query('offset') int offset,
  );

  @GET('/stories/currently_reading')
  Future<List<int>> listCurrentlyReading(
    @Query('limit') int limit,
    @Query('offset') int offset,
    @Query('timestamp') String timestamp,
  );

  @GET('/stories/recently_added')
  Future<List<int>> listRecentlyAdded(
    @Query('limit') int limit,
    @Query('offset') int offset,
    @Query('timestamp') String timestamp,
  );

  @GET('/stories/recently_finished')
  Future<List<int>> listRecentlyFinished(
    @Query('limit') int limit,
    @Query('offset') int offset,
    @Query('timestamp') String timestamp,
  );

  @GET('/tags')
  Future<List<Tag>> listAllTags();

  @GET('/genres')
  Future<List<Genre>> listAllGenres();

  @GET('/languages')
  Future<List<String>> listAllLanguages();

  @POST('/stories/search_filter')
  Future<List<BookMinimal>> searchFilter(@Body() FilterStoriesParams params);
}
