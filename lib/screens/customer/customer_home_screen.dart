import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:cached_network_image/cached_network_image.dart';
import '../../services/firestore_service.dart';
import '../../models/artwork_model.dart';
import '../../models/user_model.dart';
import '../../widgets/bottom_nav_bar.dart';
import '../../services/cloudinary_service.dart';

class CustomerHomeScreen extends StatefulWidget {
  const CustomerHomeScreen({super.key});

  @override
  State<CustomerHomeScreen> createState() => _CustomerHomeScreenState();
}

class _CustomerHomeScreenState extends State<CustomerHomeScreen> with TickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;
  String _selectedCategory = 'All';
  
  // Custom Color Palette
  static const Color primaryOrange = Color(0xFFE8541D);
  static const Color primaryGreen = Color(0xFF00BF63);
  static const Color primaryPurple = Color(0xFF5E17EB);
  static const Color backgroundWhite = Colors.white;
  static const Color lightGray = Color(0xFFF8F9FA);
  static const Color mediumGray = Color(0xFFE9ECEF);
  static const Color darkGray = Color(0xFF6C757D);

  final List<String> categories = [
    'All', 'Painting', 'Digital Art', 'Photography', 'Sculpture', 'Drawing'
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
              child: Column(
                children: [
                  _buildHeaderSection(),
                  _buildCategoryFilter(),
                  const SizedBox(height: 20),
                ],
              ),
            ),
          ),
          _buildArtworkGrid(),
        ],
      ),
      bottomNavigationBar: const CustomerBottomNavBar(currentIndex: 0),
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
          'Discover Art',
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
                primaryPurple.withOpacity(0.05),
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
                color: primaryOrange.withOpacity(0.1),
                borderRadius: BorderRadius.circular(12),
              ),
              child: const Icon(Icons.search, color: primaryOrange),
            ),
            onPressed: () {
              // TODO: Implement search
            },
          ),
        ),
      ],
    );
  }

  Widget _buildHeaderSection() {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            primaryGreen.withOpacity(0.1),
            primaryPurple.withOpacity(0.05),
          ],
        ),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: primaryGreen.withOpacity(0.2)),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: backgroundWhite,
              borderRadius: BorderRadius.circular(16),
              boxShadow: [
                BoxShadow(
                  color: primaryGreen.withOpacity(0.2),
                  blurRadius: 8,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: Icon(Icons.palette, color: primaryGreen, size: 24),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Explore Amazing Artwork',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: Colors.black87,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  'Discover unique pieces from talented artists',
                  style: TextStyle(
                    fontSize: 12,
                    color: darkGray,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCategoryFilter() {
    return Container(
      height: 50,
      margin: const EdgeInsets.symmetric(horizontal: 20),
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        physics: const BouncingScrollPhysics(),
        itemCount: categories.length,
        itemBuilder: (context, index) {
          final category = categories[index];
          final isSelected = _selectedCategory == category;
          
          return GestureDetector(
            onTap: () {
              setState(() {
                _selectedCategory = category;
              });
            },
            child: Container(
              margin: const EdgeInsets.only(right: 12),
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
              decoration: BoxDecoration(
                gradient: isSelected 
                    ? LinearGradient(
                        colors: [primaryOrange, primaryPurple],
                      )
                    : null,
                color: isSelected ? null : backgroundWhite,
                borderRadius: BorderRadius.circular(25),
                border: Border.all(
                  color: isSelected ? Colors.transparent : mediumGray,
                  width: 1,
                ),
                boxShadow: isSelected ? [
                  BoxShadow(
                    color: primaryOrange.withOpacity(0.3),
                    blurRadius: 8,
                    offset: const Offset(0, 2),
                  ),
                ] : [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.05),
                    blurRadius: 4,
                    offset: const Offset(0, 1),
                  ),
                ],
              ),
              child: Text(
                category,
                style: TextStyle(
                  color: isSelected ? backgroundWhite : darkGray,
                  fontWeight: isSelected ? FontWeight.w600 : FontWeight.w500,
                  fontSize: 14,
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildArtworkGrid() {
    return SliverPadding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      sliver: StreamBuilder<List<ArtworkModel>>(
        stream: Provider.of<FirestoreService>(context).getArtworks(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return SliverToBoxAdapter(
              child: _buildLoadingGrid(),
            );
          }

          if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return SliverToBoxAdapter(
              child: _buildEmptyState(),
            );
          }

          final artworks = snapshot.data!;
          final filteredArtworks = _selectedCategory == 'All'
              ? artworks
              : artworks.where((artwork) => artwork.artType == _selectedCategory).toList();

          if (filteredArtworks.isEmpty) {
            return SliverToBoxAdapter(
              child: _buildEmptyCategory(),
            );
          }

          return SliverGrid(
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 2,
              crossAxisSpacing: 16,
              mainAxisSpacing: 16,
              childAspectRatio: 0.75,
            ),
            delegate: SliverChildBuilderDelegate(
              (context, index) {
                final artwork = filteredArtworks[index];
                return _buildModernArtworkCard(artwork, index);
              },
              childCount: filteredArtworks.length,
            ),
          );
        },
      ),
    );
  }

  Widget _buildLoadingGrid() {
    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      padding: const EdgeInsets.symmetric(vertical: 20),
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
              color: primaryOrange.withOpacity(0.1),
              shape: BoxShape.circle,
            ),
            child: Icon(Icons.palette, size: 48, color: primaryOrange),
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
            'Be the first to discover amazing artwork when artists start sharing!',
            style: TextStyle(
              fontSize: 14,
              color: darkGray,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyCategory() {
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
          Text(
            'No $_selectedCategory Found',
            style: const TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: Colors.black87,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Try selecting a different category or check back later for new artwork.',
            style: TextStyle(
              fontSize: 14,
              color: darkGray,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildModernArtworkCard(ArtworkModel artwork, int index) {
    return GestureDetector(
      onTap: () => _viewArtworkDetails(context, artwork),
      child: Hero(
        tag: 'artwork_${artwork.id}_$index',
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
                    
                    // Gradient Overlay
                    Positioned(
                      bottom: 0,
                      left: 0,
                      right: 0,
                      child: Container(
                        height: 40,
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            begin: Alignment.bottomCenter,
                            end: Alignment.topCenter,
                            colors: [
                              Colors.black.withOpacity(0.3),
                              Colors.transparent,
                            ],
                          ),
                          borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
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
                        if (artwork.images.length > 1) ...[
                          const SizedBox(height: 16),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: artwork.images.asMap().entries.map((entry) {
                              return Container(
                                width: 8,
                                height: 8,
                                margin: const EdgeInsets.symmetric(horizontal: 4),
                                decoration: BoxDecoration(
                                  shape: BoxShape.circle,
                                  color: primaryPurple.withOpacity(0.3),
                                ),
                              );
                            }).toList(),
                          ),
                        ],
                        const SizedBox(height: 24),
                      ],

                      // Artist Info Section
                      FutureBuilder<UserModel?>(
                        future: Provider.of<FirestoreService>(context, listen: false)
                            .getUser(artwork.artistId),
                        builder: (context, userSnapshot) {
                          if (userSnapshot.connectionState == ConnectionState.waiting) {
                            return Container(
                              padding: const EdgeInsets.symmetric(vertical: 12),
                              child: Row(
                                children: [
                                  Text(
                                    'Artist: ',
                                    style: TextStyle(
                                      fontSize: 14,
                                      fontWeight: FontWeight.w600,
                                      color: darkGray,
                                    ),
                                  ),
                                  SizedBox(
                                    width: 16,
                                    height: 16,
                                    child: CircularProgressIndicator(
                                      strokeWidth: 2,
                                      valueColor: AlwaysStoppedAnimation<Color>(primaryPurple),
                                    ),
                                  ),
                                ],
                              ),
                            );
                          }

                          if (userSnapshot.hasError || !userSnapshot.hasData) {
                            return Container(
                              padding: const EdgeInsets.symmetric(vertical: 12),
                              child: Text(
                                'Artist: Unknown',
                                style: TextStyle(
                                  fontSize: 14,
                                  fontWeight: FontWeight.w600,
                                  color: darkGray,
                                ),
                              ),
                            );
                          }

                          final artist = userSnapshot.data!;
                          return GestureDetector(
                            onTap: () {
                              Navigator.pop(context);
                              _navigateToArtistProfile(context, artist);
                            },
                            child: Container(
                              padding: const EdgeInsets.all(16),
                              margin: const EdgeInsets.only(bottom: 16),
                              decoration: BoxDecoration(
                                gradient: LinearGradient(
                                  colors: [
                                    primaryGreen.withOpacity(0.1),
                                    primaryPurple.withOpacity(0.05),
                                  ],
                                ),
                                borderRadius: BorderRadius.circular(16),
                                border: Border.all(color: primaryGreen.withOpacity(0.2)),
                              ),
                              child: Row(
                                children: [
                                  CircleAvatar(
                                    radius: 20,
                                    backgroundColor: primaryGreen,
                                    child: Text(
                                      artist.name.isNotEmpty
                                          ? artist.name[0].toUpperCase()
                                          : 'A',
                                      style: const TextStyle(
                                        color: Colors.white,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                  ),
                                  const SizedBox(width: 12),
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          artist.name,
                                          style: TextStyle(
                                            fontSize: 16,
                                            fontWeight: FontWeight.bold,
                                            color: primaryGreen,
                                          ),
                                        ),
                                        Text(
                                          'View Artist Profile',
                                          style: TextStyle(
                                            fontSize: 12,
                                            color: darkGray,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                  Icon(
                                    Icons.arrow_forward_ios,
                                    size: 16,
                                    color: primaryGreen,
                                  ),
                                ],
                              ),
                            ),
                          );
                        },
                      ),

                      // Artwork Details
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

  void _navigateToArtistProfile(BuildContext context, UserModel artist) {
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
                  child: Column(
                    children: [
                      // Artist Profile Header
                      Container(
                        width: double.infinity,
                        padding: const EdgeInsets.symmetric(vertical: 40, horizontal: 24),
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                            colors: [primaryPurple, primaryOrange],
                          ),
                          borderRadius: const BorderRadius.vertical(top: Radius.circular(28)),
                        ),
                        child: Column(
                          children: [
                            Container(
                              padding: const EdgeInsets.all(4),
                              decoration: BoxDecoration(
                                color: backgroundWhite,
                                shape: BoxShape.circle,
                                boxShadow: [
                                  BoxShadow(
                                    color: Colors.black.withOpacity(0.2),
                                    blurRadius: 20,
                                    offset: const Offset(0, 10),
                                  ),
                                ],
                              ),
                              child: CircleAvatar(
                                radius: 50,
                                backgroundColor: primaryGreen,
                                child: Text(
                                  artist.name.isNotEmpty
                                      ? artist.name[0].toUpperCase()
                                      : 'A',
                                  style: const TextStyle(
                                    fontSize: 36,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.white,
                                  ),
                                ),
                              ),
                            ),
                            const SizedBox(height: 20),
                            Text(
                              artist.name,
                              style: const TextStyle(
                                fontSize: 28,
                                fontWeight: FontWeight.bold,
                                color: Colors.white,
                              ),
                            ),
                            const SizedBox(height: 8),
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
                              decoration: BoxDecoration(
                                color: Colors.white.withOpacity(0.2),
                                borderRadius: BorderRadius.circular(20),
                              ),
                              child: Text(
                                artist.email,
                                style: const TextStyle(
                                  fontSize: 14,
                                  color: Colors.white,
                                ),
                              ),
                            ),
                            if (artist.location != null) ...[
                              const SizedBox(height: 12),
                              Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  const Icon(Icons.location_on, size: 16, color: Colors.white70),
                                  const SizedBox(width: 4),
                                  Text(
                                    artist.location!,
                                    style: const TextStyle(color: Colors.white70, fontSize: 14),
                                  ),
                                ],
                              ),
                            ],
                            if (artist.bio != null) ...[
                              const SizedBox(height: 20),
                              Container(
                                padding: const EdgeInsets.all(16),
                                decoration: BoxDecoration(
                                  color: Colors.white.withOpacity(0.1),
                                  borderRadius: BorderRadius.circular(16),
                                ),
                                child: Text(
                                  artist.bio!,
                                  style: const TextStyle(
                                    fontSize: 16,
                                    color: Colors.white,
                                    height: 1.4,
                                  ),
                                  textAlign: TextAlign.center,
                                ),
                              ),
                            ],
                          ],
                        ),
                      ),

                      // Artist's Artworks Section
                      Padding(
                        padding: const EdgeInsets.all(24),
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
                                  child: Icon(Icons.palette, color: primaryOrange, size: 20),
                                ),
                                const SizedBox(width: 12),
                                const Text(
                                  'Artist\'s Gallery',
                                  style: TextStyle(
                                    fontSize: 22,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.black87,
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 20),
                            
                            StreamBuilder<List<ArtworkModel>>(
                              stream: Provider.of<FirestoreService>(context)
                                  .getArtworksByArtist(artist.uid),
                              builder: (context, snapshot) {
                                if (snapshot.hasError) {
                                  return Container(
                                    padding: const EdgeInsets.all(32),
                                    child: Column(
                                      children: [
                                        Icon(Icons.error, size: 48, color: Colors.red.withOpacity(0.5)),
                                        const SizedBox(height: 16),
                                        const Text(
                                          'Error loading artworks',
                                          style: TextStyle(fontSize: 16, color: Colors.red),
                                        ),
                                      ],
                                    ),
                                  );
                                }

                                if (snapshot.connectionState == ConnectionState.waiting) {
                                  return Container(
                                    padding: const EdgeInsets.all(32),
                                    child: Center(
                                      child: CircularProgressIndicator(
                                        valueColor: AlwaysStoppedAnimation<Color>(primaryPurple),
                                      ),
                                    ),
                                  );
                                }

                                if (!snapshot.hasData || snapshot.data!.isEmpty) {
                                  return Container(
                                    padding: const EdgeInsets.all(32),
                                    child: Column(
                                      children: [
                                        Container(
                                          padding: const EdgeInsets.all(20),
                                          decoration: BoxDecoration(
                                            color: primaryGreen.withOpacity(0.1),
                                            shape: BoxShape.circle,
                                          ),
                                          child: Icon(Icons.palette, size: 40, color: primaryGreen),
                                        ),
                                        const SizedBox(height: 16),
                                        const Text(
                                          'No artworks available',
                                          style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
                                        ),
                                        const SizedBox(height: 8),
                                        Text(
                                          'This artist hasn\'t shared any artwork yet.',
                                          style: TextStyle(fontSize: 14, color: darkGray),
                                          textAlign: TextAlign.center,
                                        ),
                                      ],
                                    ),
                                  );
                                }

                                final artworks = snapshot.data!;

                                return GridView.builder(
                                  shrinkWrap: true,
                                  physics: const NeverScrollableScrollPhysics(),
                                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                                    crossAxisCount: 2,
                                    crossAxisSpacing: 16,
                                    mainAxisSpacing: 16,
                                    childAspectRatio: 0.75,
                                  ),
                                  itemCount: artworks.length,
                                  itemBuilder: (context, index) {
                                    final artwork = artworks[index];
                                    return GestureDetector(
                                      onTap: () {
                                        Navigator.pop(context);
                                        _viewArtworkDetails(context, artwork);
                                      },
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
                                                    borderRadius: const BorderRadius.vertical(
                                                        top: Radius.circular(20)),
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
                                                            child: Icon(Icons.image,
                                                                size: 40, color: darkGray),
                                                          ),
                                                  ),
                                                  if (!artwork.availability)
                                                    Positioned(
                                                      top: 8,
                                                      right: 8,
                                                      child: Container(
                                                        padding: const EdgeInsets.symmetric(
                                                            horizontal: 8, vertical: 4),
                                                        decoration: BoxDecoration(
                                                          color: Colors.red,
                                                          borderRadius: BorderRadius.circular(12),
                                                        ),
                                                        child: const Text(
                                                          'Sold',
                                                          style: TextStyle(
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
                                                    Text(
                                                      artwork.artStyle,
                                                      style: TextStyle(
                                                        color: primaryPurple.withOpacity(0.7),
                                                        fontSize: 12,
                                                        fontWeight: FontWeight.w500,
                                                      ),
                                                      maxLines: 1,
                                                      overflow: TextOverflow.ellipsis,
                                                    ),
                                                    const Spacer(),
                                                    Row(
                                                      mainAxisAlignment:
                                                          MainAxisAlignment.spaceBetween,
                                                      children: [
                                                        Text(
                                                          '₱${artwork.price.toStringAsFixed(2)}',
                                                          style: TextStyle(
                                                            fontWeight: FontWeight.bold,
                                                            color: primaryOrange,
                                                            fontSize: 14,
                                                          ),
                                                        ),
                                                        Icon(
                                                          artwork.availability
                                                              ? Icons.check_circle
                                                              : Icons.cancel,
                                                          color: artwork.availability
                                                              ? primaryGreen
                                                              : Colors.red,
                                                          size: 16,
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
                                    );
                                  },
                                );
                              },
                            ),
                          ],
                        ),
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
}