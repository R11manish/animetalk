import 'package:AnimeTalk/core/api/api_client.dart';
import 'package:AnimeTalk/data/database/database.dart';
import 'package:AnimeTalk/data/repositories/character_repository.dart';
import 'package:AnimeTalk/data/repositories/message_repository.dart';
import 'package:AnimeTalk/services/character_service.dart';
import 'package:get_it/get_it.dart';

final getIt = GetIt.instance;

void setupServiceLocator() {
  getIt.registerLazySingleton<AppDatabase>(() => AppDatabase());

  getIt.registerLazySingleton<ApiClient>(() => ApiClient(
        baseUrl: 'https://api.example.com',
        useMockData: true,
      ));

  getIt.registerLazySingleton<CharacterService>(
    () => CharacterService(apiClient: getIt<ApiClient>()),
  );

  getIt.registerLazySingleton<CharacterRepository>(
    () => CharacterRepository(getIt<AppDatabase>()),
  );

  getIt.registerLazySingleton<MessageRepository>(
    () => MessageRepository(getIt<AppDatabase>()),
  );
}
