import 'dart:typed_data';

import 'package:firebase_storage/firebase_storage.dart';

class StorageService {
  final FirebaseStorage _storage = FirebaseStorage.instance;

  /// Uploads a profile photo to `users/{userId}/profile_photos/{filename}`
  /// and returns the public download URL.
  Future<String> uploadProfilePhoto(
    String userId,
    Uint8List bytes,
    String filename,
  ) async {
    try {
      final ref = _storage.ref('users/$userId/profile_photos/$filename');
      final uploadTask = await ref.putData(
        bytes,
        SettableMetadata(contentType: _contentTypeFromFilename(filename)),
      );
      return await uploadTask.ref.getDownloadURL();
    } catch (e) {
      throw Exception('Failed to upload profile photo: $e');
    }
  }

  /// Uploads an intro video to `users/{userId}/intro_videos/{filename}`
  /// and returns the public download URL.
  Future<String> uploadIntroVideo(
    String userId,
    Uint8List bytes,
    String filename,
  ) async {
    try {
      final ref = _storage.ref('users/$userId/intro_videos/$filename');
      final uploadTask = await ref.putData(
        bytes,
        SettableMetadata(contentType: _contentTypeFromFilename(filename)),
      );
      return await uploadTask.ref.getDownloadURL();
    } catch (e) {
      throw Exception('Failed to upload intro video: $e');
    }
  }

  /// Uploads a company logo to `users/{userId}/company_logos/{filename}`
  /// and returns the public download URL.
  Future<String> uploadCompanyLogo(
    String userId,
    Uint8List bytes,
    String filename,
  ) async {
    try {
      final ref = _storage.ref('users/$userId/company_logos/$filename');
      final uploadTask = await ref.putData(
        bytes,
        SettableMetadata(contentType: _contentTypeFromFilename(filename)),
      );
      return await uploadTask.ref.getDownloadURL();
    } catch (e) {
      throw Exception('Failed to upload company logo: $e');
    }
  }

  /// Uploads a verification document to `users/{userId}/verification_docs/{filename}`
  /// and returns the public download URL.
  Future<String> uploadVerificationDoc(
    String userId,
    Uint8List bytes,
    String filename,
  ) async {
    try {
      final ref = _storage.ref('users/$userId/verification_docs/$filename');
      final uploadTask = await ref.putData(
        bytes,
        SettableMetadata(contentType: _contentTypeFromFilename(filename)),
      );
      return await uploadTask.ref.getDownloadURL();
    } catch (e) {
      throw Exception('Failed to upload verification document: $e');
    }
  }

  /// Deletes a file from Firebase Storage given its download [url].
  Future<void> deleteFile(String url) async {
    try {
      final ref = _storage.refFromURL(url);
      await ref.delete();
    } catch (e) {
      throw Exception('Failed to delete file: $e');
    }
  }

  /// Infers a MIME content-type from the file extension.
  String _contentTypeFromFilename(String filename) {
    final ext = filename.split('.').last.toLowerCase();
    switch (ext) {
      case 'jpg':
      case 'jpeg':
        return 'image/jpeg';
      case 'png':
        return 'image/png';
      case 'gif':
        return 'image/gif';
      case 'webp':
        return 'image/webp';
      case 'mp4':
        return 'video/mp4';
      case 'mov':
        return 'video/quicktime';
      case 'pdf':
        return 'application/pdf';
      default:
        return 'application/octet-stream';
    }
  }
}
