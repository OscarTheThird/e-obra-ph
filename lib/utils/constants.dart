import 'package:flutter/material.dart';

class AppConstants {
  static const String appName = 'ArtMatch';
  static const String appVersion = '1.0.0';
  
  // Colors
  static const Color primaryColor = Colors.deepPurple;
  static const Color secondaryColor = Colors.deepPurpleAccent;
  static const Color backgroundColor = Color(0xFFF5F5F5);
  static const Color cardColor = Colors.white;
  static const Color textPrimaryColor = Color(0xFF212121);
  static const Color textSecondaryColor = Color(0xFF757575);
  static const Color errorColor = Colors.red;
  static const Color successColor = Colors.green;
  
  // Art Types
  static const List<String> artTypes = [
    'Painting',
    'Pottery',
    'Sculpture',
    'Digital Art',
    'Photography',
    'Drawing',
    'Mixed Media',
    'Jewelry',
    'Textile Art',
    'Glass Art',
    'Printmaking',
    'Calligraphy',
  ];

  // Art Styles
  static const List<String> artStyles = [
    'Abstract',
    'Realistic',
    'Contemporary',
    'Traditional',
    'Modern',
    'Impressionist',
    'Expressionist',
    'Minimalist',
    'Pop Art',
    'Street Art',
    'Surrealist',
    'Conceptual',
    'Folk Art',
  ];

  // Price Ranges
  static const Map<String, RangeValues> priceRanges = {
    'Budget': RangeValues(0, 100),
    'Affordable': RangeValues(100, 500),
    'Mid-range': RangeValues(500, 1500),
    'Premium': RangeValues(1500, 5000),
    'Luxury': RangeValues(5000, 50000),
  };

  // Default Values
  static const double defaultMinPrice = 0;
  static const double defaultMaxPrice = 10000;
  static const int maxImagesPerPost = 5;
  static const int maxMessageLength = 500;
  static const int maxBioLength = 300;
  static const int maxTitleLength = 100;
  static const int maxDescriptionLength = 1000;

  // Animation Durations
  static const Duration shortAnimation = Duration(milliseconds: 200);
  static const Duration mediumAnimation = Duration(milliseconds: 300);
  static const Duration longAnimation = Duration(milliseconds: 500);

  // Spacing
  static const double smallSpacing = 8.0;
  static const double mediumSpacing = 16.0;
  static const double largeSpacing = 24.0;
  static const double extraLargeSpacing = 32.0;

  // Border Radius
  static const double smallBorderRadius = 4.0;
  static const double mediumBorderRadius = 8.0;
  static const double largeBorderRadius = 16.0;
  static const double circularBorderRadius = 50.0;

  // Image Dimensions
  static const double thumbnailSize = 80.0;
  static const double profileImageSize = 120.0;
  static const double artworkCardAspectRatio = 0.8;
  static const double artworkDetailAspectRatio = 1.2;
}