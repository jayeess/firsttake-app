import 'package:cloud_firestore/cloud_firestore.dart';

enum Gender { MALE, FEMALE, OTHER }

enum TalentCategory { ACTOR, MODEL, DANCER, VOICE_ARTIST, ANCHOR }

enum ExperienceLevel { FRESHER, ONE_3_YRS, THREE_5_YRS, FIVE_PLUS_YRS }

/// Maps [ExperienceLevel] to its Firestore string representation.
const experienceLevelToString = {
  ExperienceLevel.FRESHER: 'FRESHER',
  ExperienceLevel.ONE_3_YRS: '1_3_YRS',
  ExperienceLevel.THREE_5_YRS: '3_5_YRS',
  ExperienceLevel.FIVE_PLUS_YRS: '5_PLUS_YRS',
};

/// Maps Firestore string representation to [ExperienceLevel].
const stringToExperienceLevel = {
  'FRESHER': ExperienceLevel.FRESHER,
  '1_3_YRS': ExperienceLevel.ONE_3_YRS,
  '3_5_YRS': ExperienceLevel.THREE_5_YRS,
  '5_PLUS_YRS': ExperienceLevel.FIVE_PLUS_YRS,
};

class TalentProfile {
  final String id;
  final String userId;
  final String firstName;
  final String lastName;
  final int? age;
  final Gender? gender;
  final double? height;
  final String? bio;
  final TalentCategory category;
  final ExperienceLevel experienceLevel;
  final String? location;
  final String? instagramUrl;
  final String? youtubeUrl;
  final String? websiteUrl;
  final bool isPublic;
  final String? profilePhotoUrl;
  final DateTime createdAt;
  final DateTime updatedAt;

  const TalentProfile({
    required this.id,
    required this.userId,
    required this.firstName,
    required this.lastName,
    this.age,
    this.gender,
    this.height,
    this.bio,
    required this.category,
    required this.experienceLevel,
    this.location,
    this.instagramUrl,
    this.youtubeUrl,
    this.websiteUrl,
    this.isPublic = true,
    this.profilePhotoUrl,
    required this.createdAt,
    required this.updatedAt,
  });

  factory TalentProfile.fromMap(Map<String, dynamic> map) {
    return TalentProfile(
      id: map['id'] as String,
      userId: map['userId'] as String,
      firstName: map['firstName'] as String,
      lastName: map['lastName'] as String,
      age: map['age'] as int?,
      gender: map['gender'] != null
          ? Gender.values.firstWhere((e) => e.name == map['gender'])
          : null,
      height: (map['height'] as num?)?.toDouble(),
      bio: map['bio'] as String?,
      category: TalentCategory.values.firstWhere(
        (e) => e.name == map['category'],
      ),
      experienceLevel: stringToExperienceLevel[map['experienceLevel']]!,
      location: map['location'] as String?,
      instagramUrl: map['instagramUrl'] as String?,
      youtubeUrl: map['youtubeUrl'] as String?,
      websiteUrl: map['websiteUrl'] as String?,
      isPublic: map['isPublic'] as bool? ?? true,
      profilePhotoUrl: map['profilePhotoUrl'] as String?,
      createdAt: (map['createdAt'] as Timestamp).toDate(),
      updatedAt: (map['updatedAt'] as Timestamp).toDate(),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'userId': userId,
      'firstName': firstName,
      'lastName': lastName,
      'age': age,
      'gender': gender?.name,
      'height': height,
      'bio': bio,
      'category': category.name,
      'experienceLevel': experienceLevelToString[experienceLevel],
      'location': location,
      'instagramUrl': instagramUrl,
      'youtubeUrl': youtubeUrl,
      'websiteUrl': websiteUrl,
      'isPublic': isPublic,
      'profilePhotoUrl': profilePhotoUrl,
      'createdAt': Timestamp.fromDate(createdAt),
      'updatedAt': Timestamp.fromDate(updatedAt),
    };
  }

  TalentProfile copyWith({
    String? id,
    String? userId,
    String? firstName,
    String? lastName,
    int? age,
    Gender? gender,
    double? height,
    String? bio,
    TalentCategory? category,
    ExperienceLevel? experienceLevel,
    String? location,
    String? instagramUrl,
    String? youtubeUrl,
    String? websiteUrl,
    bool? isPublic,
    String? profilePhotoUrl,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return TalentProfile(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      firstName: firstName ?? this.firstName,
      lastName: lastName ?? this.lastName,
      age: age ?? this.age,
      gender: gender ?? this.gender,
      height: height ?? this.height,
      bio: bio ?? this.bio,
      category: category ?? this.category,
      experienceLevel: experienceLevel ?? this.experienceLevel,
      location: location ?? this.location,
      instagramUrl: instagramUrl ?? this.instagramUrl,
      youtubeUrl: youtubeUrl ?? this.youtubeUrl,
      websiteUrl: websiteUrl ?? this.websiteUrl,
      isPublic: isPublic ?? this.isPublic,
      profilePhotoUrl: profilePhotoUrl ?? this.profilePhotoUrl,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }
}
