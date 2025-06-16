// lib/utils/image_picker_service.dart
abstract class ImagePickerService {
  Future<List<dynamic>> pickImages({int maxImages = 5});
}