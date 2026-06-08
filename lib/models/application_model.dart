import 'package:cloud_firestore/cloud_firestore.dart';

enum ApplicationStatus { APPLIED, VIEWED, SHORTLISTED, REJECTED }

class Application {
  final String id;
  final String auditionId;
  final String talentId;
  final String? coverMessage;
  final String status;
  final DateTime? lastStatusChange;
  final String? recruiterNotes;
  final String? rejectionReason;
  final DateTime? createdAt;
  final DateTime? updatedAt;
  final String? talentName;
  final String? talentCategory;
  final String? talentPhotoUrl;
  final String? auditionTitle;

  const Application({
    required this.id,
    required this.auditionId,
    required this.talentId,
    this.coverMessage,
    this.status = 'APPLIED',
    this.lastStatusChange,
    this.recruiterNotes,
    this.rejectionReason,
    this.createdAt,
    this.updatedAt,
    this.talentName,
    this.talentCategory,
    this.talentPhotoUrl,
    this.auditionTitle,
  });

  factory Application.fromMap(Map<String, dynamic> map) {
    return Application(
      id: map['id'] as String? ?? '',
      auditionId: map['auditionId'] as String? ?? '',
      talentId: map['talentId'] as String? ?? '',
      coverMessage: map['coverMessage'] as String?,
      status: map['status'] as String? ?? 'APPLIED',
      lastStatusChange: map['lastStatusChange'] != null
          ? (map['lastStatusChange'] as Timestamp).toDate()
          : null,
      recruiterNotes: map['recruiterNotes'] as String?,
      rejectionReason: map['rejectionReason'] as String?,
      createdAt: map['createdAt'] != null ? (map['createdAt'] as Timestamp).toDate() : null,
      updatedAt: map['updatedAt'] != null ? (map['updatedAt'] as Timestamp).toDate() : null,
      talentName: map['talentName'] as String?,
      talentCategory: map['talentCategory'] as String?,
      talentPhotoUrl: map['talentPhotoUrl'] as String?,
      auditionTitle: map['auditionTitle'] as String?,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'auditionId': auditionId,
      'talentId': talentId,
      'coverMessage': coverMessage,
      'status': status,
      'lastStatusChange': lastStatusChange != null ? Timestamp.fromDate(lastStatusChange!) : null,
      'recruiterNotes': recruiterNotes,
      'rejectionReason': rejectionReason,
      'createdAt': createdAt != null ? Timestamp.fromDate(createdAt!) : null,
      'updatedAt': updatedAt != null ? Timestamp.fromDate(updatedAt!) : null,
      'talentName': talentName,
      'talentCategory': talentCategory,
      'talentPhotoUrl': talentPhotoUrl,
      'auditionTitle': auditionTitle,
    };
  }

  Application copyWith({
    String? id,
    String? auditionId,
    String? talentId,
    String? coverMessage,
    String? status,
    DateTime? lastStatusChange,
    String? recruiterNotes,
    String? rejectionReason,
    DateTime? createdAt,
    DateTime? updatedAt,
    String? talentName,
    String? talentCategory,
    String? talentPhotoUrl,
    String? auditionTitle,
  }) {
    return Application(
      id: id ?? this.id,
      auditionId: auditionId ?? this.auditionId,
      talentId: talentId ?? this.talentId,
      coverMessage: coverMessage ?? this.coverMessage,
      status: status ?? this.status,
      lastStatusChange: lastStatusChange ?? this.lastStatusChange,
      recruiterNotes: recruiterNotes ?? this.recruiterNotes,
      rejectionReason: rejectionReason ?? this.rejectionReason,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      talentName: talentName ?? this.talentName,
      talentCategory: talentCategory ?? this.talentCategory,
      talentPhotoUrl: talentPhotoUrl ?? this.talentPhotoUrl,
      auditionTitle: auditionTitle ?? this.auditionTitle,
    );
  }
}
