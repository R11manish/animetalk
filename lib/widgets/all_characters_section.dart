import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../viewmodels/home_viewmodel.dart';
import 'character_card.dart';

class AllCharactersSection extends StatefulWidget {
  const AllCharactersSection({super.key});

  @override
  State<AllCharactersSection> createState() => _AllCharactersSectionState();
}

class _AllCharactersSectionState extends State<AllCharactersSection> {
  @override
  void initState() {
    super.initState();
    _loadInitial();
  }

  void _loadInitial() {
    context.read<HomeViewModel>().loadInitialCharacters();
  }

  bool _handleScrollNotification(ScrollNotification notification) {
    if (notification is ScrollUpdateNotification) {
      final metrics = notification.metrics;
      if (metrics.pixels >= metrics.maxScrollExtent * 0.8) {
        context.read<HomeViewModel>().loadMoreCharacters();
      }
    }
    return false; // Allow the notification to continue bubbling up
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
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
        Consumer<HomeViewModel>(
          builder: (context, viewModel, child) {
            return NotificationListener<ScrollNotification>(
              onNotification: _handleScrollNotification,
              child: Container(
                height: MediaQuery.of(context).size.height -
                    150, // Adjust height as needed
                child: GridView.builder(
                  padding: const EdgeInsets.all(8.0),
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 2,
                    childAspectRatio: 0.8,
                    crossAxisSpacing: 10,
                    mainAxisSpacing: 10,
                  ),
                  itemCount: viewModel.allCharacters.length +
                      (viewModel.hasMore ? 1 : 0),
                  itemBuilder: (context, index) {
                    if (index >= viewModel.allCharacters.length) {
                      return const Center(
                        child: Padding(
                          padding: EdgeInsets.all(8.0),
                          child: CircularProgressIndicator(),
                        ),
                      );
                    }

                    var currentCharacter = viewModel.allCharacters[index];
                    return StreamBuilder<bool>(
                      stream: viewModel.watchCharIsFav(currentCharacter.name),
                      builder: (context, snapshot) {
                        return CharacterCard(
                          character: currentCharacter,
                          isFavorite: snapshot.data ?? false,
                          onFavoritePressed: () =>
                              viewModel.toggleFavCharacter(currentCharacter),
                        );
                      },
                    );
                  },
                ),
              ),
            );
          },
        ),
        Consumer<HomeViewModel>(
          builder: (context, viewModel, child) {
            if (viewModel.isLoading && viewModel.allCharacters.isNotEmpty) {
              return const Padding(
                padding: EdgeInsets.all(8.0),
                child: Center(child: CircularProgressIndicator()),
              );
            }
            return const SizedBox.shrink();
          },
        ),
      ],
    );
  }
}
