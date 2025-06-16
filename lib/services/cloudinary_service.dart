// services/cloudinary_service.dart - Simple signed uploads (full control)

import 'dart:io';
import 'dart:convert';
import 'dart:typed_data';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import 'package:crypto/crypto.dart';
import '../config/cloudinary_config.dart';

class CloudinaryService {
  // 🔧 CONFIGURATION FROM CLOUDINARY_CONFIG.DART
  static String get _cloudName => CloudinaryConfig.cloudName;
  static String get _apiKey => CloudinaryConfig.apiKey;
  static String get _apiSecret => CloudinaryConfig.apiSecret;

  // 📁 FOLDER STRUCTURE FROM CONFIG
  static String get _artworkFolder => CloudinaryConfig.artworkFolder;
  static String get _profileFolder => CloudinaryConfig.profileFolder;
  static String get _eventFolder => CloudinaryConfig.eventFolder;

  // 🌐 BASE URLS FROM CONFIG
  static String get _uploadUrl => CloudinaryConfig.uploadUrl;
  static String get _deleteUrl => CloudinaryConfig.deleteUrl;

  // 📱 SIGNED IMAGE UPLOAD (Simple and reliable)
  static Future<CloudinaryResponse> uploadImageSigned({
    required dynamic imageFile,
    required String folder,
    String? publicId,
  }) async {
    try {
      Uint8List bytes;
      
      if (imageFile is File) {
        bytes = await imageFile.readAsBytes();
      } else if (imageFile is Uint8List) {
        bytes = imageFile;
      } else {
        throw Exception('Invalid image file type');
      }

      final base64Image = base64Encode(bytes);

      return await _uploadSignedToCloudinary(
        base64Image: base64Image,
        folder: folder,
        publicId: publicId,
      );
    } catch (e) {
      return CloudinaryResponse(
        success: false,
        error: 'Failed to upload image: $e',
      );
    }
  }

  // 🎨 ARTWORK IMAGE UPLOAD (Signed)
  static Future<CloudinaryResponse> uploadArtworkImage({
    required dynamic imageFile,
    required String artistId,
    String? artworkId,
  }) async {
    // Let Cloudinary auto-generate public_id to avoid issues
    return await uploadImageSigned(
      imageFile: imageFile,
      folder: _artworkFolder,
      publicId: null, // Auto-generate
    );
  }

  // 📱 UPLOAD FROM BYTES (For web compatibility)
  static Future<CloudinaryResponse> uploadArtworkImageFromBytes({
    required Uint8List imageBytes,
    required String fileName,
    required String artistId,
    String? artworkId,
  }) async {
    // Let Cloudinary auto-generate public_id to avoid issues
    return await uploadImageSigned(
      imageFile: imageBytes,
      folder: _artworkFolder,
      publicId: null, // Auto-generate
    );
  }

  // 👤 PROFILE IMAGE UPLOAD (Signed)
  static Future<CloudinaryResponse> uploadProfileImage({
    required dynamic imageFile,
    required String userId,
  }) async {
    return await uploadImageSigned(
      imageFile: imageFile,
      folder: _profileFolder,
      publicId: null, // Auto-generate
    );
  }

  // 🎭 EVENT IMAGE UPLOAD (Signed)
  static Future<CloudinaryResponse> uploadEventImage({
    required dynamic imageFile,
    required String eventId,
  }) async {
    return await uploadImageSigned(
      imageFile: imageFile,
      folder: _eventFolder,
      publicId: null, // Auto-generate
    );
  }

  // 🔄 TRANSFORM IMAGE URL
  static String getTransformedImageUrl({
    required String publicId,
    int? width,
    int? height,
    int? quality,
    String? format,
    String? cropMode,
    String? gravity,
  }) {
    final transformations = <String>[];

    if (width != null) transformations.add('w_$width');
    if (height != null) transformations.add('h_$height');
    if (quality != null) transformations.add('q_$quality');
    if (format != null) transformations.add('f_$format');
    if (cropMode != null) transformations.add('c_$cropMode');
    if (gravity != null) transformations.add('g_$gravity');

    final transformationString = transformations.isEmpty 
        ? '' 
        : '${transformations.join(',')}/';

    return 'https://res.cloudinary.com/$_cloudName/image/upload/$transformationString$publicId';
  }

