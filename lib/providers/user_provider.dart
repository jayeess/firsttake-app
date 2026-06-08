import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../services/firestore_service.dart';
import '../models/talent_profile_model.dart';
import '../models/recruiter_profile_model.dart';

final firestoreServiceProvider =
    Provider<FirestoreService>((ref) => FirestoreService());

final talentProfileProvider = FutureProvider.autoDispose
    .family<TalentProfile?, String>((ref, userId) async {
  return ref.read(firestoreServiceProvider).getTalentProfile(userId);
});

final recruiterProfileProvider = FutureProvider.autoDispose
    .family<RecruiterProfile?, String>((ref, userId) async {
  return ref.read(firestoreServiceProvider).getRecruiterProfile(userId);
});
