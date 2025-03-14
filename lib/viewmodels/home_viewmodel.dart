import 'package:flutter/material.dart';
import 'package:AnimeTalk/core/service_locator.dart';
import 'package:AnimeTalk/data/repositories/character_repository.dart';
import 'package:AnimeTalk/models/character_model.dart';
import 'package:AnimeTalk/repository/characters.dart' as char;

class HomeViewModel extends ChangeNotifier {
  final char.Characters _characterService;
  final CharacterRepository _characterRepository;
  static const int pageSize = 10;

  List<ICharacter> allCharacters = [];
  List<ICharacter> featuredCharacters = [];
  String? nextPageTokenCharacter;
  String? nextPageTokenFeature;
  bool isLoading = false;
  bool hasMore = true;
  bool isLoadingFeatured = false;
  bool hasMoreFeatured = true;

  HomeViewModel({
    char.Characters? characterService,
    CharacterRepository? characterRepository,
  })  : _characterService = characterService ?? char.Characters(),
        _characterRepository =
            characterRepository ?? getIt<CharacterRepository>();

  Future<void> loadInitialCharacters() async {
    allCharacters.clear();
    nextPageTokenCharacter = null;
    hasMore = true;
    await loadMoreCharacters();
  }

  Future<void> loadMoreCharacters() async {
    if (isLoading || !hasMore) return;

    isLoading = true;
    notifyListeners();

    try {
      final response = await _characterService.getAllCharacters(
          pageSize, nextPageTokenCharacter);
      final List<ICharacter> characters = response['characters'];
      final String? nextToken = response['nextPageToken'];

      if (characters.isEmpty || nextToken == null) {
        hasMore = false;
      } else {
        allCharacters.addAll(characters);
        nextPageTokenCharacter = nextToken;
      }
    } catch (e) {
      hasMore = false;
    } finally {
      isLoading = false;
      notifyListeners();
    }
  }

  Future<void> loadInitialFeaturedCharacters() async {
    featuredCharacters.clear();
    nextPageTokenFeature = null;
    hasMoreFeatured = true;
    await loadMoreFeaturedCharacters();
  }

  Future<void> loadMoreFeaturedCharacters() async {
    if (isLoadingFeatured || !hasMoreFeatured) return;

    isLoadingFeatured = true;
    notifyListeners();

    try {
      final response = await _characterService.getFeaturedCharacters(
          pageSize, nextPageTokenFeature);
      final List<ICharacter> characters = response['characters'];
      final String? nextToken = response['nextPageToken'];

      if (characters.isEmpty || nextToken == null) {
        hasMoreFeatured = false;
      } else {
        featuredCharacters.addAll(characters);
        nextPageTokenFeature = nextToken;
      }
    } catch (e) {
      hasMoreFeatured = false;
    } finally {
      isLoadingFeatured = false;
      notifyListeners();
    }
  }

  Stream<bool> watchCharIsFav(String name) {
    return _characterRepository
        .watchCharacterByName(name)
        .map((character) => character?.favourite ?? false);
  }

  Future<void> toggleFavCharacter(ICharacter character) async {
    final existingCharacter =
        await _characterRepository.getCharacterByName(character.name);

    if (existingCharacter != null) {
      await _characterRepository.updateCharacter(
        id: existingCharacter.id,
        name: existingCharacter.name,
        description: existingCharacter.description,
        profileUrl: existingCharacter.profileUrl,
        favourite: !existingCharacter.favourite,
      );
    } else {
      await _characterRepository.createCharacter(
        name: character.name,
        description: character.description,
        profileUrl: character.profileUrl,
        favourite: true,
      );
    }
  }
}
