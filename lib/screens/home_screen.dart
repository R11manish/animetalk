import 'package:AnimeTalk/core/service_locator.dart';
import 'package:AnimeTalk/data/repositories/character_repository.dart';
import 'package:AnimeTalk/models/character_model.dart';
import 'package:flutter/material.dart';
import '../services/character_service.dart';
import '../widgets/character_card.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  late final CharacterService _characterService;
  late final CharacterRepository characterRepository;

  @override
  void initState() {
    super.initState();
    _characterService = getIt<CharacterService>();
    characterRepository = getIt<CharacterRepository>();

  }

  Stream<bool> watchCharIsFav(String name) {
    return characterRepository
        .watchCharacterByName(name)
        .map((character) => character?.favourite ?? false);
  }

  Future<void> _toggleFavCharacter(ICharacter character) async {
    final existingCharacter =
        await characterRepository.getCharacterByName(character.name);

    if (existingCharacter != null) {
      await characterRepository.updateCharacter(
        id: existingCharacter.id,
        name: existingCharacter.name,
        description: existingCharacter.description,
        profileUrl: existingCharacter.profileUrl,
        favourite: !existingCharacter.favourite,
      );
    } else {
      await characterRepository.createCharacter(
          name: character.name,
          description: character.description,
          profileUrl: character.profileUrl,
          favourite: true);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'AnimeTalk',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.settings),
            onPressed: () {
              // Add settings functionality
            },
          ),
        ],
      ),
      body: RefreshIndicator(
          onRefresh: () async {
            setState(() {});
          },
          child: SingleChildScrollView(
            physics: const AlwaysScrollableScrollPhysics(),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Padding(
                  padding: EdgeInsets.all(16.0),
                  child: Text(
                    'Featured Characters',
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                SizedBox(
                  height: 220,
                  child: FutureBuilder<List<ICharacter>>(
                    future: _characterService.getFeaturedCharacters(),
                    builder: (context, snapshot) {
                      if (snapshot.connectionState == ConnectionState.waiting) {
                        return const Center(child: CircularProgressIndicator());
                      }
                      if (snapshot.hasError) {
                        return Center(child: Text('Error: ${snapshot.error}'));
                      }
                      if (!snapshot.hasData || snapshot.data!.isEmpty) {
                        return const Center(
                            child: Text('No featured characters available'));
                      }

                      final featuredCharacters = snapshot.data!;
                      return ListView.builder(
                        scrollDirection: Axis.horizontal,
                        itemCount: featuredCharacters.length,
                        itemBuilder: (context, index) {
                          return SizedBox(
                            width: 160,
                            child: CharacterCard(
                              character: featuredCharacters[index],
                              isFeatured: true,
                            ),
                          );
                        },
                      );
                    },
                  ),
                ),
                const Padding(
                  padding: EdgeInsets.all(16.0),
                  child: Text(
                    'All Characters',
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                FutureBuilder<List<ICharacter>>(
                  future: _characterService.getAllCharacters(),
                  builder: (context, snapshot) {
                    if (snapshot.connectionState == ConnectionState.waiting) {
                      return const Center(child: CircularProgressIndicator());
                    }
                    if (snapshot.hasError) {
                      return Center(child: Text('Error: ${snapshot.error}'));
                    }
                    if (!snapshot.hasData || snapshot.data!.isEmpty) {
                      return const Center(
                          child: Text('No characters available'));
                    }

                    var allCharacters = snapshot.data!;
                    return GridView.builder(
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      padding: const EdgeInsets.all(8.0),
                      gridDelegate:
                          const SliverGridDelegateWithFixedCrossAxisCount(
                        crossAxisCount: 2,
                        childAspectRatio: 0.8,
                      ),
                      itemCount: allCharacters.length,
                      itemBuilder: (context, index) {
                        var currentCharacter = allCharacters[index];

                        return StreamBuilder<bool>(
                          stream: watchCharIsFav(currentCharacter.name),
                          builder: (context, snapshot) {
                            return CharacterCard(
                              character: currentCharacter,
                              isFavorite: snapshot.data ?? false,
                              onFavoritePressed: () =>
                                  _toggleFavCharacter(currentCharacter),
                            );
                          },
                        );
                      },
                    );
                  },
                ),
              ],
            ),
          )),
    );
  }
}
