// lib/utils/image_picker_service_mobile.dart
import 'dart:io';
import 'package:image_picker/image_picker.dart';
import 'image_picker_service_interface.dart';

class ImagePickerServiceMobile implements ImagePickerServiceInterface {
  final ImagePicker _picker = ImagePicker();

  @override
  Future<List<dynamic>> pickImages({int maxImages = 1}) async {
    final List<File> images = [];
    
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
          images.add(File(pickedFile.path));
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
          images.add(File(file.path));
        }
      }
    } catch (e) {
      print('Error picking images: $e');
      rethrow;
    }
    
    return images;
  }
}