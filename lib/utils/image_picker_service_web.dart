// lib/utils/image_picker_service_web.dart
import 'dart:typed_data';
import 'package:image_picker/image_picker.dart';
import 'image_picker_service_interface.dart';

// Factory function for conditional imports
ImagePickerServiceInterface createImagePickerService() {
  return ImagePickerServiceWeb();
}

class ImagePickerServiceWeb implements ImagePickerServiceInterface {
  final ImagePicker _picker = ImagePicker();

  @override
  Future<List<dynamic>> pickImages({int maxImages = 1}) async {
    final List<Uint8List> images = [];
    
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
          final Uint8List bytes = await pickedFile.readAsBytes();
          images.add(bytes);
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
        
        for (final XFile file in limitedFiles) {
          final Uint8List bytes = await file.readAsBytes();
          images.add(bytes);
        }
      }
    } catch (e) {
      print('Error picking images: $e');
      rethrow;
    }
    
    return images;
  }
}