// dependency_injection.dart
import 'package:dio/dio.dart';
import 'package:flutter/cupertino.dart';
import 'package:get_it/get_it.dart';

import 'core/api/library_api_client.dart';
import 'core/api/notifications_api_client.dart';
import 'core/api/scrape_service.dart';
import 'core/api/story_api_client.dart';
import 'core/secrets/app_secrets.dart';
import 'features/comments/bloc/comments_bloc.dart';
import 'features/library/bloc/search_bloc.dart';
import 'features/library/cubit/search_cubit.dart';
import 'features/notifications/bloc/notifications_bloc.dart';
import 'features/part/bloc/part_bloc.dart';
import 'features/part/cubit/part_side_panel_cubit.dart';
import 'features/part/cubit/reading_settings_cubit.dart';
import 'features/settings/cubit/settings_cubit.dart';
import 'features/story/bloc/scrape_story_bloc.dart';
import 'features/story/bloc/story_bloc.dart';

final sl = GetIt.instance;

void initDI() {
  WidgetsFlutterBinding.ensureInitialized();

  final base = AppSecrets.apiBaseUrl;

  sl.registerLazySingleton<Dio>(
    () => Dio(
      BaseOptions(
        baseUrl: base,
        connectTimeout: const Duration(seconds: 8),
        receiveTimeout: const Duration(seconds: 8),
        headers: {'Accept': 'application/json'},
      ),
    ),
  );

  sl.registerLazySingleton<StoryApiClient>(
        () => StoryApiClient(sl<Dio>()),
  );

  sl.registerLazySingleton<LibraryApiClient>(
        () => LibraryApiClient(sl<Dio>()),
  );

  sl.registerLazySingleton<ScrapeService>(
        () => ScrapeService(baseUrl: base),
  );

  sl.registerLazySingleton<NotificationsApiClient>(
        () => NotificationsApiClient(sl<Dio>()),
  );

  sl.registerLazySingleton<StoryBloc>(
        () => StoryBloc(api: sl<StoryApiClient>()),
  );

  sl.registerLazySingleton<SearchCubit>(() => SearchCubit());

  sl.registerLazySingleton<SearchBloc>(
        () => SearchBloc(api: sl<LibraryApiClient>()),
  );

  sl.registerFactory<PartBloc>(() => PartBloc(api: sl<StoryApiClient>()));

  sl.registerFactory<PartSidePanelCubit>(() => PartSidePanelCubit());
  sl.registerFactory<CommentsBloc>(
        () => CommentsBloc(api: sl<StoryApiClient>()),
  );

  sl.registerLazySingleton<SettingsCubit>(
        () => SettingsCubit(),
  );

  sl.registerLazySingleton<ReadingSettingsCubit>(
        () => ReadingSettingsCubit(),
  );

  sl.registerLazySingleton<ScrapeStoryBloc>(
        () => ScrapeStoryBloc(api: sl<ScrapeService>()),
  );

  sl.registerFactory<NotificationsBloc>(
        () => NotificationsBloc(api: sl<NotificationsApiClient>()),
  );
}