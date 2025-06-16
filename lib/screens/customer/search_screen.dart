// screens/customer/search_screen.dart
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../services/firestore_service.dart';
import '../../models/artwork_model.dart';
import '../../widgets/bottom_nav_bar.dart';
import 'customer_home_screen.dart';

class SearchScreen extends StatefulWidget {
  const SearchScreen({super.key});

  @override
  State<SearchScreen> createState() => _SearchScreenState();
}

class _SearchScreenState extends State<SearchScreen> {
  String? _selectedArtType;
  RangeValues _priceRange = const RangeValues(0, 1000);
  List<ArtworkModel> _searchResults = [];
  bool _isLoading = false;

  final List<String> _artTypes = [
    'Painting',
    'Pottery',
    'Sculpture',
    'Digital Art',
    'Photography',
    'Drawing',
    'Mixed Media',
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Search Art'),
        backgroundColor: Colors.deepPurple,
        foregroundColor: Colors.white,
      ),
      body: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Art Type',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 8),
                Wrap(
                  spacing: 8,
                  children: _artTypes.map((type) {
                    return FilterChip(
                      label: Text(type),
                      selected: _selectedArtType == type,
                      onSelected: (selected) {
                        setState(() {
                          _selectedArtType = selected ? type : null;
                        });
                      },
                    );
                  }).toList(),
                ),
                const SizedBox(height: 16),
                const Text(
                  'Price Range',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                ),
                RangeSlider(
                  values: _priceRange,
                  min: 0,
                  max: 5000,
                  divisions: 50,
                  labels: RangeLabels(
                    '\$${_priceRange.start.round()}',
                    '\$${_priceRange.end.round()}',
                  ),
                  onChanged: (values) {
                    setState(() {
                      _priceRange = values;
                    });
                  },
                ),
                const SizedBox(height: 16),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: _searchArtworks,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.deepPurple,
                      foregroundColor: Colors.white,
                    ),
                    child: const Text('Search'),
                  ),
                ),
              ],
            ),
          ),
          Expanded(
            child: _isLoading
                ? const Center(child: CircularProgressIndicator())
                : _searchResults.isEmpty
                    ? const Center(child: Text('No results found'))
                    : GridView.builder(
                        padding: const EdgeInsets.all(16),
                        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                          crossAxisCount: 2,
                          crossAxisSpacing: 16,
                          mainAxisSpacing: 16,
                          childAspectRatio: 0.8,
                        ),
                        itemCount: _searchResults.length,
                        itemBuilder: (context, index) {
                          return ArtworkCard(artwork: _searchResults[index]);
                        },
                      ),
          ),
        ],
      ),
      bottomNavigationBar: const CustomerBottomNavBar(currentIndex: 1),
    );
  }

  Future<void> _searchArtworks() async {
    setState(() => _isLoading = true);

    final firestoreService = Provider.of<FirestoreService>(context, listen: false);
    final results = await firestoreService.searchArtworks(
      artType: _selectedArtType,
      minPrice: _priceRange.start,
      maxPrice: _priceRange.end,
    );

    setState(() {
      _searchResults = results;
      _isLoading = false;
    });
  }
}
