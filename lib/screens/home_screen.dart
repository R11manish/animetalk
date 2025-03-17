import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../viewmodels/home_viewmodel.dart';
import '../widgets/featured_characters_section.dart';
import '../widgets/all_characters_section.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  @override
  void initState() {
    super.initState();
    // Load data when the screen initializes if not already loaded
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final viewModel = Provider.of<HomeViewModel>(context, listen: false);
      viewModel.loadInitialCharacters();
      viewModel.loadInitialFeaturedCharacters();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'AnimeTalk',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        // actions: [
        //   IconButton(
        //     icon: const Icon(Icons.settings),
        //     onPressed: () {
        //       // Add settings functionality
        //     },
        //   ),
        // ],
      ),
      body: RefreshIndicator(
        onRefresh: () async {
          try {
            final viewModel = context.read<HomeViewModel>();
            // Force refresh data when user pulls to refresh
            await viewModel.forceRefresh();
          } catch (e) {
            // Handle any errors during refresh
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text('Error refreshing: ${e.toString()}')),
            );
          }
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
    );
  }
}