  // 🖼️ GET THUMBNAIL URL
  static String getThumbnailUrl(String publicId, {int size = 150}) {
    return getTransformedImageUrl(
      publicId: publicId,
      width: size,
      height: size,
      cropMode: 'fill',
      gravity: 'auto',
      quality: 80,
      format: 'auto',
    );
  }

  // 🎨 GET ARTWORK DISPLAY URL
  static String getArtworkDisplayUrl(String publicId, {int maxWidth = 800}) {
    return getTransformedImageUrl(
      publicId: publicId,
      width: maxWidth,
      cropMode: 'limit',
      quality: 85,
      format: 'auto',
    );
  }

  // 👤 GET PROFILE IMAGE URL
  static String getProfileImageUrl(String publicId, {int size = 200}) {
    return getTransformedImageUrl(
      publicId: publicId,
      width: size,
      height: size,
      cropMode: 'fill',
      gravity: 'face',
      quality: 80,
      format: 'auto',
    );
  }

  // 🔐 PRIVATE METHODS

  // Simple signed upload method
  static Future<CloudinaryResponse> _uploadSignedToCloudinary({
    required String base64Image,
    required String folder,
    String? publicId,
  }) async {
    try {
      final timestamp = DateTime.now().millisecondsSinceEpoch.toString();
      
      // Build parameters for signature (only include what we're sending)
      final Map<String, String> signatureParams = {
        'timestamp': timestamp,
      };

      // Only include folder if it's not empty
      if (folder.isNotEmpty) {
        signatureParams['folder'] = folder;
      }

      // Only include public_id if provided
      if (publicId != null && publicId.isNotEmpty) {
        signatureParams['public_id'] = publicId;
      }

      // Generate signature
      final signature = _generateSignature(signatureParams);

      // Build upload parameters (include all params for upload)
      final Map<String, String> uploadParams = {
        'file': 'data:image/jpeg;base64,$base64Image',
        'timestamp': timestamp,
        'api_key': _apiKey,
        'signature': signature,
      };

      // Add the same params used in signature
      if (folder.isNotEmpty) {
        uploadParams['folder'] = folder;
      }
      if (publicId != null && publicId.isNotEmpty) {
        uploadParams['public_id'] = publicId;
      }

      print('🔄 Uploading to Cloudinary (Signed)...');
      print('📁 Folder: $folder');
      print('⏰ Timestamp: $timestamp');
      print('🔐 Signature: $signature');
      print('📋 Signature params: ${signatureParams.toString()}');

      final response = await http.post(
        Uri.parse(_uploadUrl),
        body: uploadParams,
      );

      print('📊 Response Status: ${response.statusCode}');
      print('📄 Response Body: ${response.body}');

      if (response.statusCode == 200) {
        final responseData = json.decode(response.body);
        
        if (responseData['secure_url'] != null) {
          print('✅ Signed upload successful!');
          return CloudinaryResponse(
            success: true,
            publicId: responseData['public_id'],
            secureUrl: responseData['secure_url'],
            url: responseData['url'],
            width: responseData['width'],
            height: responseData['height'],
            format: responseData['format'],
            bytes: responseData['bytes'],
            message: 'Image uploaded successfully',
          );
        }
      }

      // Handle error response
      final responseData = json.decode(response.body);
      print('❌ Signed upload failed');
      return CloudinaryResponse(
        success: false,
        error: 'Upload failed: ${responseData['error']?['message'] ?? responseData['error'] ?? 'HTTP ${response.statusCode}'}',
      );
    } catch (e) {
      print('❌ Exception during signed upload: $e');
      return CloudinaryResponse(
        success: false,
        error: 'Upload failed: $e',
      );
    }
  }

