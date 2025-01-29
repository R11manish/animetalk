import "package:AnimeTalk/core/api/api_client.dart";
import "package:AnimeTalk/models/character_model.dart";

class CharacterService {
  final ApiClient _apiClient;

  CharacterService({required ApiClient apiClient}) : _apiClient = apiClient;

  Future<List<ICharacter>> getFeaturedCharacters() async {
    try {
      final characters = await _apiClient.getCharacters();
      // For this example, we'll consider the first 5 characters as featured
      return characters
          .take(5)
          .map((apiChar) => ICharacter(
                name: apiChar.name,
                nameChecking: apiChar.nameChecking,
                description: apiChar.description,
                imageUrl: apiChar.imageUrl,
              ))
          .toList();
    } catch (e) {
      throw Exception('Failed to fetch featured characters: $e');
    }
  }

  Future<List<ICharacter>> getAllCharacters() async {
    try {
      final characters = await _apiClient.getCharacters();
      return characters
          .map((apiChar) => ICharacter(
                name: apiChar.name,
                nameChecking: apiChar.nameChecking,
                description: apiChar.description,
                imageUrl: apiChar.imageUrl,
              ))
          .toList();
    } catch (e) {
      throw Exception('Failed to fetch all characters: $e');
    }
  }
}
