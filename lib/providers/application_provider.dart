import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../services/firestore_service.dart';
import '../models/application_model.dart';
import 'user_provider.dart';

final talentApplicationsProvider = FutureProvider.autoDispose
    .family<List<Application>, String>((ref, talentId) async {
  return ref.read(firestoreServiceProvider).getApplicationsForTalent(talentId);
});

final auditionApplicationsProvider = FutureProvider.autoDispose
    .family<List<Application>, String>((ref, auditionId) async {
  return ref
      .read(firestoreServiceProvider)
      .getApplicationsForAudition(auditionId);
});
