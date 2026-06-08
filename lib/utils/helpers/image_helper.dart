import 'dart:typed_data';
import 'package:image_picker/image_picker.dart';

class ImageHelper {
  static final ImagePicker _picker = ImagePicker();

  static Future<XFile?> pickFromGallery() async {
    return _picker.pickImage(source: ImageSource.gallery, maxWidth: 1024, imageQuality: 85);
  }

  static Future<XFile?> pickFromCamera() async {
    return _picker.pickImage(source: ImageSource.camera, maxWidth: 1024, imageQuality: 85);
  }

  static Future<XFile?> pickVideo() async {
    return _picker.pickVideo(source: ImageSource.gallery, maxDuration: const Duration(seconds: 60));
  }

  static Future<Uint8List?> getBytes(XFile file) async {
    return file.readAsBytes();
  }

  static bool isValidImageType(String path) {
    final ext = path.toLowerCase().split('.').last;
    return ['jpg', 'jpeg', 'png', 'webp'].contains(ext);
  }

  static bool isValidVideoType(String path) {
    final ext = path.toLowerCase().split('.').last;
    return ['mp4', 'mov', 'avi'].contains(ext);
  }
}
