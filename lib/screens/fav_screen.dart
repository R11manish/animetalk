import 'package:animetalk/core/service_locator.dart';
import 'package:animetalk/data/database/database.dart';
import 'package:animetalk/data/repositories/character_repository.dart';
import 'package:animetalk/models/character_model.dart';
import 'package:animetalk/widgets/character_card.dart';
import 'package:flutter/material.dart';

class FavScreen extends StatelessWidget {
  final CharacterRepository characterRepository = getIt<CharacterRepository>();

  FavScreen({super.key});

  Future<void> _toggleFavCharacter(String name) async {
    final existingCharacter =
        await characterRepository.getCharacterByName(name);

    if (existingCharacter != null) {
      await characterRepository.updateCharacter(
        id: existingCharacter.id,
        name: existingCharacter.name,
        description: existingCharacter.description,
        profileUrl: existingCharacter.profileUrl,
        favourite: !existingCharacter.favourite,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      physics: const AlwaysScrollableScrollPhysics(),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(16.0),
            margin: const EdgeInsets.only(top: 30.0),
            child: const Text(
              'All Characters',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          StreamBuilder<List<Character>>(
            stream: characterRepository.watchFavoriteCharacters(),
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return const Center(child: CircularProgressIndicator());
              }

              if (snapshot.hasError) {
                return Center(child: Text('Error: ${snapshot.error}'));
              }

              final characters = snapshot.data;
              if (characters == null || characters.isEmpty) {
                return const Center(child: Text('No favorite characters yet'));
              }

              return GridView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                padding: const EdgeInsets.all(8.0),
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 2,
                  childAspectRatio: 0.8,
                ),
                itemCount: characters.length,
                itemBuilder: (context, index) {
                  final character = characters[index];

                  final currentCharacter = ICharacter(
                    name: character.name,
                    description: character.description,
                    profileUrl: character.profileUrl,
                  );

                  return CharacterCard(
                    character: currentCharacter,
                    isFavorite: character.favourite,
                    isFeatured: false,
                    onFavoritePressed: () =>
                        _toggleFavCharacter(character.name),
                  );
                },
              );
            },
          ),
        ],
      ),
    );
  }
}
