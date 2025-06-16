import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart'; // For kDebugMode
import 'package:provider/provider.dart';
import 'package:go_router/go_router.dart';
import 'package:cached_network_image/cached_network_image.dart';
import '../../services/auth_service.dart';
import '../../services/firestore_service.dart';
import '../../services/cloudinary_service.dart';
import '../../models/artwork_model.dart';
import '../../widgets/bottom_nav_bar.dart';

class ArtistProfileScreen extends StatefulWidget {
  const ArtistProfileScreen({super.key});

  @override
  State<ArtistProfileScreen> createState() => _ArtistProfileScreenState();
}

class _ArtistProfileScreenState extends State<ArtistProfileScreen> with TickerProviderStateMixin {
  late AnimationController _profileAnimationController;
  late AnimationController _contentAnimationController;
  late Animation<double> _profileFadeAnimation;
  late Animation<Offset> _profileSlideAnimation;
  late Animation<double> _contentFadeAnimation;

  // Color palette
  static const Color primaryOrange = Color(0xFFE8541D);
  static const Color primaryGreen = Color(0xFF00BF63);
  static const Color primaryPurple = Color(0xFF5E17EB);
  static const Color backgroundWhite = Color(0xFFFFFFFF);
  static const Color lightGray = Color(0xFFF8F9FA);
  static const Color darkGray = Color(0xFF6C757D);

  @override
  void initState() {
    super.initState();
    
    _profileAnimationController = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );
    
    _contentAnimationController = AnimationController(
      duration: const Duration(milliseconds: 1000),
      vsync: this,
    );
    
