import 'package:flutter/material.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import 'package:provider/provider.dart';
import '../services/ad_service.dart';
import '../viewmodels/home_viewmodel.dart';
import '../widgets/featured_characters_section.dart';
import '../widgets/all_characters_section.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final ScrollController _scrollController = ScrollController();
  NativeAd? _nativeAd;
  bool _isAdLoaded = false;

  @override
  void initState() {
    super.initState();
    _loadNativeAd();

    WidgetsBinding.instance.addPostFrameCallback((_) {
      final viewModel = Provider.of<HomeViewModel>(context, listen: false);
      viewModel.loadInitialCharacters();
      viewModel.loadInitialFeaturedCharacters();
    });
  }

  void _loadNativeAd() {
    _nativeAd = AdService.createNativeAd(
      onAdLoaded: (Ad ad) {
        setState(() {
          _isAdLoaded = true;
        });
      },
      onAdFailedToLoad: (Ad ad, LoadAdError error) {
        ad.dispose();
        print('Native ad failed to load: $error');
      },
    );

    _nativeAd?.load();
  }

  @override
  void dispose() {
    _nativeAd?.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'AnimeTalk',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
      ),
      body: RefreshIndicator(
        onRefresh: () async {
          try {
            final viewModel = context.read<HomeViewModel>();
            await viewModel.forceRefresh();
          } catch (e) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text('Error refreshing: ${e.toString()}')),
            );
          }
        },
        child: SingleChildScrollView(
          controller: _scrollController,
          physics: AlwaysScrollableScrollPhysics(),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const FeaturedCharactersSection(),
              if (_isAdLoaded)
                Container(
                  padding: const EdgeInsets.symmetric(vertical: 10),
                  height: 300, // Adjust this based on your ad size
                  child: AdWidget(ad: _nativeAd!),
                ),
              AllCharactersSection(
                parentScrollController: _scrollController,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
