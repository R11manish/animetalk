import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../viewmodels/home_viewmodel.dart';
import 'character_card.dart';

class FeaturedCharactersSection extends StatefulWidget {
  const FeaturedCharactersSection({super.key});

  @override
  State<FeaturedCharactersSection> createState() =>
      _FeaturedCharactersSectionState();
}

class _FeaturedCharactersSectionState extends State<FeaturedCharactersSection> {
  final ScrollController _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(_onScroll);
    // Use post-frame callback to avoid setState during build
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) {
        _loadInitial();
      }
    });
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  void _loadInitial() {
    // Only call if we have no data yet
    final viewModel = context.read<HomeViewModel>();
    if (viewModel.featuredCharacters.isEmpty) {
      viewModel.loadInitialFeaturedCharacters();
    }
  }

  void _onScroll() {
    if (_scrollController.position.pixels >=
        _scrollController.position.maxScrollExtent * 0.8) {
      // Use a debounce or throttle mechanism to avoid repeated calls
      final viewModel = context.read<HomeViewModel>();
      if (!viewModel.isLoadingFeatured && viewModel.hasMoreFeatured) {
        viewModel.loadMoreFeaturedCharacters();
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Column(
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
          child: Consumer<HomeViewModel>(
            builder: (context, viewModel, child) {
              return Column(
                children: [
                  Expanded(
                    child: ListView.builder(
                      controller: _scrollController,
                      scrollDirection: Axis.horizontal,
                      itemCount: viewModel.featuredCharacters.length +
                          (viewModel.hasMoreFeatured ? 1 : 0),
                      itemBuilder: (context, index) {
                        if (index >= viewModel.featuredCharacters.length) {
                          return const SizedBox(
                            width: 160,
                            child: Center(
                              child: Padding(
                                padding: EdgeInsets.all(8.0),
                                child: CircularProgressIndicator(),
                              ),
                            ),
                          );
                        }

                        var currentCharacter =
                            viewModel.featuredCharacters[index];
                        return SizedBox(
                          width: 160,
                          child: StreamBuilder<bool>(
                            stream:
                                viewModel.watchCharIsFav(currentCharacter.name),
                            builder: (context, snapshot) {
                              return CharacterCard(
                                character: currentCharacter,
                                isFeatured: true,
                                isFavorite: snapshot.data ?? false,
                                onFavoritePressed: () => viewModel
                                    .toggleFavCharacter(currentCharacter),
                              );
                            },
                          ),
                        );
                      },
                    ),
                  ),
                 
                ],
              );
            },
          ),
        ),
      ],
    );
  }
}
