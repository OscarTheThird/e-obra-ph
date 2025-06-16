// services/firestore_service.dart
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/artwork_model.dart';
import '../models/user_model.dart';

class FirestoreService extends ChangeNotifier {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  Future<void> createArtwork(ArtworkModel artwork) async {
    await _firestore.collection('artworks').add(artwork.toMap());
  }

  Stream<List<ArtworkModel>> getArtworks() {
    return _firestore
        .collection('artworks')
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map((snapshot) => snapshot.docs
            .map((doc) => ArtworkModel.fromMap(doc.data(), doc.id))
            .toList());
  }

  Stream<List<ArtworkModel>> getArtworksByArtist(String artistId) {
    return _firestore
        .collection('artworks')
        .where('artistId', isEqualTo: artistId)
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map((snapshot) => snapshot.docs
            .map((doc) => ArtworkModel.fromMap(doc.data(), doc.id))
            .toList());
  }

  Future<List<ArtworkModel>> searchArtworks({
  String? artType,
  double? minPrice,
  double? maxPrice,
  String? artStyle,
}) async {
  try {
    // Get all artworks and filter client-side to avoid complex indexes
    Query query = _firestore.collection('artworks');
    
    // Only apply one server-side filter to avoid compound index requirements
    if (artType != null) {
      query = query.where('artType', isEqualTo: artType);
    }
    
    final snapshot = await query.get();
    List<ArtworkModel> results = snapshot.docs
        .map((doc) => ArtworkModel.fromMap(doc.data() as Map<String, dynamic>, doc.id))
        .toList();
    
    // Apply additional filters client-side
    if (minPrice != null && minPrice > 0) {
      results = results.where((artwork) => artwork.price >= minPrice).toList();
    }
    
    if (maxPrice != null && maxPrice != double.infinity) {
      results = results.where((artwork) => artwork.price <= maxPrice).toList();
    }
    
    if (artStyle != null) {
      results = results.where((artwork) => artwork.artStyle == artStyle).toList();
    }
    
    // Sort by price
    results.sort((a, b) => a.price.compareTo(b.price));
    
    return results;
  } catch (e) {
    print('Error searching artworks: $e');
    return [];
  }
}
  // Get a single artwork by ID
  Future<ArtworkModel?> getArtwork(String artworkId) async {
    try {
      final doc = await _firestore.collection('artworks').doc(artworkId).get();
      if (doc.exists && doc.data() != null) {
        return ArtworkModel.fromMap(doc.data()!, doc.id);
      }
      return null;
    } catch (e) {
      print('Error getting artwork: $e');
      return null;
    }
  }

  // Update an artwork
  Future<void> updateArtwork(String artworkId, ArtworkModel artwork) async {
    try {
      await _firestore.collection('artworks').doc(artworkId).update(artwork.toMap());
    } catch (e) {
      print('Error updating artwork: $e');
      throw Exception('Failed to update artwork: $e');
    }
  }

  // Delete an artwork
  Future<void> deleteArtwork(String artworkId) async {
    try {
      await _firestore.collection('artworks').doc(artworkId).delete();
    } catch (e) {
      print('Error deleting artwork: $e');
      throw Exception('Failed to delete artwork: $e');
    }
  }

  Future<UserModel?> getUser(String uid) async {
    try {
      final doc = await _firestore.collection('users').doc(uid).get();
      if (doc.exists && doc.data() != null) {
        return UserModel.fromMap(doc.data()!);
      }
      return null;
    } catch (e) {
      print('Error getting user: $e');
      return null;
    }
  }

  Future<void> updateUser(UserModel user) async {
    try {
      await _firestore.collection('users').doc(user.uid).update(user.toMap());
    } catch (e) {
      print('Error updating user: $e');
      throw Exception('Failed to update user: $e');
    }
  }

  // Create a new user document
  Future<void> createUser(UserModel user) async {
    try {
      await _firestore.collection('users').doc(user.uid).set(user.toMap());
    } catch (e) {
      print('Error creating user: $e');
      throw Exception('Failed to create user: $e');
    }
  }
}