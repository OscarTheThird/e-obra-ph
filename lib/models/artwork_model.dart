import 'package:cloud_firestore/cloud_firestore.dart';

class ArtworkModel {
  final String id;
  final String title;
  final String description;
  final List<String> images;
  final double price;
  final String artStyle;
  final String artType;
  final String medium;
  final String dimensions;
  final bool availability;
  final String artistId;
  final String artistName;
  final Timestamp createdAt;

  ArtworkModel({
    required this.id,
    required this.title,
    required this.description,
    required this.images,
    required this.price,
    required this.artStyle,
    required this.artType,
    required this.medium,
    required this.dimensions,
    required this.availability,
    required this.artistId,
    required this.artistName,
    required this.createdAt,
  });

  // Convert from Firestore document
  factory ArtworkModel.fromMap(Map<String, dynamic> map, String id) {
    Timestamp createdAtTs;

    if (map['createdAt'] is Timestamp) {
      createdAtTs = map['createdAt'] as Timestamp;
    } else if (map['createdAt'] is String) {
      createdAtTs = Timestamp.fromDate(DateTime.parse(map['createdAt']));
    } else if (map['createdAt'] is DateTime) {
      createdAtTs = Timestamp.fromDate(map['createdAt'] as DateTime);
    } else {
      createdAtTs = Timestamp.now();
    }

    return ArtworkModel(
      id: id,
      title: map['title'] ?? '',
      description: map['description'] ?? '',
      images: List<String>.from(map['images'] ?? []),
      price: (map['price'] ?? 0.0).toDouble(),
      artStyle: map['artStyle'] ?? '',
      artType: map['artType'] ?? '',
      medium: map['medium'] ?? '',
      dimensions: map['dimensions'] ?? '',
      availability: map['availability'] ?? true,
      artistId: map['artistId'] ?? '',
      artistName: map['artistName'] ?? '',
      createdAt: createdAtTs,
    );
  }

  // Convert to Firestore document
  Map<String, dynamic> toMap() {
    return {
      'title': title,
      'description': description,
      'images': images,
      'price': price,
      'artStyle': artStyle,
      'artType': artType,
      'medium': medium,
      'dimensions': dimensions,
      'availability': availability,
      'artistId': artistId,
      'artistName': artistName,
      'createdAt': createdAt,
    };
  }

  // Copy with method for updates
  ArtworkModel copyWith({
    String? id,
    String? title,
    String? description,
    List<String>? images,
    double? price,
    String? artStyle,
    String? artType,
    String? medium,
    String? dimensions,
    bool? availability,
    String? artistId,
    String? artistName,
    Timestamp? createdAt,
  }) {
    return ArtworkModel(
      id: id ?? this.id,
      title: title ?? this.title,
      description: description ?? this.description,
      images: images ?? this.images,
      price: price ?? this.price,
      artStyle: artStyle ?? this.artStyle,
      artType: artType ?? this.artType,
      medium: medium ?? this.medium,
      dimensions: dimensions ?? this.dimensions,
      availability: availability ?? this.availability,
      artistId: artistId ?? this.artistId,
      artistName: artistName ?? this.artistName,
      createdAt: createdAt ?? this.createdAt,
    );
  }
}