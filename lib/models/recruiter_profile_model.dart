import 'package:cloud_firestore/cloud_firestore.dart';

class RecruiterProfile {
  final String id;
  final String userId;
  final String companyName;
  final String? companyLogo;
  final String? bio;
  final String? phone;
  final String? address;
  final String? website;
  final bool isVerified;
  final DateTime? verificationDate;
  final List<String> verificationDocuments;
  final DateTime createdAt;
  final DateTime updatedAt;

  const RecruiterProfile({
    required this.id,
    required this.userId,
    required this.companyName,
    this.companyLogo,
    this.bio,
    this.phone,
    this.address,
    this.website,
    this.isVerified = false,
    this.verificationDate,
    this.verificationDocuments = const [],
    required this.createdAt,
    required this.updatedAt,
  });

  factory RecruiterProfile.fromMap(Map<String, dynamic> map) {
    return RecruiterProfile(
      id: map['id'] as String,
      userId: map['userId'] as String,
      companyName: map['companyName'] as String,
      companyLogo: map['companyLogo'] as String?,
      bio: map['bio'] as String?,
      phone: map['phone'] as String?,
      address: map['address'] as String?,
      website: map['website'] as String?,
      isVerified: map['isVerified'] as bool? ?? false,
      verificationDate: map['verificationDate'] != null
          ? (map['verificationDate'] as Timestamp).toDate()
          : null,
      verificationDocuments: map['verificationDocuments'] != null
          ? List<String>.from(map['verificationDocuments'] as List)
          : const [],
      createdAt: (map['createdAt'] as Timestamp).toDate(),
      updatedAt: (map['updatedAt'] as Timestamp).toDate(),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'userId': userId,
      'companyName': companyName,
      'companyLogo': companyLogo,
      'bio': bio,
      'phone': phone,
      'address': address,
      'website': website,
      'isVerified': isVerified,
      'verificationDate': verificationDate != null
          ? Timestamp.fromDate(verificationDate!)
          : null,
      'verificationDocuments': verificationDocuments,
      'createdAt': Timestamp.fromDate(createdAt),
      'updatedAt': Timestamp.fromDate(updatedAt),
    };
  }

  RecruiterProfile copyWith({
    String? id,
    String? userId,
    String? companyName,
    String? companyLogo,
    String? bio,
    String? phone,
    String? address,
    String? website,
    bool? isVerified,
    DateTime? verificationDate,
    List<String>? verificationDocuments,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return RecruiterProfile(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      companyName: companyName ?? this.companyName,
      companyLogo: companyLogo ?? this.companyLogo,
      bio: bio ?? this.bio,
      phone: phone ?? this.phone,
      address: address ?? this.address,
      website: website ?? this.website,
      isVerified: isVerified ?? this.isVerified,
      verificationDate: verificationDate ?? this.verificationDate,
      verificationDocuments:
          verificationDocuments ?? this.verificationDocuments,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }
}
