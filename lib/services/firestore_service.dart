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
    Query query = _firestore.collection('artworks');

    if (artType != null) {
      query = query.where('artType', isEqualTo: artType);
    }
    if (minPrice != null) {
      query = query.where('price', isGreaterThanOrEqualTo: minPrice);
    }
    if (maxPrice != null) {
      query = query.where('price', isLessThanOrEqualTo: maxPrice);
    }

    final snapshot = await query.get();
    return snapshot.docs
        .map((doc) => ArtworkModel.fromMap(doc.data() as Map<String, dynamic>, doc.id))
        .toList();
  }

  // Get a single artwork by ID
  Future<ArtworkModel?> getArtwork(String artworkId) async {
    final doc = await _firestore.collection('artworks').doc(artworkId).get();
    if (doc.exists) {
      return ArtworkModel.fromMap(doc.data()!, doc.id);
    }
    return null;
  }

  // Update an artwork
  Future<void> updateArtwork(String artworkId, ArtworkModel artwork) async {
    await _firestore.collection('artworks').doc(artworkId).update(artwork.toMap());
  }

  // Delete an artwork
  Future<void> deleteArtwork(String artworkId) async {
    await _firestore.collection('artworks').doc(artworkId).delete();
  }

  Future<UserModel?> getUser(String uid) async {
    final doc = await _firestore.collection('users').doc(uid).get();
    if (doc.exists) {
      return UserModel.fromMap(doc.data()!);
    }
    return null;
  }

  Future<void> updateUser(UserModel user) async {
    await _firestore.collection('users').doc(user.uid).update(user.toMap());
  }

  // Create a new user document
  Future<void> createUser(UserModel user) async {
    await _firestore.collection('users').doc(user.uid).set(user.toMap());
  }
}