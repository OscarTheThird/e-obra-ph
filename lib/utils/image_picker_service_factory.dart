// lib/utils/image_picker_service_factory.dart
import 'dart:typed_data';
import 'dart:io';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:image_picker/image_picker.dart';

// Simple interface
abstract class ImagePickerServiceInterface {
  Future<List<dynamic>> pickImages({int maxImages = 1});
}

// Combined implementation
class ImagePickerService implements ImagePickerServiceInterface {
  final ImagePicker _picker = ImagePicker();

  @override
  Future<List<dynamic>> pickImages({int maxImages = 1}) async {
    try {
      if (maxImages == 1) {
        // Pick single image
        final XFile? pickedFile = await _picker.pickImage(
          source: ImageSource.gallery,
          imageQuality: 80,
          maxWidth: 1920,
          maxHeight: 1920,
        );
        
        if (pickedFile != null) {
          if (kIsWeb) {
            final Uint8List bytes = await pickedFile.readAsBytes();
            return [bytes];
          } else {
            return [File(pickedFile.path)];
          }
        }
      } else {
        // Pick multiple images
        final List<XFile> pickedFiles = await _picker.pickMultiImage(
          imageQuality: 80,
          maxWidth: 1920,
          maxHeight: 1920,
        );
        
        // Limit to maxImages
        final limitedFiles = pickedFiles.take(maxImages).toList();
        final List<dynamic> images = [];
        
        for (final XFile file in limitedFiles) {
          if (kIsWeb) {
            final Uint8List bytes = await file.readAsBytes();
            images.add(bytes);
          } else {
            images.add(File(file.path));
          }
        }
        
        return images;
      }
    } catch (e) {
      print('Error picking images: $e');
      rethrow;
    }
    
    return [];
  }
}

// Factory function
ImagePickerServiceInterface createImagePickerService() {
  return ImagePickerService();
}