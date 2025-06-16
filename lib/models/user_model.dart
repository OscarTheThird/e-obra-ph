// models/user_model.dart
class UserModel {
  final String uid;
  final String email;
  final String name;
  final String userType; // 'customer' or 'artist'
  final String? location;
  final String? bio;
  final List<String>? preferences;
  final String? profileImageUrl;
  final DateTime createdAt;
  final DateTime updatedAt;

  UserModel({
    required this.uid,
    required this.email,
    required this.name,
    required this.userType,
    this.location,
    this.bio,
    this.preferences,
    this.profileImageUrl,
    required this.createdAt,
    required this.updatedAt,
  });

  factory UserModel.fromMap(Map<String, dynamic> map) {
    return UserModel(
      uid: map['uid'] ?? '',
      email: map['email'] ?? '',
      name: map['name'] ?? '',
      userType: map['userType'] ?? '',
      location: map['location'],
      bio: map['bio'],
      preferences: List<String>.from(map['preferences'] ?? []),
      profileImageUrl: map['profileImageUrl'],
      createdAt: DateTime.parse(map['createdAt']),
      updatedAt: DateTime.parse(map['updatedAt']),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'uid': uid,
      'email': email,
      'name': name,
      'userType': userType,
      'location': location,
      'bio': bio,
      'preferences': preferences,
      'profileImageUrl': profileImageUrl,
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt.toIso8601String(),
    };
  }
}