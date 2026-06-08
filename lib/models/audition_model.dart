import 'package:cloud_firestore/cloud_firestore.dart';

enum AuditionStatus { ACTIVE, CLOSED, CANCELLED, DRAFT }

class Audition {
  final String id;
  final String recruiterId;
  final String title;
  final String description;
  final String category;
  final String? experienceLevel;
  final String? location;
  final String? duration;
  final String? requirements;
  final int numberOfPositions;
  final String? payInfo;
  final DateTime? deadline;
  final AuditionStatus status;
  final int applicantCount;
  final DateTime? createdAt;
  final DateTime? updatedAt;
  final DateTime? closedDate;
  final String? recruiterName;
  final String? companyName;

  const Audition({
    required this.id,
    required this.recruiterId,
    required this.title,
    required this.description,
    required this.category,
    this.experienceLevel,
    this.location,
    this.duration,
    this.requirements,
    this.numberOfPositions = 1,
    this.payInfo,
    this.deadline,
    this.status = AuditionStatus.ACTIVE,
    this.applicantCount = 0,
    this.createdAt,
    this.updatedAt,
    this.closedDate,
    this.recruiterName,
    this.companyName,
  });

  factory Audition.fromMap(Map<String, dynamic> map) {
    return Audition(
      id: map['id'] as String? ?? '',
      recruiterId: map['recruiterId'] as String? ?? '',
      title: map['title'] as String? ?? '',
      description: map['description'] as String? ?? '',
      category: map['category'] as String? ?? '',
      experienceLevel: map['experienceLevel'] as String?,
      location: map['location'] as String?,
      duration: map['duration'] as String?,
      requirements: map['requirements'] as String?,
      numberOfPositions: map['numberOfPositions'] as int? ?? 1,
      payInfo: map['payInfo'] as String?,
      deadline: map['deadline'] != null ? (map['deadline'] as Timestamp).toDate() : null,
      status: AuditionStatus.values.firstWhere(
        (e) => e.name == map['status'],
        orElse: () => AuditionStatus.ACTIVE,
      ),
      applicantCount: map['applicantCount'] as int? ?? 0,
      createdAt: map['createdAt'] != null ? (map['createdAt'] as Timestamp).toDate() : null,
      updatedAt: map['updatedAt'] != null ? (map['updatedAt'] as Timestamp).toDate() : null,
      closedDate: map['closedDate'] != null ? (map['closedDate'] as Timestamp).toDate() : null,
      recruiterName: map['recruiterName'] as String?,
      companyName: map['companyName'] as String?,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'recruiterId': recruiterId,
      'title': title,
      'description': description,
      'category': category,
      'experienceLevel': experienceLevel,
      'location': location,
      'duration': duration,
      'requirements': requirements,
      'numberOfPositions': numberOfPositions,
      'payInfo': payInfo,
      'deadline': deadline != null ? Timestamp.fromDate(deadline!) : null,
      'status': status.name,
      'applicantCount': applicantCount,
      'createdAt': createdAt != null ? Timestamp.fromDate(createdAt!) : null,
      'updatedAt': updatedAt != null ? Timestamp.fromDate(updatedAt!) : null,
      'closedDate': closedDate != null ? Timestamp.fromDate(closedDate!) : null,
      'recruiterName': recruiterName,
      'companyName': companyName,
    };
  }

  Audition copyWith({
    String? id,
    String? recruiterId,
    String? title,
    String? description,
    String? category,
    String? experienceLevel,
    String? location,
    String? duration,
    String? requirements,
    int? numberOfPositions,
    String? payInfo,
    DateTime? deadline,
    AuditionStatus? status,
    int? applicantCount,
    DateTime? createdAt,
    DateTime? updatedAt,
    DateTime? closedDate,
    String? recruiterName,
    String? companyName,
  }) {
    return Audition(
      id: id ?? this.id,
      recruiterId: recruiterId ?? this.recruiterId,
      title: title ?? this.title,
      description: description ?? this.description,
      category: category ?? this.category,
      experienceLevel: experienceLevel ?? this.experienceLevel,
      location: location ?? this.location,
      duration: duration ?? this.duration,
      requirements: requirements ?? this.requirements,
      numberOfPositions: numberOfPositions ?? this.numberOfPositions,
      payInfo: payInfo ?? this.payInfo,
      deadline: deadline ?? this.deadline,
      status: status ?? this.status,
      applicantCount: applicantCount ?? this.applicantCount,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      closedDate: closedDate ?? this.closedDate,
      recruiterName: recruiterName ?? this.recruiterName,
      companyName: companyName ?? this.companyName,
    );
  }
}
