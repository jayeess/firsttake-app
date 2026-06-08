import 'package:cloud_firestore/cloud_firestore.dart';

import '../models/user_model.dart';
import '../models/talent_profile_model.dart';
import '../models/recruiter_profile_model.dart';
import '../models/audition_model.dart';
import '../models/application_model.dart';

class FirestoreService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // ---------------------------------------------------------------------------
  // Talent Profiles  –  users/{userId}/talentProfiles/default
  // ---------------------------------------------------------------------------

  /// Creates a talent profile document at `users/{userId}/talentProfiles/default`.
  Future<void> createTalentProfile(
    String userId,
    TalentProfile profile,
  ) async {
    try {
      await _firestore
          .collection('users')
          .doc(userId)
          .collection('talentProfiles')
          .doc('default')
          .set(profile.toMap());
    } catch (e) {
      throw Exception('Failed to create talent profile: $e');
    }
  }

  /// Merges the provided [updates] into the talent profile document.
  Future<void> updateTalentProfile(
    String userId,
    Map<String, dynamic> updates,
  ) async {
    try {
      updates['updatedAt'] = Timestamp.fromDate(DateTime.now());
      await _firestore
          .collection('users')
          .doc(userId)
          .collection('talentProfiles')
          .doc('default')
          .update(updates);
    } catch (e) {
      throw Exception('Failed to update talent profile: $e');
    }
  }

  /// Returns the talent profile for [userId], or `null` if it doesn't exist.
  Future<TalentProfile?> getTalentProfile(String userId) async {
    try {
      final doc = await _firestore
          .collection('users')
          .doc(userId)
          .collection('talentProfiles')
          .doc('default')
          .get();

      if (!doc.exists || doc.data() == null) {
        return null;
      }
      return TalentProfile.fromMap(doc.data()!);
    } catch (e) {
      throw Exception('Failed to get talent profile: $e');
    }
  }

  // ---------------------------------------------------------------------------
  // Recruiter Profiles  –  users/{userId}/recruiterProfiles/default
  // ---------------------------------------------------------------------------

  /// Creates a recruiter profile document at `users/{userId}/recruiterProfiles/default`.
  Future<void> createRecruiterProfile(
    String userId,
    RecruiterProfile profile,
  ) async {
    try {
      await _firestore
          .collection('users')
          .doc(userId)
          .collection('recruiterProfiles')
          .doc('default')
          .set(profile.toMap());
    } catch (e) {
      throw Exception('Failed to create recruiter profile: $e');
    }
  }

  /// Merges the provided [updates] into the recruiter profile document.
  Future<void> updateRecruiterProfile(
    String userId,
    Map<String, dynamic> updates,
  ) async {
    try {
      updates['updatedAt'] = Timestamp.fromDate(DateTime.now());
      await _firestore
          .collection('users')
          .doc(userId)
          .collection('recruiterProfiles')
          .doc('default')
          .update(updates);
    } catch (e) {
      throw Exception('Failed to update recruiter profile: $e');
    }
  }

  /// Returns the recruiter profile for [userId], or `null` if it doesn't exist.
  Future<RecruiterProfile?> getRecruiterProfile(String userId) async {
    try {
      final doc = await _firestore
          .collection('users')
          .doc(userId)
          .collection('recruiterProfiles')
          .doc('default')
          .get();

      if (!doc.exists || doc.data() == null) {
        return null;
      }
      return RecruiterProfile.fromMap(doc.data()!);
    } catch (e) {
      throw Exception('Failed to get recruiter profile: $e');
    }
  }

  // ---------------------------------------------------------------------------
  // Auditions  –  auditions/{auditionId}
  // ---------------------------------------------------------------------------

  /// Fetches auditions with optional filters and pagination support.
  Future<List<Audition>> getAllAuditions({
    String? category,
    String? location,
    String? experienceLevel,
    String? searchQuery,
    int limit = 20,
    DocumentSnapshot? startAfterDoc,
  }) async {
    try {
      Query query = _firestore
          .collection('auditions')
          .where('status', isEqualTo: AuditionStatus.ACTIVE.name)
          .orderBy('createdAt', descending: true);

      if (category != null) {
        query = query.where('category', isEqualTo: category);
      }
      if (location != null) {
        query = query.where('location', isEqualTo: location);
      }
      if (experienceLevel != null) {
        query = query.where('experienceLevel', isEqualTo: experienceLevel);
      }

      if (startAfterDoc != null) {
        query = query.startAfterDocument(startAfterDoc);
      }

      query = query.limit(limit);

      final snapshot = await query.get();
      List<Audition> auditions = snapshot.docs
          .map((doc) => Audition.fromMap(doc.data() as Map<String, dynamic>))
          .toList();

      // Client-side title/description search when a search query is provided.
      if (searchQuery != null && searchQuery.isNotEmpty) {
        final lowerQuery = searchQuery.toLowerCase();
        auditions = auditions
            .where((a) =>
                a.title.toLowerCase().contains(lowerQuery) ||
                a.description.toLowerCase().contains(lowerQuery))
            .toList();
      }

      return auditions;
    } catch (e) {
      throw Exception('Failed to get auditions: $e');
    }
  }

  /// Returns a single [Audition] by its document id, or `null` if not found.
  Future<Audition?> getAuditionById(String id) async {
    try {
      final doc = await _firestore.collection('auditions').doc(id).get();
      if (!doc.exists || doc.data() == null) {
        return null;
      }
      return Audition.fromMap(doc.data()!);
    } catch (e) {
      throw Exception('Failed to get audition: $e');
    }
  }

  /// Creates a new audition document and returns the generated document id.
  Future<String> createAudition(Audition audition) async {
    try {
      final docRef = _firestore.collection('auditions').doc();
      final data = audition.toMap();
      data['id'] = docRef.id;
      await docRef.set(data);
      return docRef.id;
    } catch (e) {
      throw Exception('Failed to create audition: $e');
    }
  }

  /// Merges the provided [updates] into the audition document.
  Future<void> updateAudition(
    String id,
    Map<String, dynamic> updates,
  ) async {
    try {
      updates['updatedAt'] = Timestamp.fromDate(DateTime.now());
      await _firestore.collection('auditions').doc(id).update(updates);
    } catch (e) {
      throw Exception('Failed to update audition: $e');
    }
  }

  /// Deletes the audition document with the given [id].
  Future<void> deleteAudition(String id) async {
    try {
      await _firestore.collection('auditions').doc(id).delete();
    } catch (e) {
      throw Exception('Failed to delete audition: $e');
    }
  }

  /// Returns all auditions created by the given [recruiterId].
  Future<List<Audition>> getRecruiterAuditions(String recruiterId) async {
    try {
      final snapshot = await _firestore
          .collection('auditions')
          .where('recruiterId', isEqualTo: recruiterId)
          .orderBy('createdAt', descending: true)
          .get();

      return snapshot.docs
          .map((doc) => Audition.fromMap(doc.data()))
          .toList();
    } catch (e) {
      throw Exception('Failed to get recruiter auditions: $e');
    }
  }

  // ---------------------------------------------------------------------------
  // Applications  –  auditions/{auditionId}/applications/{applicationId}
  // ---------------------------------------------------------------------------

  /// Submits an application under `auditions/{auditionId}/applications` and
  /// increments the parent audition's `applicationCount`. Returns the new
  /// application document id.
  Future<String> submitApplication(Application application) async {
    try {
      final docRef = _firestore
          .collection('auditions')
          .doc(application.auditionId)
          .collection('applications')
          .doc();

      final data = application.toMap();
      data['id'] = docRef.id;

      await _firestore.runTransaction((transaction) async {
        transaction.set(docRef, data);
        transaction.update(
          _firestore.collection('auditions').doc(application.auditionId),
          {'applicantCount': FieldValue.increment(1)},
        );
      });

      return docRef.id;
    } catch (e) {
      throw Exception('Failed to submit application: $e');
    }
  }

  /// Returns all applications submitted by [talentId] across all auditions.
  ///
  /// Uses a collection-group query on the `applications` sub-collection.
  Future<List<Application>> getApplicationsForTalent(String talentId) async {
    try {
      final snapshot = await _firestore
          .collectionGroup('applications')
          .where('talentId', isEqualTo: talentId)
          .orderBy('createdAt', descending: true)
          .get();

      return snapshot.docs
          .map((doc) => Application.fromMap(doc.data()))
          .toList();
    } catch (e) {
      throw Exception('Failed to get applications for talent: $e');
    }
  }

  /// Returns all applications for the given [auditionId].
  Future<List<Application>> getApplicationsForAudition(
    String auditionId,
  ) async {
    try {
      final snapshot = await _firestore
          .collection('auditions')
          .doc(auditionId)
          .collection('applications')
          .orderBy('createdAt', descending: true)
          .get();

      return snapshot.docs
          .map((doc) => Application.fromMap(doc.data()))
          .toList();
    } catch (e) {
      throw Exception('Failed to get applications for audition: $e');
    }
  }

  /// Updates the status of an application. Optionally sets [notes] and
  /// [reason] (e.g. for rejections).
  Future<void> updateApplicationStatus(
    String auditionId,
    String applicationId,
    dynamic status, {
    String? notes,
    String? reason,
  }) async {
    try {
      final statusStr = status is ApplicationStatus ? status.name : status.toString();
      final updates = <String, dynamic>{
        'status': statusStr,
        'lastStatusChange': Timestamp.fromDate(DateTime.now()),
        'updatedAt': Timestamp.fromDate(DateTime.now()),
      };

      if (notes != null) {
        updates['recruiterNotes'] = notes;
      }
      if (reason != null) {
        updates['rejectionReason'] = reason;
      }

      await _firestore
          .collection('auditions')
          .doc(auditionId)
          .collection('applications')
          .doc(applicationId)
          .update(updates);
    } catch (e) {
      throw Exception('Failed to update application status: $e');
    }
  }

  // ---------------------------------------------------------------------------
  // Admin / Recruiter Verification
  // ---------------------------------------------------------------------------

  /// Returns all recruiter users whose recruiter profile has `isVerified == false`.
  Future<List<UserModel>> getPendingRecruiters() async {
    try {
      final usersSnapshot = await _firestore
          .collection('users')
          .where('userType', isEqualTo: UserType.RECRUITER.name)
          .get();

      final pending = <UserModel>[];

      for (final userDoc in usersSnapshot.docs) {
        final profileDoc = await _firestore
            .collection('users')
            .doc(userDoc.id)
            .collection('recruiterProfiles')
            .doc('default')
            .get();

        if (profileDoc.exists) {
          final profileData = profileDoc.data();
          if (profileData != null && profileData['isVerified'] == false) {
            pending.add(UserModel.fromMap(userDoc.data()));
          }
        }
      }

      return pending;
    } catch (e) {
      throw Exception('Failed to get pending recruiters: $e');
    }
  }

  /// Marks a recruiter's profile as verified.
  Future<void> verifyRecruiter(String userId) async {
    try {
      await _firestore
          .collection('users')
          .doc(userId)
          .collection('recruiterProfiles')
          .doc('default')
          .update({
        'isVerified': true,
        'verificationDate': Timestamp.fromDate(DateTime.now()),
        'updatedAt': Timestamp.fromDate(DateTime.now()),
      });
    } catch (e) {
      throw Exception('Failed to verify recruiter: $e');
    }
  }

  // ---------------------------------------------------------------------------
  // User Management (Admin)
  // ---------------------------------------------------------------------------

  /// Returns all users, optionally filtered by [userType].
  Future<List<UserModel>> getAllUsers({UserType? userType}) async {
    try {
      Query query = _firestore.collection('users');
      if (userType != null) {
        query = query.where('userType', isEqualTo: userType.name);
      }

      final snapshot = await query.get();
      return snapshot.docs
          .map((doc) =>
              UserModel.fromMap(doc.data() as Map<String, dynamic>))
          .toList();
    } catch (e) {
      throw Exception('Failed to get all users: $e');
    }
  }

  /// Updates the [AccountStatus] of a user.
  Future<void> updateUserStatus(
    String userId,
    AccountStatus status,
  ) async {
    try {
      await _firestore.collection('users').doc(userId).update({
        'accountStatus': status.name,
        'updatedAt': Timestamp.fromDate(DateTime.now()),
      });
    } catch (e) {
      throw Exception('Failed to update user status: $e');
    }
  }

  // ---------------------------------------------------------------------------
  // Stats
  // ---------------------------------------------------------------------------

  /// Returns a map of aggregate counts useful for an admin dashboard.
  ///
  /// Keys: `totalAuditions`, `activeAuditions`, `closedAuditions`,
  /// `totalUsers`, `totalTalents`, `totalRecruiters`.
  Future<Map<String, int>> getAuditionStats() async {
    try {
      final auditionsSnapshot =
          await _firestore.collection('auditions').get();

      int active = 0;
      int closed = 0;

      for (final doc in auditionsSnapshot.docs) {
        final data = doc.data();
        if (data['status'] == AuditionStatus.ACTIVE.name) {
          active++;
        } else if (data['status'] == AuditionStatus.CLOSED.name) {
          closed++;
        }
      }

      final usersSnapshot = await _firestore.collection('users').get();
      int talents = 0;
      int recruiters = 0;

      for (final doc in usersSnapshot.docs) {
        final data = doc.data();
        if (data['userType'] == UserType.TALENT.name) {
          talents++;
        } else if (data['userType'] == UserType.RECRUITER.name) {
          recruiters++;
        }
      }

      return {
        'totalAuditions': auditionsSnapshot.docs.length,
        'activeAuditions': active,
        'closedAuditions': closed,
        'totalUsers': usersSnapshot.docs.length,
        'totalTalents': talents,
        'totalRecruiters': recruiters,
      };
    } catch (e) {
      throw Exception('Failed to get audition stats: $e');
    }
  }
}
