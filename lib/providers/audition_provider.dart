import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../services/firestore_service.dart';
import '../models/audition_model.dart';
import 'user_provider.dart';

final auditionsProvider =
    FutureProvider.autoDispose<List<Audition>>((ref) async {
  final filters = ref.watch(auditionFiltersProvider);
  try {
    return await ref.read(firestoreServiceProvider).getAllAuditions(
          category: filters.category,
          location: filters.location,
          searchQuery: filters.searchQuery,
        );
  } catch (e) {
    debugPrint('auditionsProvider error: $e');
    return <Audition>[];
  }
});

final auditionDetailProvider = FutureProvider.autoDispose
    .family<Audition?, String>((ref, id) async {
  return ref.read(firestoreServiceProvider).getAuditionById(id);
});

final recruiterAuditionsProvider = FutureProvider.autoDispose
    .family<List<Audition>, String>((ref, recruiterId) async {
  try {
    return await ref
        .read(firestoreServiceProvider)
        .getRecruiterAuditions(recruiterId);
  } catch (e) {
    debugPrint('recruiterAuditionsProvider error: $e');
    rethrow;
  }
});

class AuditionFilters {
  final String? category;
  final String? location;
  final String? searchQuery;

  const AuditionFilters({this.category, this.location, this.searchQuery});

  AuditionFilters copyWith({
    String? category,
    String? location,
    String? searchQuery,
  }) {
    return AuditionFilters(
      category: category ?? this.category,
      location: location ?? this.location,
      searchQuery: searchQuery ?? this.searchQuery,
    );
  }
}

final auditionFiltersProvider =
    StateProvider<AuditionFilters>((ref) => const AuditionFilters());
