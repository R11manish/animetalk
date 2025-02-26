import 'package:AnimeTalk/core/network/api_client.dart';
import 'package:AnimeTalk/core/network/api_endpoints.dart';
import 'package:AnimeTalk/models/character_model.dart';

class Characters {
  late ApiClient _apiClient;

  Characters() {
    _apiClient = ApiClient();
  }

  Future<List<ICharacter>> getFeaturedCharacters() async {
    final response = await _apiClient.get(ApiEndpoints.featured);

    final List<dynamic> charactersData = response.data['data'];

    return charactersData
        .map((char) => ICharacter(
              name: char['name'],
              description: char['description'],
              profileUrl: char['profileUrl'],
            ))
        .toList();
  }

  Future<List<ICharacter>> getAllCharacters() async {
    try {
      final response = await _apiClient.get(ApiEndpoints.all);

      if (response.data == null || !response.data.containsKey('data')) {
        throw Exception('Invalid response format: missing data property');
      }

      final List<dynamic> charactersData = response.data['data'];

      return charactersData
          .map((char) => ICharacter(
                name: char['name'],
                description: char['description'],
                profileUrl: char['profileUrl'],
              ))
          .toList();
    } catch (e) {
      throw Exception('Failed to fetch all characters: $e');
    }
  }
}
