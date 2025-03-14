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
    _loadInitial();
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  void _loadInitial() {
    context.read<HomeViewModel>().loadInitialFeaturedCharacters();
  }

  void _onScroll() {
    if (_scrollController.position.pixels >=
        _scrollController.position.maxScrollExtent * 0.8) {
      context.read<HomeViewModel>().loadMoreFeaturedCharacters();
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

                        return SizedBox(
                          width: 160,
                          child: CharacterCard(
                            character: viewModel.featuredCharacters[index],
                            isFeatured: true,
                          ),
                        );
                      },
                    ),
                  ),
                  if (viewModel.isLoadingFeatured &&
                      viewModel.featuredCharacters.isNotEmpty)
                    const Padding(
                      padding: EdgeInsets.all(8.0),
                      child: Center(child: CircularProgressIndicator()),
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
