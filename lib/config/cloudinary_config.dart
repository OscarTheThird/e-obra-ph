// lib/config/cloudinary_config.dart

class CloudinaryConfig {
  // 🔧 CLOUDINARY CONFIGURATION - YOUR ACTUAL VALUES
  static const String cloudName = 'ddkinq4qn';
  static const String apiKey = '646257278314287';
  static const String apiSecret = 'SGmBhLrA8IPcHGyI2O7buaLduQo';
  static const String uploadPreset = 'e_Obra_ph'; // Optional: for unsigned uploads

  // 📁 FOLDER STRUCTURE
  static const String artworkFolder = 'e_Obra_ph/artworks';
  static const String profileFolder = 'e_Obra_ph/profiles';
  static const String eventFolder = 'e_Obra_ph/events';

  // 🌐 BASE URLS
  static String get baseUrl => 'https://api.cloudinary.com/v1_1/$cloudName';
  static String get uploadUrl => '$baseUrl/image/upload';
  static String get deleteUrl => '$baseUrl/image/destroy';

  // 🎨 TRANSFORMATION PRESETS
  static const Map<String, String> artworkTransformations = {
    'thumbnail': 'c_fill,w_200,h_200,g_auto,f_auto,q_auto',
    'display': 'c_limit,w_800,f_auto,q_85',
    'fullsize': 'c_limit,w_1200,f_auto,q_90',
  };

  static const Map<String, String> profileTransformations = {
    'thumbnail': 'c_fill,w_100,h_100,g_face,f_auto,q_auto',
    'display': 'c_fill,w_200,h_200,g_face,f_auto,q_80',
    'large': 'c_fill,w_400,h_400,g_face,f_auto,q_85',
  };

  static const Map<String, int> qualityLevels = {
    'low': 60,
    'medium': 80,
    'high': 90,
    'lossless': 100,
  };
}