    _profileFadeAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _profileAnimationController,
      curve: Curves.easeInOut,
    ));
    
    _profileSlideAnimation = Tween<Offset>(
      begin: const Offset(0, -0.3),
      end: Offset.zero,
    ).animate(CurvedAnimation(
      parent: _profileAnimationController,
      curve: Curves.easeOutBack,
    ));
    
    _contentFadeAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _contentAnimationController,
      curve: Curves.easeInOut,
    ));
    
    // Start animations
    _profileAnimationController.forward();
    Future.delayed(const Duration(milliseconds: 300), () {
      _contentAnimationController.forward();
    });
  }

  @override
  void dispose() {
    _profileAnimationController.dispose();
    _contentAnimationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final authService = Provider.of<AuthService>(context);
    final firestoreService = Provider.of<FirestoreService>(context);
    final user = authService.currentUserModel;

    return Scaffold(
      backgroundColor: lightGray,
      body: user == null
          ? const Center(child: CircularProgressIndicator())
          : CustomScrollView(
              slivers: [
                _buildModernAppBar(authService, user),
                SliverToBoxAdapter(
                  child: Column(
                    children: [
                      _buildProfileSection(user),
                      _buildArtworksSection(firestoreService, user),
                    ],
                  ),
                ),
              ],
            ),
      bottomNavigationBar: const ArtistBottomNavBar(currentIndex: 1),
    );
  }

  Widget _buildModernAppBar(AuthService authService, dynamic user) {
    return SliverAppBar(
      expandedHeight: 280,
      floating: false,
      pinned: true,
      backgroundColor: Colors.transparent,
      elevation: 0,
      flexibleSpace: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              primaryPurple,
              primaryPurple.withOpacity(0.8),
              primaryOrange.withOpacity(0.6),
            ],
          ),
        ),
        child: FlexibleSpaceBar(
          centerTitle: false,
          titlePadding: const EdgeInsets.only(left: 20, bottom: 16),
          title: AnimatedBuilder(
            animation: _profileAnimationController,
            builder: (context, child) {
              return FadeTransition(
                opacity: _profileFadeAnimation,
                child: SlideTransition(
                  position: _profileSlideAnimation,
                  child: Text(
                    'My Profile',
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 10,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              );
            },
          ),
          background: AnimatedBuilder(
            animation: _profileAnimationController,
            builder: (context, child) {
              return FadeTransition(
                opacity: _profileFadeAnimation,
                child: SlideTransition(
                  position: _profileSlideAnimation,
                  child: Container(
                    padding: const EdgeInsets.only(top: 100, left: 20, right: 20),
                    child: Column(
                      children: [
                        Container(
                          width: 90,
                          height: 90,
                          decoration: BoxDecoration(
                            gradient: LinearGradient(
                              colors: [primaryGreen, primaryGreen.withOpacity(0.8)],
                            ),
                            borderRadius: BorderRadius.circular(25),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withOpacity(0.2),
                                blurRadius: 20,
                                offset: const Offset(0, 8),
                              ),
                            ],
                          ),
                          child: Center(
                            child: Text(
                              user.name.isNotEmpty ? user.name[0].toUpperCase() : 'A',
                              style: const TextStyle(
                                fontSize: 36,
                                fontWeight: FontWeight.bold,
                                color: Colors.white,
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(height: 16),
                        Text(
                          user.name,
                          style: const TextStyle(
                            fontSize: 24,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          user.email,
                          style: TextStyle(
                            fontSize: 14,
                            color: Colors.white.withOpacity(0.9),
                          ),
                        ),
                        if (user.location != null) ...[
                          const SizedBox(height: 8),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              const Icon(Icons.location_on, size: 16, color: Colors.white70),
                              const SizedBox(width: 4),
                              Text(
                                user.location!,
                                style: const TextStyle(color: Colors.white70, fontSize: 13),
                              ),
                            ],
                          ),
                        ],
                      ],
                    ),
                  ),
                ),
              );
            },
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
                color: Colors.white.withOpacity(0.2),
                borderRadius: BorderRadius.circular(12),
              ),
              child: const Icon(
                Icons.logout,
                color: Colors.white,
                size: 20,
              ),
            ),
            onPressed: () async {
              await authService.signOut();
              context.go('/login');
            },
          ),
        ),
      ],
    );
  }

  Widget _buildProfileSection(dynamic user) {
    return AnimatedBuilder(
      animation: _contentAnimationController,
      builder: (context, child) {
        return FadeTransition(
          opacity: _contentFadeAnimation,
          child: Container(
            margin: const EdgeInsets.all(20),
            child: Column(
              children: [
                if (user.bio != null)
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      color: backgroundWhite,
                      borderRadius: BorderRadius.circular(16),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.05),
                          blurRadius: 15,
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
                                color: primaryPurple.withOpacity(0.1),
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: Icon(
                                Icons.info_outline,
                                color: primaryPurple,
                                size: 20,
                              ),
                            ),
                            const SizedBox(width: 12),
                            Text(
                              'About Me',
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                                color: primaryPurple,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 12),
                        Text(
                          user.bio!,
                          style: TextStyle(
                            fontSize: 14,
                            color: darkGray,
                            height: 1.4,
                          ),
                        ),
                      ],
                    ),
                  ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildArtworksSection(FirestoreService firestoreService, dynamic user) {
    return AnimatedBuilder(
      animation: _contentAnimationController,
      builder: (context, child) {
        return FadeTransition(
          opacity: _contentFadeAnimation,
          child: Container(
            margin: const EdgeInsets.symmetric(horizontal: 20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Expanded(
                      child: Text(
                        'My Artworks',
                        style: TextStyle(
                          fontSize: 22,
                          fontWeight: FontWeight.bold,
                          color: primaryPurple,
                        ),
                      ),
                    ),
                    Container(
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          colors: [primaryOrange, primaryOrange.withOpacity(0.8)],
                        ),
                        borderRadius: BorderRadius.circular(14),
                        boxShadow: [
                          BoxShadow(
                            color: primaryOrange.withOpacity(0.3),
                            blurRadius: 10,
                            offset: const Offset(0, 4),
                          ),
                        ],
                      ),
                      child: Material(
                        color: Colors.transparent,
                        child: InkWell(
                          borderRadius: BorderRadius.circular(14),
                          onTap: () {
                            context.go('/artist/create');
                          },
                          child: Container(
                            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                const Icon(Icons.add, size: 18, color: Colors.white),
                                const SizedBox(width: 6),
                                const Text(
                                  'Add New',
                                  style: TextStyle(
                                    color: Colors.white,
                                    fontWeight: FontWeight.w600,
                                    fontSize: 14,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 20),
                StreamBuilder<List<ArtworkModel>>(
                  stream: firestoreService.getArtworksByArtist(user.uid),
                  builder: (context, snapshot) {
                    if (snapshot.hasError) {
                      return _buildErrorState(snapshot.error);
                    }

                    if (snapshot.connectionState == ConnectionState.waiting && !snapshot.hasData) {
                      return _buildLoadingState();
                    }

                    if (!snapshot.hasData || snapshot.data!.isEmpty) {
                      return _buildEmptyState();
                    }

                    final artworks = snapshot.data!;
                    return _buildArtworkGrid(artworks);
                  },
                ),
                const SizedBox(height: 30),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildErrorState(dynamic error) {
    return Container(
      padding: const EdgeInsets.all(32),
      decoration: BoxDecoration(
        color: backgroundWhite,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: primaryOrange.withOpacity(0.2)),
      ),
      child: Column(
        children: [
          Container(
            width: 60,
            height: 60,
            decoration: BoxDecoration(
              color: primaryOrange.withOpacity(0.1),
              borderRadius: BorderRadius.circular(16),
            ),
            child: Icon(Icons.error_outline, size: 30, color: primaryOrange),
          ),
          const SizedBox(height: 16),
          const Text('Error loading artworks', style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600)),
          const SizedBox(height: 8),
          Text('$error', style: TextStyle(fontSize: 13, color: darkGray)),
          const SizedBox(height: 16),
          ElevatedButton(
            onPressed: () {
              setState(() {});
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: primaryOrange,
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            ),
            child: const Text('Retry'),
          ),
        ],
      ),
    );
  }

  Widget _buildLoadingState() {
    return Container(
      padding: const EdgeInsets.all(40),
      child: Center(
        child: Column(
          children: [
            CircularProgressIndicator(color: primaryPurple),
            const SizedBox(height: 16),
            Text(
              'Loading your artworks...',
              style: TextStyle(color: darkGray, fontSize: 14),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildEmptyState() {
    return Container(
      padding: const EdgeInsets.all(32),
      decoration: BoxDecoration(
        color: backgroundWhite,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 15,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: Column(
        children: [
          Container(
            width: 80,
            height: 80,
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [primaryPurple.withOpacity(0.1), primaryOrange.withOpacity(0.1)],
              ),
              borderRadius: BorderRadius.circular(20),
            ),
            child: Icon(Icons.palette_rounded, size: 40, color: primaryPurple),
          ),
          const SizedBox(height: 20),
          const Text(
            'No artworks yet',
            style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 8),
          Text(
            'Create your first post to get started!',
            style: TextStyle(fontSize: 15, color: darkGray),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 24),
          Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [primaryPurple, primaryOrange],
              ),
              borderRadius: BorderRadius.circular(14),
              boxShadow: [
                BoxShadow(
                  color: primaryPurple.withOpacity(0.3),
                  blurRadius: 10,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: Material(
              color: Colors.transparent,
              child: InkWell(
                borderRadius: BorderRadius.circular(14),
                onTap: () {
                  context.go('/artist/create');
                },
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Icon(Icons.add, color: Colors.white),
                      const SizedBox(width: 8),
                      const Text(
                        'Create First Artwork',
                        style: TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildArtworkGrid(List<ArtworkModel> artworks) {
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
          onTap: () => _viewArtworkDetails(context, artwork),
          child: Container(
            decoration: BoxDecoration(
              color: backgroundWhite,
              borderRadius: BorderRadius.circular(16),
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
                        borderRadius: const BorderRadius.vertical(top: Radius.circular(16)),
                        child: Container(
                          width: double.infinity,
                          child: artwork.images.isNotEmpty
                              ? _buildOptimizedThumbnail(artwork.images.first)
                              : Container(
                                  color: lightGray,
                                  child: Icon(Icons.image, size: 40, color: darkGray),
                                ),
                        ),
                      ),
                      if (!artwork.availability)
                        Positioned(
                          right: 0,
                          top: 0,
                          child: Container(
                            decoration: BoxDecoration(
                              color: primaryOrange,
                              borderRadius: const BorderRadius.only(
                                bottomLeft: Radius.circular(12),
                                topRight: Radius.circular(16),
                              ),
                            ),
                            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                            child: const Text(
                              'Sold',
                              style: TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.bold,
                                fontSize: 10,
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
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 14,
                            color: primaryPurple,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                        const SizedBox(height: 4),
                        Text(
                          artwork.artStyle,
                          style: TextStyle(
                            color: darkGray,
                            fontSize: 12,
                            fontWeight: FontWeight.w500,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                        const Spacer(),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              '₱${artwork.price.toStringAsFixed(2)}',
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                                color: primaryGreen,
                                fontSize: 14,
                              ),
                            ),
                            Container(
                              width: 6,
                              height: 6,
                              decoration: BoxDecoration(
                                color: artwork.availability ? primaryGreen : primaryOrange,
                                shape: BoxShape.circle,
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
        );
      },
    );
  }

  Widget _buildOptimizedThumbnail(String imageUrl) {
    final publicId = CloudinaryUtils.extractPublicId(imageUrl);
    if (publicId == null) {
      return Container(
        color: lightGray,
        child: Icon(Icons.error, size: 40, color: primaryOrange),
      );
    }
    final thumbnailUrl = CloudinaryService.getThumbnailUrl(publicId, size: 320);
    return CachedNetworkImage(
      imageUrl: thumbnailUrl,
      fit: BoxFit.cover,
      width: double.infinity,
      placeholder: (context, url) => Container(
        color: lightGray,
        child: Center(
          child: SizedBox(
            width: 20,
            height: 20,
            child: CircularProgressIndicator(strokeWidth: 2, color: primaryPurple),
          ),
        ),
      ),
      errorWidget: (context, url, error) => Container(
        color: lightGray,
        child: Icon(Icons.error, size: 30, color: primaryOrange),
      ),
      memCacheWidth: 320,
      memCacheHeight: 320,
      fadeInDuration: const Duration(milliseconds: 230),
    );
  }

  Widget _buildOptimizedDisplayImage(String imageUrl, {double? height}) {
    final publicId = CloudinaryUtils.extractPublicId(imageUrl);
    if (publicId == null) {
      return Container(
        height: height ?? 320,
        color: lightGray,
        child: Icon(Icons.error, size: 50, color: primaryOrange),
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
          child: CircularProgressIndicator(color: primaryPurple),
        ),
      ),
      errorWidget: (context, url, error) => Container(
        height: height ?? 320,
        color: lightGray,
        child: Icon(Icons.error, size: 50, color: primaryOrange),
      ),
      fadeInDuration: const Duration(milliseconds: 300),
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
              )
            ]
          ),
          child: Column(
            children: [
              Container(
                margin: const EdgeInsets.symmetric(vertical: 12),
                width: 44,
                height: 5,
                decoration: BoxDecoration(
                  color: darkGray.withOpacity(0.3),
                  borderRadius: BorderRadius.circular(3),
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
                        _ImageSliderWidget(
                          artwork: artwork,
                          buildOptimizedDisplayImage: _buildOptimizedDisplayImage,
                        ),
                        const SizedBox(height: 24),
                      ],
                      
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Expanded(
                            child: Text(
                              artwork.title,
                              style: TextStyle(
                                fontSize: 26,
                                fontWeight: FontWeight.bold,
                                color: primaryPurple,
                              ),
                            ),
                          ),
                          Text(
                            '₱${artwork.price.toStringAsFixed(2)}',
                            style: TextStyle(
                              fontSize: 22,
                              fontWeight: FontWeight.bold,
                              color: primaryGreen,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 12),
                      Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                            decoration: BoxDecoration(
                              color: primaryPurple.withOpacity(0.1),
                              borderRadius: BorderRadius.circular(20),
                            ),
                            child: Text(
                              artwork.artStyle,
                              style: TextStyle(color: primaryPurple, fontWeight: FontWeight.w600),
                            ),
                          ),
                          const SizedBox(width: 10),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                            decoration: BoxDecoration(
                              color: artwork.availability 
                                  ? primaryGreen.withOpacity(0.1) 
                                  : primaryOrange.withOpacity(0.1),
                              borderRadius: BorderRadius.circular(20),
                            ),
                            child: Text(
                              artwork.availability ? 'Available' : 'Sold',
                              style: TextStyle(
                                color: artwork.availability ? primaryGreen : primaryOrange,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 20),
                      if (artwork.description.isNotEmpty) ...[
                        Text(
                          'Description',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: primaryPurple,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          artwork.description,
                          style: TextStyle(fontSize: 16, color: darkGray, height: 1.4),
                        ),
                        const SizedBox(height: 20),
                      ],
                      if (artwork.medium.isNotEmpty) ...[
                        _buildDetailRow(Icons.brush, 'Medium', artwork.medium),
                        const SizedBox(height: 12),
                      ],
                      if (artwork.dimensions.isNotEmpty) ...[
                        _buildDetailRow(Icons.straighten, 'Dimensions', artwork.dimensions),
                        const SizedBox(height: 12),
                      ],
                      _buildDetailRow(Icons.calendar_today, 'Created', 
                          artwork.createdAt.toDate().toString().split(' ')[0]),
                      const SizedBox(height: 30),
                      Row(
                        children: [
                          Expanded(
                            child: Container(
                              decoration: BoxDecoration(
                                gradient: LinearGradient(
                                  colors: [primaryPurple, primaryOrange],
                                ),
                                borderRadius: BorderRadius.circular(14),
                                boxShadow: [
                                  BoxShadow(
                                    color: primaryPurple.withOpacity(0.3),
                                    blurRadius: 10,
                                    offset: const Offset(0, 4),
                                  ),
                                ],
                              ),
                              child: Material(
                                color: Colors.transparent,
                                child: InkWell(
                                  borderRadius: BorderRadius.circular(14),
                                  onTap: () {
                                    if (kDebugMode) {
                                      print('Edit button pressed for artwork: ${artwork.id}');
                                    }
                                    
                                    Navigator.of(context).pop();
                                    
                                    Future.delayed(const Duration(milliseconds: 100), () {
                                      try {
                                        context.pushReplacement('/artist/edit/${artwork.id}');
                                        
                                        if (kDebugMode) {
                                          print('Navigation to edit screen initiated');
                                        }
                                      } catch (e) {
                                        if (kDebugMode) {
                                          print('Navigation error: $e');
                                        }
                                        
                                        ScaffoldMessenger.of(context).showSnackBar(
                                          SnackBar(
                                            content: Text('Navigation failed: $e'),
                                            backgroundColor: primaryOrange,
                                          ),
                                        );
                                      }
                                    });
                                  },
                                  child: Container(
                                    padding: const EdgeInsets.symmetric(vertical: 14),
                                    child: Row(
                                      mainAxisAlignment: MainAxisAlignment.center,
                                      children: [
                                        const Icon(Icons.edit, color: Colors.white),
                                        const SizedBox(width: 8),
                                        const Text(
                                          'Edit',
                                          style: TextStyle(
                                            color: Colors.white,
                                            fontWeight: FontWeight.w600,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                              ),
                            ),
                          ),
                          const SizedBox(width: 16),
                          Expanded(
                            child: Container(
                              decoration: BoxDecoration(
                                border: Border.all(color: primaryOrange, width: 2),
                                borderRadius: BorderRadius.circular(14),
                              ),
                              child: Material(
                                color: Colors.transparent,
                                child: InkWell(
                                  borderRadius: BorderRadius.circular(14),
                                  onTap: () {
                                    Navigator.pop(context);
                                    _confirmDelete(context, artwork);
                                  },
                                  child: Container(
                                    padding: const EdgeInsets.symmetric(vertical: 14),
                                    child: Row(
                                      mainAxisAlignment: MainAxisAlignment.center,
                                      children: [
                                        Icon(Icons.delete, color: primaryOrange),
                                        const SizedBox(width: 8),
                                        Text(
                                          'Delete',
                                          style: TextStyle(
                                            color: primaryOrange,
                                            fontWeight: FontWeight.w600,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                              ),
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

  Widget _buildDetailRow(IconData icon, String label, String value) {
    return Row(
      children: [
        Container(
          padding: const EdgeInsets.all(6),
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
            fontSize: 16,
            fontWeight: FontWeight.w600,
            color: primaryPurple,
          ),
        ),
        Expanded(
          child: Text(
            value,
            style: TextStyle(fontSize: 16, color: darkGray),
          ),
        ),
      ],
    );
  }

  void _confirmDelete(BuildContext context, ArtworkModel artwork) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: Text(
          'Delete Artwork',
          style: TextStyle(color: primaryPurple, fontWeight: FontWeight.bold),
        ),
        content: Text(
          'Are you sure you want to delete "${artwork.title}"? This action cannot be undone.',
          style: TextStyle(color: darkGray),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('Cancel', style: TextStyle(color: darkGray)),
          ),
          Container(
            decoration: BoxDecoration(
              color: primaryOrange,
              borderRadius: BorderRadius.circular(8),
            ),
            child: TextButton(
              onPressed: () async {
                Navigator.pop(context);
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: const Text('Deleting artwork...'),
                    backgroundColor: primaryOrange,
                  ),
                );
                try {
                  final firestoreService = Provider.of<FirestoreService>(context, listen: false);
                  await firestoreService.deleteArtwork(artwork.id);
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: const Text('Artwork deleted successfully'),
                      backgroundColor: primaryGreen,
                    ),
                  );
                } catch (e) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text('Failed to delete artwork: $e'),
                      backgroundColor: primaryOrange,
                    ),
                  );
                }
              },
              child: const Text('Delete', style: TextStyle(color: Colors.white)),
            ),
          ),
        ],
      ),
    );
  }
}

// Enhanced Image Slider Widget with modern styling
class _ImageSliderWidget extends StatefulWidget {
  final ArtworkModel artwork;
  final Widget Function(String, {double? height}) buildOptimizedDisplayImage;

  const _ImageSliderWidget({
    required this.artwork,
    required this.buildOptimizedDisplayImage,
  });

  @override
  _ImageSliderWidgetState createState() => _ImageSliderWidgetState();
}

class _ImageSliderWidgetState extends State<_ImageSliderWidget> {
  int currentPage = 0;
  late PageController pageController;

  // Color palette
  static const Color primaryOrange = Color(0xFFE8541D);
  static const Color primaryGreen = Color(0xFF00BF63);
  static const Color primaryPurple = Color(0xFF5E17EB);
  static const Color darkGray = Color(0xFF6C757D);

  @override
  void initState() {
    super.initState();
    pageController = PageController();
  }

  @override
  void dispose() {
    pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Container(
          height: 300,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(20),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.1),
                blurRadius: 15,
                offset: const Offset(0, 8),
              ),
            ],
          ),
          child: PageView.builder(
            controller: pageController,
            onPageChanged: (index) {
              setState(() {
                currentPage = index;
              });
            },
            itemCount: widget.artwork.images.length,
            itemBuilder: (context, index) => ClipRRect(
              borderRadius: BorderRadius.circular(20),
              child: widget.buildOptimizedDisplayImage(
                widget.artwork.images[index],
                height: 300,
              ),
            ),
          ),
        ),
        
        if (widget.artwork.images.length > 1) ...[
          const SizedBox(height: 20),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              if (currentPage > 0)
                GestureDetector(
                  onTap: () {
                    pageController.previousPage(
                      duration: const Duration(milliseconds: 300),
                      curve: Curves.easeInOut,
                    );
                  },
                  child: Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: primaryPurple.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Icon(
                      Icons.chevron_left,
                      color: primaryPurple,
                      size: 24,
                    ),
                  ),
                ),
              
              Expanded(
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: widget.artwork.images.asMap().entries.map((entry) {
                    bool isActive = entry.key == currentPage;
                    return GestureDetector(
                      onTap: () {
                        pageController.animateToPage(
                          entry.key,
                          duration: const Duration(milliseconds: 300),
                          curve: Curves.easeInOut,
                        );
                      },
                      child: AnimatedContainer(
                        duration: const Duration(milliseconds: 200),
                        width: isActive ? 28 : 8,
                        height: 8,
                        margin: const EdgeInsets.symmetric(horizontal: 4),
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(4),
                          color: isActive 
                              ? primaryPurple 
                              : primaryPurple.withOpacity(0.3),
                        ),
                      ),
                    );
                  }).toList(),
                ),
              ),
              
              if (currentPage < widget.artwork.images.length - 1)
                GestureDetector(
                  onTap: () {
                    pageController.nextPage(
                      duration: const Duration(milliseconds: 300),
                      curve: Curves.easeInOut,
                    );
                  },
                  child: Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: primaryPurple.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Icon(
                      Icons.chevron_right,
                      color: primaryPurple,
                      size: 24,
                    ),
                  ),
                ),
            ],
          ),
          
          const SizedBox(height: 12),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            decoration: BoxDecoration(
              color: primaryPurple.withOpacity(0.1),
              borderRadius: BorderRadius.circular(16),
            ),
            child: Text(
              '${currentPage + 1} of ${widget.artwork.images.length}',
              style: TextStyle(
                fontSize: 12,
                color: primaryPurple,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ],
    );
  }
}