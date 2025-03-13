import 'dart:convert';

import 'package:AnimeTalk/core/network/api_client.dart';
import 'package:AnimeTalk/core/network/api_endpoints.dart';
import 'package:AnimeTalk/models/character_model.dart';
import 'package:AnimeTalk/utility/functions.dart';

class Characters {
  late ApiClient _apiClient;

  Characters() {
    _apiClient = ApiClient();
  }

  Future<Map<String, dynamic>> getFeaturedCharacters(
      int? limit, String? lastKey) async {
    final response = await _apiClient.get(ApiEndpoints.featured,
        queryParameters: {'limit': 8, 'lastKey': jsonEncode(lastKey)});

    if (response.data == null || !response.data.containsKey('data')) {
      throw Exception('Invalid response format: missing data property');
    }

    final List<dynamic> charactersData = response.data['data'];
    final String? nextLastKey = response.data['lastKey'].toString();

    return {
      'characters': charactersData
          .map((char) => ICharacter(
                name: char['name'],
                description: char['description'],
                profileUrl: char['profileUrl'],
              ))
          .toList(),
      'lastKey': nextLastKey,
    };
  }

  Future<Map<String, dynamic>> getAllCharacters(
      int? limit, String? lastKey) async {
    final response = await _apiClient.get(ApiEndpoints.all,
        queryParameters: {'limit': 12, 'lastKey': jsonEncode(lastKey)});

    if (response.data == null || !response.data.containsKey('data')) {
      throw Exception('Invalid response format: missing data property');
    }

    final List<dynamic> charactersData = response.data['data'];
    final String? nextLastKey = response.data['lastKey'].toString();

    return {
      'characters': charactersData
          .map((char) => ICharacter(
                name: char['name'],
                description: char['description'],
                profileUrl: char['profileUrl'],
              ))
          .toList(),
      'lastKey': nextLastKey,
    };
  }
}
