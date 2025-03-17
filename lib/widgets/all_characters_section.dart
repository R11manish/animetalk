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
  final ScrollController _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
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

  void _scrollToTop() {
    _scrollController.animateTo(
      0,
      duration: const Duration(milliseconds: 500),
      curve: Curves.easeInOut,
    );
  }

  void _loadInitial() {
    final viewModel = context.read<HomeViewModel>();
    if (viewModel.allCharacters.isEmpty) {
      viewModel.loadInitialCharacters();
    }
  }

  bool _handleScrollNotification(ScrollNotification notification) {
    if (notification is ScrollUpdateNotification) {
      final metrics = notification.metrics;
      if (metrics.pixels >= metrics.maxScrollExtent * 0.8) {
        final viewModel = context.read<HomeViewModel>();
        if (!viewModel.isLoading && viewModel.hasMore) {
          viewModel.loadMoreCharacters();
        }
      }
    }
    return false;
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.all(16.0),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'All Characters',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),
              IconButton(
                icon: const Icon(Icons.arrow_upward),
                onPressed: _scrollToTop,
                tooltip: 'Back to top',
              ),
            ],
          ),
        ),
        LayoutBuilder(
          builder: (context, constraints) {
            final availableHeight = MediaQuery.of(context).size.height - 200;

            return SizedBox(
              height: availableHeight,
              child: Consumer<HomeViewModel>(
                builder: (context, viewModel, child) {
                  return NotificationListener<ScrollNotification>(
                    onNotification: _handleScrollNotification,
                    child: GridView.builder(
                      controller: _scrollController,
                      physics: const ClampingScrollPhysics(),
                      padding: const EdgeInsets.all(8.0),
                      gridDelegate:
                          const SliverGridDelegateWithFixedCrossAxisCount(
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
                          stream:
                              viewModel.watchCharIsFav(currentCharacter.name),
                          builder: (context, snapshot) {
                            return CharacterCard(
                              character: currentCharacter,
                              isFavorite: snapshot.data ?? false,
                              onFavoritePressed: () => viewModel
                                  .toggleFavCharacter(currentCharacter),
                            );
                          },
                        );
                      },
                    ),
                  );
                },
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
