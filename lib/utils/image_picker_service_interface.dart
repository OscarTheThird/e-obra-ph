// lib/utils/image_picker_service_interface.dart
import 'dart:typed_data';
import 'dart:io';

abstract class ImagePickerServiceInterface {
  Future<List<dynamic>> pickImages({int maxImages = 1});
}