// dependency_injection.dart
import 'package:dio/dio.dart';
import 'package:get_it/get_it.dart';
import 'package:locallibrary/wattpad_publisher/bloc/comments_bloc.dart';
import 'package:locallibrary/wattpad_publisher/bloc/part_bloc.dart';
import 'package:locallibrary/wattpad_publisher/bloc/story_bloc.dart';
import 'package:locallibrary/wattpad_publisher/cubit/part_side_panel_cubit.dart';

import 'core/secrets/app_secrets.dart';
import 'wattpad_publisher/datasource.dart';

final sl = GetIt.instance;

void initDI() {
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

  sl.registerLazySingleton<PartSidePanelCubit>(() => PartSidePanelCubit());
  sl.registerLazySingleton<CommentsBloc>(
    () => CommentsBloc(api: sl<AppApiDataSource>()),
  );

  // sl<Dio>().interceptors.add(LogInterceptor(
  //     request: true, requestBody: true, responseBody: true, error: true));
}
