import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../viewmodels/home_viewmodel.dart';
import '../widgets/featured_characters_section.dart';
import '../widgets/all_characters_section.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => HomeViewModel(),
      child: Scaffold(
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
            final viewModel = context.read<HomeViewModel>();
            await Future.wait([
              viewModel.loadInitialCharacters(),
              viewModel.loadInitialFeaturedCharacters(),
            ]);
          },
          child: const SingleChildScrollView(
            physics: AlwaysScrollableScrollPhysics(),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                FeaturedCharactersSection(),
                AllCharactersSection(),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
