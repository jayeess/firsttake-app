import 'package:image_picker/image_picker.dart';

class FilePickerHelper {
  static final ImagePicker _picker = ImagePicker();

  static Future<List<XFile>> pickMultipleImages({int maxCount = 5}) async {
    final images = await _picker.pickMultiImage(maxWidth: 1024, imageQuality: 85);
    if (images.length > maxCount) {
      return images.sublist(0, maxCount);
    }
    return images;
  }

  static Future<XFile?> pickSingleImage() async {
    return _picker.pickImage(source: ImageSource.gallery, maxWidth: 1024, imageQuality: 85);
  }

  static Future<XFile?> pickVideo() async {
    return _picker.pickVideo(
      source: ImageSource.gallery,
      maxDuration: const Duration(seconds: 60),
    );
  }
}
