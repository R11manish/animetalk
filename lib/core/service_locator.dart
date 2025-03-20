import 'package:animetalk/core/network/api_client.dart';
import 'package:animetalk/data/database/database.dart';
import 'package:animetalk/data/repositories/character_repository.dart';
import 'package:animetalk/data/repositories/message_repository.dart';
import 'package:animetalk/services/token_service.dart';
import 'package:get_it/get_it.dart';
import 'package:flutter/material.dart';

final getIt = GetIt.instance;

void setupServiceLocator() {
  getIt.registerLazySingleton<AppDatabase>(() => AppDatabase());

  getIt.registerLazySingleton<ApiClient>(() => ApiClient());

  getIt.registerLazySingleton<TokenService>(() => TokenService());

  getIt.registerLazySingleton<CharacterRepository>(
    () => CharacterRepository(getIt<AppDatabase>()),
  );

  getIt.registerLazySingleton<MessageRepository>(
    () => MessageRepository(getIt<AppDatabase>()),
  );

  // Register the GlobalKey<NavigatorState>
  getIt.registerLazySingleton<GlobalKey<NavigatorState>>(
      () => GlobalKey<NavigatorState>());
}
