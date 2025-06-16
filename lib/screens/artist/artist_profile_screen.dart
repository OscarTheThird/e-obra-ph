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

class ArtistProfileScreen extends StatelessWidget {
  const ArtistProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final authService = Provider.of<AuthService>(context);
    final firestoreService = Provider.of<FirestoreService>(context);
    final user = authService.currentUserModel;

    

    return Scaffold(
      backgroundColor: const Color(0xFFF6F6F9),
      appBar: AppBar(
        elevation: 0,
        backgroundColor: Colors.deepPurple,
        foregroundColor: Colors.white,
        title: const Text('My Profile', style: TextStyle(fontWeight: FontWeight.w600)),
        actions: [
          IconButton(
            icon: const Icon(Icons.logout),
            tooltip: 'Logout',
            onPressed: () async {
              await authService.signOut();
              context.go('/login');
            },
          ),
        ],
      ),
      body: user == null
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              child: Column(
                children: [
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.symmetric(vertical: 32, horizontal: 24),
                    decoration: const BoxDecoration(
                      color: Colors.deepPurple,
                      borderRadius: BorderRadius.vertical(bottom: Radius.circular(32)),
                    ),
                    child: Column(
                      children: [
                        CircleAvatar(
                          radius: 52,
                          backgroundColor: Colors.white,
                          child: CircleAvatar(
                            radius: 48,
                            backgroundColor: Colors.deepPurple,
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
                        const SizedBox(height: 20),
                        Text(
                          user.name,
                          style: const TextStyle(
                            fontSize: 26,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          user.email,
                          style: TextStyle(
                            fontSize: 15,
                            color: Colors.white.withOpacity(0.8),
                          ),
                        ),
                        if (user.location != null) ...[
                          const SizedBox(height: 10),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              const Icon(Icons.location_on, size: 18, color: Colors.white70),
                              const SizedBox(width: 5),
                              Text(
                                user.location!,
                                style: const TextStyle(color: Colors.white70),
                              ),
                            ],
                          ),
                        ],
                        if (user.bio != null) ...[
                          const SizedBox(height: 16),
                          Text(
                            user.bio!,
                            style: const TextStyle(
                              fontSize: 16,
                              color: Colors.white70,
                            ),
                            textAlign: TextAlign.center,
                          ),
                        ],
                      ],
                    ),
                  ),
                  const SizedBox(height: 28),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 18),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            const Text(
                              'My Artworks',
                              style: TextStyle(
                                fontSize: 22,
                                fontWeight: FontWeight.bold,
                                color: Colors.deepPurple,
                              ),
                            ),
                            const Spacer(),
                            ElevatedButton.icon(
                              onPressed: () {
                                context.go('/artist/create');
                              },
                              icon: const Icon(Icons.add, size: 20),
                              label: const Text('Add New'),
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Colors.deepPurple,
                                foregroundColor: Colors.white,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(14),
                                ),
                                elevation: 0,
                                padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 12),
                                textStyle: const TextStyle(fontWeight: FontWeight.bold),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 18),
                        StreamBuilder<List<ArtworkModel>>(
                          stream: firestoreService.getArtworksByArtist(user.uid),
                          builder: (context, snapshot) {
                            if (snapshot.hasError) {
                              return Center(
                                child: Column(
                                  children: [
                                    const Icon(Icons.error_outline, size: 54, color: Colors.red),
                                    const SizedBox(height: 14),
                                    const Text('Error loading artworks', style: TextStyle(fontSize: 18)),
                                    Text('${snapshot.error}', style: const TextStyle(fontSize: 13)),
                                    const SizedBox(height: 12),
                                    ElevatedButton(
                                      onPressed: () {
                                        (context as Element).markNeedsBuild();
                                      },
                                      child: const Text('Retry'),
                                    ),
                                  ],
                                ),
                              );
                            }

                            if (snapshot.connectionState == ConnectionState.waiting && !snapshot.hasData) {
                              return const Padding(
                                padding: EdgeInsets.all(32.0),
                                child: Center(child: CircularProgressIndicator()),
                              );
                            }

                            if (!snapshot.hasData || snapshot.data!.isEmpty) {
                              return Center(
                                child: Padding(
                                  padding: const EdgeInsets.symmetric(vertical: 42),
                                  child: Column(
                                    children: [
                                      Icon(Icons.palette_rounded, size: 70, color: Colors.deepPurple.withOpacity(0.18)),
                                      const SizedBox(height: 18),
                                      const Text('No artworks yet', style: TextStyle(fontSize: 18, fontWeight: FontWeight.w500)),
                                      const SizedBox(height: 6),
                                      Text('Create your first post to get started!',
                                        style: TextStyle(fontSize: 15, color: Colors.grey[600]),
                                      ),
                                      const SizedBox(height: 22),
                                      ElevatedButton.icon(
                                        onPressed: () {
                                          context.go('/artist/create');
                                        },
                                        icon: const Icon(Icons.add),
                                        label: const Text('Create First Artwork'),
                                        style: ElevatedButton.styleFrom(
                                          backgroundColor: Colors.deepPurple,
                                          foregroundColor: Colors.white,
                                          shape: RoundedRectangleBorder(
                                            borderRadius: BorderRadius.circular(12),
                                          ),
                                          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 13),
                                          textStyle: const TextStyle(fontWeight: FontWeight.bold),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              );
                            }

                            final artworks = snapshot.data!;

                            return GridView.builder(
                              shrinkWrap: true,
                              physics: const NeverScrollableScrollPhysics(),
                              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                                crossAxisCount: 2,
                                crossAxisSpacing: 18,
                                mainAxisSpacing: 18,
                                childAspectRatio: 0.74,
                              ),
                              itemCount: artworks.length,
                              itemBuilder: (context, index) {
                                final artwork = artworks[index];
                                return GestureDetector(
                                  onTap: () => _viewArtworkDetails(context, artwork),
                                  child: Card(
                                    elevation: 7,
                                    margin: EdgeInsets.zero,
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(20),
                                    ),
                                    clipBehavior: Clip.antiAlias,
                                    child: Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        Expanded(
                                          flex: 3,
                                          child: Stack(
                                            children: [
                                              Positioned.fill(
                                                child: artwork.images.isNotEmpty
                                                    ? _buildOptimizedThumbnail(artwork.images.first)
                                                    : Container(
                                                        color: Colors.grey[200],
                                                        child: const Icon(Icons.image, size: 60, color: Colors.grey),
                                                      ),
                                              ),
                                              if (!artwork.availability)
                                                Positioned(
                                                  right: 0,
                                                  top: 0,
                                                  child: Container(
                                                    decoration: const BoxDecoration(
                                                      color: Colors.redAccent,
                                                      borderRadius: BorderRadius.only(
                                                        bottomLeft: Radius.circular(12),
                                                        topRight: Radius.circular(20),
                                                      ),
                                                    ),
                                                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                                                    child: const Text(
                                                      'Sold',
                                                      style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 12),
                                                    ),
                                                  ),
                                                ),
                                            ],
                                          ),
                                        ),
                                        Expanded(
                                          flex: 2,
                                          child: Padding(
                                            padding: const EdgeInsets.fromLTRB(14, 10, 14, 10),
                                            child: Column(
                                              crossAxisAlignment: CrossAxisAlignment.start,
                                              children: [
                                                Text(
                                                  artwork.title,
                                                  style: const TextStyle(
                                                    fontWeight: FontWeight.w700,
                                                    fontSize: 16,
                                                    color: Colors.black87,
                                                  ),
                                                  maxLines: 1,
                                                  overflow: TextOverflow.ellipsis,
                                                ),
                                                const SizedBox(height: 2),
                                                Text(
                                                  artwork.artStyle,
                                                  style: TextStyle(
                                                    color: Colors.deepPurple.withOpacity(0.7),
                                                    fontSize: 13,
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
                                                      '\$${artwork.price.toStringAsFixed(2)}',
                                                      style: const TextStyle(
                                                        fontWeight: FontWeight.w800,
                                                        color: Colors.deepPurple,
                                                        fontSize: 15,
                                                      ),
                                                    ),
                                                    Icon(
                                                      artwork.availability
                                                          ? Icons.check_circle
                                                          : Icons.cancel,
                                                      color: artwork.availability
                                                          ? Colors.green
                                                          : Colors.red,
                                                      size: 18,
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
                  const SizedBox(height: 28),
                ],
              ),
            ),
      bottomNavigationBar: const ArtistBottomNavBar(currentIndex: 1),
    );
  }

  Widget _buildOptimizedThumbnail(String imageUrl) {
    final publicId = CloudinaryUtils.extractPublicId(imageUrl);
    if (publicId == null) {
      return Container(
        color: Colors.grey[300],
        child: const Icon(Icons.error, size: 50),
      );
    }
    final thumbnailUrl = CloudinaryService.getThumbnailUrl(publicId, size: 320);
    return CachedNetworkImage(
      imageUrl: thumbnailUrl,
      fit: BoxFit.cover,
      width: double.infinity,
      placeholder: (context, url) => Container(
        color: Colors.grey[100],
        child: const Center(
          child: SizedBox(
            width: 28,
            height: 28,
            child: CircularProgressIndicator(strokeWidth: 2),
          ),
        ),
      ),
      errorWidget: (context, url, error) => Container(
        color: Colors.grey[300],
        child: const Icon(Icons.error, size: 38),
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
        color: Colors.grey[300],
        child: const Icon(Icons.error, size: 50),
      );
    }
    final displayUrl = CloudinaryService.getArtworkDisplayUrl(publicId, maxWidth: 900);
    return CachedNetworkImage(
      imageUrl: displayUrl,
      fit: BoxFit.cover,
      height: height,
      placeholder: (context, url) => Container(
        height: height ?? 320,
        color: Colors.grey[100],
        child: const Center(
          child: CircularProgressIndicator(),
        ),
      ),
      errorWidget: (context, url, error) => Container(
        height: height ?? 320,
        color: Colors.grey[300],
        child: const Icon(Icons.error, size: 50),
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
          decoration: const BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
            boxShadow: [
              BoxShadow(
                color: Color(0x1A000000),
                blurRadius: 16,
                offset: Offset(0, -8),
              )
            ]
          ),
          child: Column(
            children: [
              Container(
                margin: const EdgeInsets.symmetric(vertical: 10),
                width: 44,
                height: 5,
                decoration: BoxDecoration(
                  color: Colors.grey[300],
                  borderRadius: BorderRadius.circular(3),
                ),
              ),
              Expanded(
                child: SingleChildScrollView(
                  controller: scrollController,
                  padding: const EdgeInsets.all(18),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      if (artwork.images.isNotEmpty) ...[
                        SizedBox(
                          height: 330,
                          child: PageView.builder(
                            itemCount: artwork.images.length,
                            itemBuilder: (context, index) => ClipRRect(
                              borderRadius: BorderRadius.circular(18),
                              child: _buildOptimizedDisplayImage(
                                artwork.images[index],
                                height: 330,
                              ),
                            ),
                          ),
                        ),
                        if (artwork.images.length > 1) ...[
                          const SizedBox(height: 10),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: artwork.images.asMap().entries.map((entry) {
                              return Container(
                                width: 9,
                                height: 9,
                                margin: const EdgeInsets.symmetric(horizontal: 3),
                                decoration: BoxDecoration(
                                  shape: BoxShape.circle,
                                  color: Colors.deepPurple.withOpacity(0.21),
                                ),
                              );
                            }).toList(),
                          ),
                        ],
                        const SizedBox(height: 22),
                      ],
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Expanded(
                            child: Text(
                              artwork.title,
                              style: const TextStyle(
                                fontSize: 26,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                          Text(
                            '\$${artwork.price.toStringAsFixed(2)}',
                            style: const TextStyle(
                              fontSize: 22,
                              fontWeight: FontWeight.bold,
                              color: Colors.deepPurple,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 10),
                      Row(
                        children: [
                          Chip(
                            label: Text(artwork.artStyle),
                            backgroundColor: Colors.deepPurple.withOpacity(0.1),
                          ),
                          const SizedBox(width: 9),
                          Chip(
                            label: Text(
                              artwork.availability ? 'Available' : 'Sold',
                            ),
                            backgroundColor: artwork.availability
                                ? Colors.green.withOpacity(0.1)
                                : Colors.red.withOpacity(0.1),
                            labelStyle: TextStyle(
                              color: artwork.availability ? Colors.green : Colors.red,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 19),
                      if (artwork.description.isNotEmpty) ...[
                        const Text(
                          'Description',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 7),
                        Text(
                          artwork.description,
                          style: const TextStyle(fontSize: 16, color: Colors.black87),
                        ),
                        const SizedBox(height: 16),
                      ],
                      if (artwork.medium.isNotEmpty) ...[
                        Row(
                          children: [
                            const Icon(Icons.brush, color: Colors.grey, size: 20),
                            const SizedBox(width: 8),
                            Text(
                              'Medium: ${artwork.medium}',
                              style: const TextStyle(fontSize: 16),
                            ),
                          ],
                        ),
                        const SizedBox(height: 7),
                      ],
                      if (artwork.dimensions.isNotEmpty) ...[
                        Row(
                          children: [
                            const Icon(Icons.straighten, color: Colors.grey, size: 20),
                            const SizedBox(width: 8),
                            Text(
                              'Dimensions: ${artwork.dimensions}',
                              style: const TextStyle(fontSize: 16),
                            ),
                          ],
                        ),
                        const SizedBox(height: 7),
                      ],
                      Row(
                        children: [
                          const Icon(Icons.calendar_today, color: Colors.grey, size: 18),
                          const SizedBox(width: 8),
                          Text(
                            'Created: ${artwork.createdAt.toDate().toString().split(' ')[0]}',
                            style: const TextStyle(fontSize: 16),
                          ),
                        ],
                      ),
                      const SizedBox(height: 26),
                      if (kDebugMode) ...[
                        ExpansionTile(
                          title: const Text('Debug: Image URLs'),
                          children: artwork.images.map((url) {
                            final publicId = CloudinaryUtils.extractPublicId(url);
                            return Padding(
                              padding: const EdgeInsets.all(8.0),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text('Original: $url'),
                                  if (publicId != null) ...[
                                    Text('Public ID: $publicId'),
                                    Text('Thumbnail: ${CloudinaryService.getThumbnailUrl(publicId)}'),
                                    Text('Display: ${CloudinaryService.getArtworkDisplayUrl(publicId)}'),
                                  ],
                                  const Divider(),
                                ],
                              ),
                            );
                          }).toList(),
                        ),
                        const SizedBox(height: 14),
                      ],
                      Row(
                        children: [
                          Expanded(
                            child: ElevatedButton.icon(
                              onPressed: () {
                                Navigator.pop(context);
                                context.go('/artist/edit/${artwork.id}');
                              },
                              icon: const Icon(Icons.edit),
                              label: const Text('Edit'),
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Colors.deepPurple,
                                foregroundColor: Colors.white,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(14),
                                ),
                                padding: const EdgeInsets.symmetric(horizontal: 0, vertical: 14),
                              ),
                            ),
                          ),
                          const SizedBox(width: 16),
                          Expanded(
                            child: OutlinedButton.icon(
                              onPressed: () {
                                Navigator.pop(context);
                                _confirmDelete(context, artwork);
                              },
                              icon: const Icon(Icons.delete, color: Colors.red),
                              label: const Text('Delete', style: TextStyle(color: Colors.red)),
                              style: OutlinedButton.styleFrom(
                                side: const BorderSide(color: Colors.red),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(14),
                                ),
                                padding: const EdgeInsets.symmetric(horizontal: 0, vertical: 14),
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

  void _confirmDelete(BuildContext context, ArtworkModel artwork) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Artwork'),
        content: Text('Are you sure you want to delete "${artwork.title}"? This action cannot be undone.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () async {
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Deleting artwork...')),
              );
              try {
                final firestoreService = Provider.of<FirestoreService>(context, listen: false);
                // TODO: Also delete images from Cloudinary
                // for (String imageUrl in artwork.images) {
                //   final publicId = CloudinaryUtils.extractPublicId(imageUrl);
                //   if (publicId != null) {
                //     await CloudinaryService.deleteImage(publicId);
                //   }
                // }
                await firestoreService.deleteArtwork(artwork.id);
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Artwork deleted successfully'),
                    backgroundColor: Colors.green,
                  ),
                );
              } catch (e) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text('Failed to delete artwork: $e'),
                    backgroundColor: Colors.red,
                  ),
                );
              }
            },
            child: const Text('Delete', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
  }
}