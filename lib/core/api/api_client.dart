import 'dart:convert';
import 'package:AnimeTalk/models/character_model.dart';
import 'package:http/http.dart' as http;
import "package:AnimeTalk/services/mock_data.dart";

class ApiClient {
  final String baseUrl =
      "https://alf9kf9ukl.execute-api.ap-south-1.amazonaws.com/";
  final bool useMockData;

  ApiClient({
    this.useMockData = false,
  });

  Future<List<ICharacter>> getCharacters() async {
    if (useMockData) {
      return MockData.characters
          .map((json) => ICharacter.fromJson(json))
          .toList();
    }

    final response = await http.get(
      Uri.parse('$baseUrl/characters'),
      headers: {'Content-Type': 'application/json'},
    );

    if (response.statusCode == 200) {
      List<dynamic> jsonList = json.decode(response.body);
      return jsonList.map((json) => ICharacter.fromJson(json)).toList();
    } else {
      throw Exception('Failed to load characters');
    }
  }

  Future<ICharacter> getCharacter(String name) async {
    if (useMockData) {
      final character = MockData.characters.firstWhere(
        (char) => char['name'] == name,
        orElse: () => throw Exception('Character not found'),
      );
      return ICharacter.fromJson(character);
    }

    final response = await http.get(
      Uri.parse('$baseUrl/characters/$name'),
      headers: {'Content-Type': 'application/json'},
    );

    if (response.statusCode == 200) {
      return ICharacter.fromJson(json.decode(response.body));
    } else {
      throw Exception('Failed to load character');
    }
  }

  Future<List<ICharacter>> searchCharacters(String query) async {
    if (useMockData) {
      final filteredCharacters = MockData.characters.where((char) =>
          char['name'].toLowerCase().contains(query.toLowerCase()) ||
          char['description'].toLowerCase().contains(query.toLowerCase()));
      return filteredCharacters
          .map((json) => ICharacter.fromJson(json))
          .toList();
    }

    final response = await http.get(
      Uri.parse('$baseUrl/characters/search?q=$query'),
      headers: {'Content-Type': 'application/json'},
    );

    if (response.statusCode == 200) {
      List<dynamic> jsonList = json.decode(response.body);
      return jsonList.map((json) => ICharacter.fromJson(json)).toList();
    } else {
      throw Exception('Failed to search characters');
    }
  }
}
