import 'dart:typed_data';

class ImagePickerWeb {
  static Future<Uint8List?> pickImage() async {
    // Stub implementation for non-web platforms
    // In a real app, you would use image_picker package here
    throw UnsupportedError('Image picking is only supported on web platform');
  }
}
