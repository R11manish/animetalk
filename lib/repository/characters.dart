import 'package:animetalk/core/network/api_client.dart';
import 'package:animetalk/core/network/api_endpoints.dart';
import 'package:animetalk/models/character_model.dart';

class Characters {
  late ApiClient _apiClient;

  Characters() {
    _apiClient = ApiClient();
  }

  Future<Map<String, dynamic>> getFeaturedCharacters(
      int? limit, String? nextPageToken) async {
    Map<String, dynamic> queryParams = {'limit': limit ?? 10};

    if (nextPageToken != null) {
      queryParams['nextPageToken'] = nextPageToken;
    }

    final response = await _apiClient.get(ApiEndpoints.featured,
        queryParameters: queryParams);

    if (response.data == null || !response.data.containsKey('data')) {
      throw Exception('Invalid response format: missing data property');
    }

    final List<dynamic> charactersData = response.data['data'];
    final String? nextToken = response.data['nextPageToken'];

    return {
      'characters': charactersData
          .map((char) => ICharacter(
                name: char['name'],
                description: char['description'],
                profileUrl: char['profileUrl'],
              ))
          .toList(),
      'nextPageToken': nextToken,
    };
  }

  Future<Map<String, dynamic>> getAllCharacters(
      int? limit, String? nextPageToken) async {
    Map<String, dynamic> queryParams = {'limit': limit ?? 10};

    if (nextPageToken != null) {
      queryParams['nextPageToken'] = nextPageToken;
    }

    final response =
        await _apiClient.get(ApiEndpoints.all, queryParameters: queryParams);

    if (response.data == null || !response.data.containsKey('data')) {
      throw Exception('Invalid response format: missing data property');
    }

    final List<dynamic> charactersData = response.data['data'];
    final String? nextToken = response.data.containsKey('nextPageToken')
        ? response.data['nextPageToken']
        : null;

    return {
      'characters': charactersData
          .map((char) => ICharacter(
                name: char['name'],
                description: char['description'],
                profileUrl: char['profileUrl'],
              ))
          .toList(),
      'nextPageToken': nextToken,
    };
  }
}