  // 🗑️ DELETE IMAGE
  static Future<CloudinaryResponse> deleteImage(String publicId) async {
    try {
      final timestamp = DateTime.now().millisecondsSinceEpoch.toString();
      final signature = _generateSignature({
        'public_id': publicId,
        'timestamp': timestamp,
      });

      final response = await http.post(
        Uri.parse(_deleteUrl),
        body: {
          'public_id': publicId,
          'timestamp': timestamp,
          'api_key': _apiKey,
          'signature': signature,
        },
      );

      final responseData = json.decode(response.body);

      if (response.statusCode == 200 && responseData['result'] == 'ok') {
        return CloudinaryResponse(
          success: true,
          publicId: publicId,
          message: 'Image deleted successfully',
        );
      } else {
        return CloudinaryResponse(
          success: false,
          error: 'Failed to delete image: ${responseData['error'] ?? 'Unknown error'}',
        );
      }
    } catch (e) {
      return CloudinaryResponse(
        success: false,
        error: 'Failed to delete image: $e',
      );
    }
  }

  // 🔐 GENERATE SIGNATURE
  static String _generateSignature(Map<String, String> params) {
    // Sort parameters alphabetically
    final sortedKeys = params.keys.toList()..sort();
    
    // Create signature string
    final signatureString = sortedKeys
        .map((key) => '$key=${params[key]}')
        .join('&');

    // Add API secret
    final stringToSign = '$signatureString$_apiSecret';

    print('🔐 String to sign: $stringToSign');

    // Generate SHA1 hash
    final bytes = utf8.encode(stringToSign);
    final digest = sha1.convert(bytes);

    return digest.toString();
  }
}

// 📊 CLOUDINARY RESPONSE MODEL
class CloudinaryResponse {
  final bool success;
  final String? publicId;
  final String? secureUrl;
  final String? url;
  final int? width;
  final int? height;
  final String? format;
  final int? bytes;
  final String? error;
  final String? message;

  CloudinaryResponse({
    required this.success,
    this.publicId,
    this.secureUrl,
    this.url,
    this.width,
    this.height,
    this.format,
    this.bytes,
    this.error,
    this.message,
  });

  @override
  String toString() {
    if (success) {
      return 'CloudinaryResponse(success: $success, publicId: $publicId, url: $secureUrl)';
    } else {
      return 'CloudinaryResponse(success: $success, error: $error)';
    }
  }
}

// 🎯 CLOUDINARY HELPER UTILITIES
class CloudinaryUtils {
  static String? extractPublicId(String cloudinaryUrl) {
    try {
      final uri = Uri.parse(cloudinaryUrl);
      final segments = uri.pathSegments;
      
      final uploadIndex = segments.indexOf('upload');
      if (uploadIndex == -1 || uploadIndex >= segments.length - 1) {
        return null;
      }

      final publicIdSegments = segments.skip(uploadIndex + 1).toList();
      
      final lastSegment = publicIdSegments.last;
      final dotIndex = lastSegment.lastIndexOf('.');
      if (dotIndex != -1) {
        publicIdSegments[publicIdSegments.length - 1] = 
            lastSegment.substring(0, dotIndex);
      }

      return publicIdSegments.join('/');
    } catch (e) {
      print('Error extracting public ID: $e');
      return null;
    }
  }

  static bool isCloudinaryUrl(String url) {
    return url.contains('cloudinary.com') || url.contains('res.cloudinary.com');
  }

  static String optimizeForUseCase(String publicId, ImageUseCase useCase) {
    switch (useCase) {
      case ImageUseCase.thumbnail:
        return CloudinaryService.getThumbnailUrl(publicId);
      case ImageUseCase.artworkDisplay:
        return CloudinaryService.getArtworkDisplayUrl(publicId);
      case ImageUseCase.profileImage:
        return CloudinaryService.getProfileImageUrl(publicId);
      case ImageUseCase.fullSize:
        return CloudinaryService.getTransformedImageUrl(
          publicId: publicId,
          quality: 90,
          format: 'auto',
        );
    }
  }
}

enum ImageUseCase {
  thumbnail,
  artworkDisplay,
  profileImage,
  fullSize,
}