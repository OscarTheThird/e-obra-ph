// screens/customer/search_screen.dart
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:cached_network_image/cached_network_image.dart';
import '../../services/firestore_service.dart';
import '../../models/artwork_model.dart';
import '../../models/user_model.dart';
import '../../widgets/bottom_nav_bar.dart';
import '../../services/cloudinary_service.dart';

class SearchScreen extends StatefulWidget {
  const SearchScreen({super.key});

  @override
  State<SearchScreen> createState() => _SearchScreenState();
}

class _SearchScreenState extends State<SearchScreen> with TickerProviderStateMixin {
  String? _selectedArtType;
  final TextEditingController _minPriceController = TextEditingController();
  final TextEditingController _maxPriceController = TextEditingController();
  List<ArtworkModel> _searchResults = [];
  bool _isLoading = false;
  String? _priceError;
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;

  // Custom Color Palette
  static const Color primaryOrange = Color(0xFFE8541D);
  static const Color primaryGreen = Color(0xFF00BF63);
  static const Color primaryPurple = Color(0xFF5E17EB);
  static const Color backgroundWhite = Colors.white;
  static const Color lightGray = Color(0xFFF8F9FA);
  static const Color mediumGray = Color(0xFFE9ECEF);
  static const Color darkGray = Color(0xFF6C757D);

