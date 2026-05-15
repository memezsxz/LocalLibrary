// dependency_injection.dart
import 'package:dio/dio.dart';
import 'package:flutter/cupertino.dart';
import 'package:get_it/get_it.dart';

import 'core/datasource.dart';
import 'core/secrets/app_secrets.dart';
import 'features/comments/bloc/comments_bloc.dart';
import 'features/part/bloc/part_bloc.dart';
import 'features/part/cubit/part_side_panel_cubit.dart';
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
        baseUrl: base, // <- single source of truth
        connectTimeout: const Duration(seconds: 8),
        receiveTimeout: const Duration(seconds: 8),
        headers: {'Accept': 'application/json'},
      ),
    ),
  );

  sl.registerLazySingleton<StoryRemoteDataSource>(
    () => StoryRemoteDataSourceImpl(dio: sl<Dio>()),
  );

  sl.registerLazySingleton<AppApiDataSource>(
    () => AppApiDataSource(baseUrl: "http://127.0.0.1:5050"),
  );

  sl.registerLazySingleton<StoryBloc>(
    () => StoryBloc(api: sl<AppApiDataSource>()),
  );

  sl.registerFactory<PartBloc>(() => PartBloc(api: sl<AppApiDataSource>()));

  sl.registerFactory<PartSidePanelCubit>(() => PartSidePanelCubit());
  sl.registerFactory<CommentsBloc>(
    () => CommentsBloc(api: sl<AppApiDataSource>()),
  );

  sl.registerLazySingleton<SettingsCubit>(
        () => SettingsCubit(),
  );

  sl.registerLazySingleton<ScrapeStoryBloc>(
    () => ScrapeStoryBloc(api: sl<AppApiDataSource>()),
  );

  // sl.registerLazySingleton<WindowsBloc>(
  //       () => WindowsBloc(),
  // );
  // sl<Dio>().interceptors.add(LogInterceptor(
  //     request: true, requestBody: true, responseBody: true, error: true));
}
