import 'package:cloud_firestore/cloud_firestore.dart';

enum FileType { PHOTO, VIDEO }

class MediaFile {
  final String id;
  final String userId;
  final String fileUrl;
  final FileType fileType;
  final String fileName;
  final int fileSize;
  final String? mimeType;
  final bool isPrimary;
  final int displayOrder;
  final DateTime? uploadedAt;
  final DateTime createdAt;

  const MediaFile({
    required this.id,
    required this.userId,
    required this.fileUrl,
    required this.fileType,
    required this.fileName,
    required this.fileSize,
    this.mimeType,
    this.isPrimary = false,
    this.displayOrder = 0,
    this.uploadedAt,
    required this.createdAt,
  });

  factory MediaFile.fromMap(Map<String, dynamic> map) {
    return MediaFile(
      id: map['id'] as String,
      userId: map['userId'] as String,
      fileUrl: map['fileUrl'] as String,
      fileType: FileType.values.firstWhere(
        (e) => e.name == map['fileType'],
      ),
      fileName: map['fileName'] as String,
      fileSize: map['fileSize'] as int,
      mimeType: map['mimeType'] as String?,
      isPrimary: map['isPrimary'] as bool? ?? false,
      displayOrder: map['displayOrder'] as int? ?? 0,
      uploadedAt: map['uploadedAt'] != null
          ? (map['uploadedAt'] as Timestamp).toDate()
          : null,
      createdAt: (map['createdAt'] as Timestamp).toDate(),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'userId': userId,
      'fileUrl': fileUrl,
      'fileType': fileType.name,
      'fileName': fileName,
      'fileSize': fileSize,
      'mimeType': mimeType,
      'isPrimary': isPrimary,
      'displayOrder': displayOrder,
      'uploadedAt':
          uploadedAt != null ? Timestamp.fromDate(uploadedAt!) : null,
      'createdAt': Timestamp.fromDate(createdAt),
    };
  }

  MediaFile copyWith({
    String? id,
    String? userId,
    String? fileUrl,
    FileType? fileType,
    String? fileName,
    int? fileSize,
    String? mimeType,
    bool? isPrimary,
    int? displayOrder,
    DateTime? uploadedAt,
    DateTime? createdAt,
  }) {
    return MediaFile(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      fileUrl: fileUrl ?? this.fileUrl,
      fileType: fileType ?? this.fileType,
      fileName: fileName ?? this.fileName,
      fileSize: fileSize ?? this.fileSize,
      mimeType: mimeType ?? this.mimeType,
      isPrimary: isPrimary ?? this.isPrimary,
      displayOrder: displayOrder ?? this.displayOrder,
      uploadedAt: uploadedAt ?? this.uploadedAt,
      createdAt: createdAt ?? this.createdAt,
    );
  }
}