  final List<String> _artTypes = [
    'Painting',
    'Backdrop painting',
    'Sculpture',
    'Digital Art',
    'Photography',
    'Drawing',
    'Mixed Media',
    'Jewelry',
    'Textile Art',
    'Glass Art',
  ];

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );
    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeInOut),
    );
    _animationController.forward();
  }

  @override
  void dispose() {
    _animationController.dispose();
    _minPriceController.dispose();
    _maxPriceController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: lightGray,
      body: CustomScrollView(
        physics: const BouncingScrollPhysics(),
        slivers: [
          _buildModernAppBar(),
          SliverToBoxAdapter(
            child: FadeTransition(
              opacity: _fadeAnimation,
              child: _buildSearchFilters(),
            ),
          ),
          _buildSearchResults(),
        ],
      ),
      bottomNavigationBar: const CustomerBottomNavBar(currentIndex: 1),
    );
  }

  Widget _buildModernAppBar() {
    return SliverAppBar(
      expandedHeight: 120,
      floating: true,
      pinned: true,
      elevation: 0,
      backgroundColor: backgroundWhite,
      surfaceTintColor: Colors.transparent,
      flexibleSpace: FlexibleSpaceBar(
        titlePadding: const EdgeInsets.only(left: 20, bottom: 16),
        title: const Text(
          'Search Art',
          style: TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 28,
            color: Colors.black87,
          ),
        ),
        background: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                backgroundWhite,
                primaryOrange.withOpacity(0.05),
              ],
            ),
          ),
        ),
      ),
      actions: [
        Container(
          margin: const EdgeInsets.only(right: 16, top: 8),
          child: IconButton(
            icon: Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: primaryPurple.withOpacity(0.1),
                borderRadius: BorderRadius.circular(12),
              ),
              child: const Icon(Icons.filter_alt, color: primaryPurple),
            ),
            onPressed: () {
              _showAdvancedFilters();
            },
          ),
        ),
      ],
    );
  }

  Widget _buildSearchFilters() {
    return Container(
      margin: const EdgeInsets.all(20),
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: backgroundWhite,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.08),
            blurRadius: 20,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: primaryOrange.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(Icons.search, color: primaryOrange, size: 20),
              ),
              const SizedBox(width: 12),
              const Text(
                'Find Your Perfect Artwork',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Colors.black87,
                ),
              ),
            ],
          ),
          const SizedBox(height: 24),

          // Art Type Section
          const Text(
            'Art Type',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w600,
              color: Colors.black87,
            ),
          ),
          const SizedBox(height: 12),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: _artTypes.map((type) {
              final isSelected = _selectedArtType == type;
              return GestureDetector(
                onTap: () {
                  setState(() {
                    _selectedArtType = isSelected ? null : type;
                  });
                },
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  decoration: BoxDecoration(
                    gradient: isSelected
                        ? LinearGradient(
                            colors: [primaryGreen, primaryGreen.withOpacity(0.8)],
                          )
                        : null,
                    color: isSelected ? null : lightGray,
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(
                      color: isSelected ? Colors.transparent : mediumGray,
                      width: 1,
                    ),
                    boxShadow: isSelected ? [
                      BoxShadow(
                        color: primaryGreen.withOpacity(0.3),
                        blurRadius: 8,
                        offset: const Offset(0, 2),
                      ),
                    ] : [],
                  ),
                  child: Text(
                    type,
                    style: TextStyle(
                      color: isSelected ? backgroundWhite : darkGray,
                      fontWeight: isSelected ? FontWeight.w600 : FontWeight.w500,
                      fontSize: 12,
                    ),
                  ),
                ),
              );
            }).toList(),
          ),

          const SizedBox(height: 24),

          // Price Range Section
          const Text(
            'Price Range',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w600,
              color: Colors.black87,
            ),
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: _buildPriceTextField(
                  controller: _minPriceController,
                  label: 'Min Price',
                  hint: '0',
                  icon: Icons.trending_down,
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: _buildPriceTextField(
                  controller: _maxPriceController,
                  label: 'Max Price',
                  hint: '50000',
                  icon: Icons.trending_up,
                ),
              ),
            ],
          ),

          if (_priceError != null) ...[
            const SizedBox(height: 12),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.red.withOpacity(0.1),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: Colors.red.withOpacity(0.3)),
              ),
              child: Row(
                children: [
                  Icon(Icons.error, color: Colors.red, size: 16),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      _priceError!,
                      style: const TextStyle(
                        color: Colors.red,
                        fontSize: 12,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],

          const SizedBox(height: 24),

          // Search Button
          SizedBox(
            width: double.infinity,
            height: 50,
            child: Container(
              decoration: BoxDecoration(
                gradient: _priceError == null
                    ? LinearGradient(
                        colors: [primaryOrange, primaryPurple],
                      )
                    : null,
                color: _priceError != null ? mediumGray : null,
                borderRadius: BorderRadius.circular(16),
                boxShadow: _priceError == null ? [
                  BoxShadow(
                    color: primaryOrange.withOpacity(0.3),
                    blurRadius: 12,
                    offset: const Offset(0, 4),
                  ),
                ] : [],
              ),
              child: ElevatedButton.icon(
                onPressed: _priceError == null ? _searchArtworks : null,
                icon: _isLoading
                    ? SizedBox(
                        width: 20,
                        height: 20,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          valueColor: AlwaysStoppedAnimation<Color>(backgroundWhite),
                        ),
                      )
                    : const Icon(Icons.search, color: Colors.white),
                label: Text(
                  _isLoading ? 'Searching...' : 'Search Artworks',
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.transparent,
                  shadowColor: Colors.transparent,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPriceTextField({
    required TextEditingController controller,
    required String label,
    required String hint,
    required IconData icon,
  }) {
    return TextFormField(
      controller: controller,
      keyboardType: TextInputType.number,
      onChanged: (_) => _validatePrices(),
      style: const TextStyle(
        fontSize: 14,
        fontWeight: FontWeight.w500,
      ),
      decoration: InputDecoration(
        labelText: label,
        hintText: hint,
        prefixText: '₱ ',
        prefixIcon: Container(
          margin: const EdgeInsets.all(12),
          padding: const EdgeInsets.all(6),
          decoration: BoxDecoration(
            color: primaryPurple.withOpacity(0.1),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Icon(icon, color: primaryPurple, size: 16),
        ),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: mediumGray),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: mediumGray),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: primaryPurple, width: 2),
        ),
        filled: true,
        fillColor: lightGray,
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      ),
    );
  }

  Widget _buildSearchResults() {
    if (_isLoading) {
      return SliverToBoxAdapter(
        child: _buildLoadingGrid(),
      );
    }

    if (_searchResults.isEmpty) {
      return SliverToBoxAdapter(
        child: _buildEmptyState(),
      );
    }

    return SliverPadding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      sliver: SliverGrid(
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 2,
          crossAxisSpacing: 16,
          mainAxisSpacing: 16,
          childAspectRatio: 0.75,
        ),
        delegate: SliverChildBuilderDelegate(
          (context, index) {
            final artwork = _searchResults[index];
            return _buildModernArtworkCard(artwork, index);
          },
          childCount: _searchResults.length,
        ),
      ),
    );
  }

  Widget _buildLoadingGrid() {
    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      padding: const EdgeInsets.all(20),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        crossAxisSpacing: 16,
        mainAxisSpacing: 16,
        childAspectRatio: 0.75,
      ),
      itemCount: 6,
      itemBuilder: (context, index) {
        return Container(
          decoration: BoxDecoration(
            color: backgroundWhite,
            borderRadius: BorderRadius.circular(20),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.05),
                blurRadius: 10,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Column(
            children: [
              Expanded(
                flex: 3,
                child: Container(
                  decoration: BoxDecoration(
                    color: mediumGray,
                    borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
                  ),
                  child: Center(
                    child: CircularProgressIndicator(
                      valueColor: AlwaysStoppedAnimation<Color>(primaryPurple),
                      strokeWidth: 2,
                    ),
                  ),
                ),
              ),
              Expanded(
                flex: 2,
                child: Padding(
                  padding: const EdgeInsets.all(12),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Container(
                        height: 12,
                        width: double.infinity,
                        decoration: BoxDecoration(
                          color: mediumGray,
                          borderRadius: BorderRadius.circular(6),
                        ),
                      ),
                      const SizedBox(height: 8),
                      Container(
                        height: 8,
                        width: 80,
                        decoration: BoxDecoration(
                          color: mediumGray,
                          borderRadius: BorderRadius.circular(4),
                        ),
                      ),
                      const Spacer(),
                      Container(
                        height: 12,
                        width: 60,
                        decoration: BoxDecoration(
                          color: mediumGray,
                          borderRadius: BorderRadius.circular(6),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildEmptyState() {
    return Container(
      padding: const EdgeInsets.all(40),
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              color: primaryGreen.withOpacity(0.1),
              shape: BoxShape.circle,
            ),
            child: Icon(Icons.search_off, size: 48, color: primaryGreen),
          ),
          const SizedBox(height: 24),
          const Text(
            'No Artworks Found',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: Colors.black87,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Try adjusting your filters or search for different artwork types.',
            style: TextStyle(
              fontSize: 14,
              color: darkGray,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 20),
          ElevatedButton.icon(
            onPressed: () {
              setState(() {
                _selectedArtType = null;
                _minPriceController.clear();
                _maxPriceController.clear();
                _searchResults.clear();
                _priceError = null;
              });
            },
            icon: const Icon(Icons.refresh),
            label: const Text('Clear Filters'),
            style: ElevatedButton.styleFrom(
              backgroundColor: primaryPurple,
              foregroundColor: backgroundWhite,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildModernArtworkCard(ArtworkModel artwork, int index) {
    return GestureDetector(
      onTap: () => _viewArtworkDetails(context, artwork),
      child: Hero(
        tag: 'search_artwork_${artwork.id}_$index',
        child: Container(
          decoration: BoxDecoration(
            color: backgroundWhite,
            borderRadius: BorderRadius.circular(20),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.08),
                blurRadius: 15,
                offset: const Offset(0, 5),
              ),
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                flex: 3,
                child: Stack(
                  children: [
                    ClipRRect(
                      borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
                      child: artwork.images.isNotEmpty
                          ? _buildOptimizedThumbnail(
                              artwork.images.first,
                              width: double.infinity,
                              height: double.infinity,
                            )
                          : Container(
                              width: double.infinity,
                              height: double.infinity,
                              color: mediumGray,
                              child: Icon(Icons.image, size: 50, color: darkGray),
                            ),
                    ),
                    
                    // Availability Badge
                    Positioned(
                      top: 12,
                      right: 12,
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                        decoration: BoxDecoration(
                          color: artwork.availability ? primaryGreen : Colors.red,
                          borderRadius: BorderRadius.circular(12),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withOpacity(0.2),
                              blurRadius: 4,
                              offset: const Offset(0, 2),
                            ),
                          ],
                        ),
                        child: Text(
                          artwork.availability ? 'Available' : 'Sold',
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 10,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              
              Expanded(
                flex: 2,
                child: Padding(
                  padding: const EdgeInsets.all(12),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        artwork.title,
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 14,
                          color: Colors.black87,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 4),
                      Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                            decoration: BoxDecoration(
                              color: primaryPurple.withOpacity(0.1),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Text(
                              artwork.artStyle,
                              style: TextStyle(
                                color: primaryPurple,
                                fontSize: 10,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ),
                        ],
                      ),
                      const Spacer(),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            '₱${artwork.price.toStringAsFixed(2)}',
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              color: primaryOrange,
                              fontSize: 16,
                            ),
                          ),
                          Container(
                            padding: const EdgeInsets.all(4),
                            decoration: BoxDecoration(
                              color: primaryGreen.withOpacity(0.1),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Icon(
                              Icons.favorite_border,
                              size: 16,
                              color: primaryGreen,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _showAdvancedFilters() {
    // TODO: Implement advanced filters dialog
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            Icon(Icons.filter_alt, color: Colors.white),
            const SizedBox(width: 12),
            const Text(
              'Advanced filters coming soon!',
              style: TextStyle(fontWeight: FontWeight.w500),
            ),
          ],
        ),
        backgroundColor: primaryPurple,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
        margin: const EdgeInsets.all(16),
      ),
    );
  }

  void _viewArtworkDetails(BuildContext context, ArtworkModel artwork) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => DraggableScrollableSheet(
        initialChildSize: 0.92,
        minChildSize: 0.6,
        maxChildSize: 0.97,
        builder: (context, scrollController) => Container(
          decoration: BoxDecoration(
            color: backgroundWhite,
            borderRadius: const BorderRadius.vertical(top: Radius.circular(28)),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.1),
                blurRadius: 20,
                offset: const Offset(0, -8),
              ),
            ],
          ),
          child: Column(
            children: [
              Container(
                margin: const EdgeInsets.symmetric(vertical: 12),
                width: 50,
                height: 4,
                decoration: BoxDecoration(
                  color: mediumGray,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              Expanded(
                child: SingleChildScrollView(
                  controller: scrollController,
                  padding: const EdgeInsets.all(20),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Image Gallery
                      if (artwork.images.isNotEmpty) ...[
                        Container(
                          height: 300,
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(20),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withOpacity(0.1),
                                blurRadius: 20,
                                offset: const Offset(0, 10),
                              ),
                            ],
                          ),
                          child: PageView.builder(
                            itemCount: artwork.images.length,
                            itemBuilder: (context, index) => ClipRRect(
                              borderRadius: BorderRadius.circular(20),
                              child: _buildOptimizedDisplayImage(
                                artwork.images[index],
                                height: 300,
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(height: 24),
                      ],

                      // Artwork Title and Price
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Expanded(
                            child: Text(
                              artwork.title,
                              style: const TextStyle(
                                fontSize: 28,
                                fontWeight: FontWeight.bold,
                                color: Colors.black87,
                              ),
                            ),
                          ),
                          const SizedBox(width: 16),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                            decoration: BoxDecoration(
                              gradient: LinearGradient(
                                colors: [primaryOrange, primaryOrange.withOpacity(0.8)],
                              ),
                              borderRadius: BorderRadius.circular(20),
                              boxShadow: [
                                BoxShadow(
                                  color: primaryOrange.withOpacity(0.3),
                                  blurRadius: 8,
                                  offset: const Offset(0, 4),
                                ),
                              ],
                            ),
                            child: Text(
                              '₱${artwork.price.toStringAsFixed(2)}',
                              style: const TextStyle(
                                fontSize: 20,
                                fontWeight: FontWeight.bold,
                                color: Colors.white,
                              ),
                            ),
                          ),
                        ],
                      ),

                      const SizedBox(height: 16),

                      // Tags
                      Wrap(
                        spacing: 8,
                        runSpacing: 8,
                        children: [
                          _buildInfoChip(artwork.artStyle, primaryPurple),
                          _buildInfoChip(artwork.artType, primaryGreen),
                          _buildInfoChip(
                            artwork.availability ? 'Available' : 'Sold',
                            artwork.availability ? primaryGreen : Colors.red,
                          ),
                        ],
                      ),

                      const SizedBox(height: 24),

                      // Description
                      if (artwork.description.isNotEmpty) ...[
                        const Text(
                          'Description',
                          style: TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                            color: Colors.black87,
                          ),
                        ),
                        const SizedBox(height: 12),
                        Container(
                          padding: const EdgeInsets.all(16),
                          decoration: BoxDecoration(
                            color: lightGray,
                            borderRadius: BorderRadius.circular(16),
                          ),
                          child: Text(
                            artwork.description,
                            style: const TextStyle(
                              fontSize: 16,
                              color: Colors.black87,
                              height: 1.5,
                            ),
                          ),
                        ),
                        const SizedBox(height: 20),
                      ],

                      // Artwork Details
                      const Text(
                        'Artwork Details',
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                          color: Colors.black87,
                        ),
                      ),
                      const SizedBox(height: 16),

                      if (artwork.medium.isNotEmpty)
                        _buildDetailRow(Icons.brush, 'Medium', artwork.medium),
                      if (artwork.dimensions.isNotEmpty)
                        _buildDetailRow(Icons.straighten, 'Dimensions', artwork.dimensions),
                      _buildDetailRow(
                        Icons.calendar_today,
                        'Created',
                        artwork.createdAt.toDate().toString().split(' ')[0],
                      ),

                      const SizedBox(height: 32),

                      // Action Button
                      SizedBox(
                        width: double.infinity,
                        height: 56,
                        child: Container(
                          decoration: BoxDecoration(
                            gradient: LinearGradient(
                              colors: [primaryPurple, primaryGreen],
                            ),
                            borderRadius: BorderRadius.circular(16),
                            boxShadow: [
                              BoxShadow(
                                color: primaryPurple.withOpacity(0.3),
                                blurRadius: 12,
                                offset: const Offset(0, 6),
                              ),
                            ],
                          ),
                          child: ElevatedButton.icon(
                            onPressed: () {
                              Navigator.pop(context);
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(
                                  content: Row(
                                    children: [
                                      Icon(Icons.message, color: Colors.white),
                                      const SizedBox(width: 12),
                                      const Text(
                                        'Message artist feature coming soon!',
                                        style: TextStyle(fontWeight: FontWeight.w500),
                                      ),
                                    ],
                                  ),
                                  backgroundColor: primaryGreen,
                                  behavior: SnackBarBehavior.floating,
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                  margin: const EdgeInsets.all(16),
                                ),
                              );
                            },
                            icon: const Icon(Icons.message, color: Colors.white),
                            label: const Text(
                              'Message Artist',
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                                color: Colors.white,
                              ),
                            ),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.transparent,
                              shadowColor: Colors.transparent,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(16),
                              ),
                            ),
                          ),
                        ),
                      ),

                      const SizedBox(height: 20),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildInfoChip(String label, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: color.withOpacity(0.3)),
      ),
      child: Text(
        label,
        style: TextStyle(
          color: color,
          fontSize: 12,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }

  Widget _buildDetailRow(IconData icon, String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: primaryPurple.withOpacity(0.1),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(icon, color: primaryPurple, size: 16),
          ),
          const SizedBox(width: 12),
          Text(
            '$label: ',
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w600,
              color: darkGray,
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: const TextStyle(
                fontSize: 14,
                color: Colors.black87,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildOptimizedThumbnail(String imageUrl, {double? width, double? height}) {
    final publicId = CloudinaryUtils.extractPublicId(imageUrl);
    if (publicId == null) {
      return Container(
        width: width,
        height: height,
        color: mediumGray,
        child: Icon(Icons.error, size: 50, color: darkGray),
      );
    }
    final thumbnailUrl = CloudinaryService.getThumbnailUrl(publicId, size: 320);
    return CachedNetworkImage(
      imageUrl: thumbnailUrl,
      fit: BoxFit.cover,
      width: width,
      height: height,
      placeholder: (context, url) => Container(
        width: width,
        height: height,
        color: lightGray,
        child: Center(
          child: SizedBox(
            width: 24,
            height: 24,
            child: CircularProgressIndicator(
              strokeWidth: 2,
              valueColor: AlwaysStoppedAnimation<Color>(primaryPurple),
            ),
          ),
        ),
      ),
      errorWidget: (context, url, error) => Container(
        width: width,
        height: height,
        color: mediumGray,
        child: Icon(Icons.error, size: 38, color: darkGray),
      ),
      memCacheWidth: 320,
      memCacheHeight: 320,
      fadeInDuration: const Duration(milliseconds: 300),
    );
  }

  Widget _buildOptimizedDisplayImage(String imageUrl, {double? height}) {
    final publicId = CloudinaryUtils.extractPublicId(imageUrl);
    if (publicId == null) {
      return Container(
        height: height ?? 320,
        color: mediumGray,
        child: Icon(Icons.error, size: 50, color: darkGray),
      );
    }
    final displayUrl = CloudinaryService.getArtworkDisplayUrl(publicId, maxWidth: 900);
    return CachedNetworkImage(
      imageUrl: displayUrl,
      fit: BoxFit.cover,
      height: height,
      placeholder: (context, url) => Container(
        height: height ?? 320,
        color: lightGray,
        child: Center(
          child: CircularProgressIndicator(
            valueColor: AlwaysStoppedAnimation<Color>(primaryPurple),
          ),
        ),
      ),
      errorWidget: (context, url, error) => Container(
        height: height ?? 320,
        color: mediumGray,
        child: Icon(Icons.error, size: 50, color: darkGray),
      ),
      fadeInDuration: const Duration(milliseconds: 300),
    );
  }

  void _validatePrices() {
    setState(() {
      _priceError = null;
      
      final minText = _minPriceController.text.trim();
      final maxText = _maxPriceController.text.trim();
      
      // Check if inputs contain non-numeric characters
      if (minText.isNotEmpty && !_isNumeric(minText)) {
        _priceError = 'Minimum price must be a valid number';
        return;
      }
      
      if (maxText.isNotEmpty && !_isNumeric(maxText)) {
        _priceError = 'Maximum price must be a valid number';
        return;
      }
      
      // Parse values if they're numeric
      if (minText.isNotEmpty && maxText.isNotEmpty) {
        final minPrice = int.tryParse(minText);
        final maxPrice = int.tryParse(maxText);
        
        if (minPrice != null && maxPrice != null) {
          if (minPrice < 0) {
            _priceError = 'Minimum price cannot be negative';
            return;
          }
          
          if (maxPrice < 0) {
            _priceError = 'Maximum price cannot be negative';
            return;
          }
          
          if (minPrice > maxPrice) {
            _priceError = 'Minimum price cannot be greater than maximum price';
            return;
          }
        }
      }
    });
  }

  bool _isNumeric(String str) {
    return int.tryParse(str) != null;
  }

  Future<void> _searchArtworks() async {
  setState(() => _isLoading = true);

    try {
      final minPrice = _minPriceController.text.trim().isEmpty 
          ? null 
          : double.tryParse(_minPriceController.text.trim());
      
      final maxPrice = _maxPriceController.text.trim().isEmpty 
          ? null 
          : double.tryParse(_maxPriceController.text.trim());

      final firestoreService = Provider.of<FirestoreService>(context, listen: false);
      final results = await firestoreService.searchArtworks(
        artType: _selectedArtType,
        minPrice: minPrice,
        maxPrice: maxPrice,
      );

      setState(() {
        _searchResults = results;
        _isLoading = false;
      });

      if (results.isNotEmpty) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Row(
              children: [
                Icon(Icons.check_circle, color: Colors.white),
                const SizedBox(width: 12),
                Text(
                  'Found ${results.length} artwork${results.length == 1 ? '' : 's'}',
                  style: const TextStyle(fontWeight: FontWeight.w500),
                ),
              ],
            ),
            backgroundColor: primaryGreen,
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
            margin: const EdgeInsets.all(16),
          ),
        );
      }
    } catch (e) {
      setState(() => _isLoading = false);
      
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Row(
            children: [
              Icon(Icons.error, color: Colors.white),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  'Error searching artworks: ${e.toString()}',
                  style: const TextStyle(fontWeight: FontWeight.w500),
                ),
              ),
            ],
          ),
          backgroundColor: Colors.red,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          margin: const EdgeInsets.all(16),
        ),
      );
    }
  }
}