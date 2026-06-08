import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../models/audition_model.dart';
import '../../models/talent_profile_model.dart';
import '../../providers/audition_provider.dart';
import '../../routing/route_names.dart';
import '../../utils/theme/app_colors.dart';
import '../../utils/extensions/string_extensions.dart';
import '../../utils/extensions/date_extensions.dart';
import '../../widgets/talent/audition_card.dart';
import '../../widgets/common/loading_indicator.dart';

class AuditionListScreen extends ConsumerWidget {
  const AuditionListScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final auditionsAsync = ref.watch(auditionsProvider);
    final filters = ref.watch(auditionFiltersProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Browse Auditions'),
        backgroundColor: AppColors.primary,
        foregroundColor: Colors.white,
        automaticallyImplyLeading: false,
        elevation: 0,
      ),
      body: Column(
        children: [
          // Search bar
          Container(
            color: AppColors.primary,
            padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
            child: TextField(
              decoration: InputDecoration(
                hintText: 'Search auditions...',
                hintStyle: const TextStyle(color: AppColors.textHint),
                prefixIcon:
                    const Icon(Icons.search, color: AppColors.textSecondary),
                suffixIcon: filters.searchQuery != null &&
                        filters.searchQuery!.isNotEmpty
                    ? IconButton(
                        icon: const Icon(Icons.clear,
                            color: AppColors.textSecondary),
                        onPressed: () {
                          ref.read(auditionFiltersProvider.notifier).state =
                              filters.copyWith(searchQuery: '');
                        },
                      )
                    : null,
                filled: true,
                fillColor: Colors.white,
                contentPadding: const EdgeInsets.symmetric(vertical: 0),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide.none,
                ),
              ),
              onChanged: (value) {
                ref.read(auditionFiltersProvider.notifier).state =
                    filters.copyWith(searchQuery: value);
              },
            ),
          ),

          // Filter chips
          Container(
            padding: const EdgeInsets.symmetric(vertical: 8),
            color: AppColors.surface,
            child: SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(horizontal: 12),
              child: Row(
                children: [
                  _FilterChipWidget(
                    label: filters.category != null
                        ? filters.category!.displayCategory
                        : 'Category',
                    isActive: filters.category != null,
                    onTap: () => _showCategoryFilter(context, ref, filters),
                  ),
                  const SizedBox(width: 8),
                  _FilterChipWidget(
                    label: filters.location ?? 'Location',
                    isActive: filters.location != null,
                    onTap: () => _showLocationFilter(context, ref, filters),
                  ),
                  const SizedBox(width: 8),
                  if (filters.category != null || filters.location != null)
                    ActionChip(
                      label: const Text('Clear All'),
                      avatar: const Icon(Icons.clear, size: 16),
                      onPressed: () {
                        ref.read(auditionFiltersProvider.notifier).state =
                            const AuditionFilters();
                      },
                      backgroundColor: AppColors.errorLight,
                      labelStyle: const TextStyle(
                          color: AppColors.error, fontSize: 13),
                      side: BorderSide.none,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(20),
                      ),
                    ),
                ],
              ),
            ),
          ),
          const Divider(height: 1),

          // Audition list
          Expanded(
            child: auditionsAsync.when(
              loading: () => const ShimmerList(),
              error: (error, stack) => _buildErrorState(context, ref, error),
              data: (auditions) {
                if (auditions.isEmpty) {
                  return _buildEmptyState(context, ref);
                }
                return RefreshIndicator(
                  color: AppColors.primary,
                  onRefresh: () async {
                    ref.invalidate(auditionsProvider);
                  },
                  child: ListView.builder(
                    padding: const EdgeInsets.only(top: 8, bottom: 24),
                    itemCount: auditions.length,
                    itemBuilder: (context, index) {
                      final audition = auditions[index];
                      return AuditionCard(
                        audition: audition,
                        onTap: () {
                          context.pushNamed(
                            RouteNames.auditionDetail,
                            pathParameters: {'id': audition.id},
                          );
                        },
                      );
                    },
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyState(BuildContext context, WidgetRef ref) {
    return EmptyState(
      icon: Icons.search_off,
      title: 'No auditions found',
      subtitle:
          'Try adjusting your search or filters to find more opportunities.',
      action: TextButton.icon(
        onPressed: () {
          ref.read(auditionFiltersProvider.notifier).state =
              const AuditionFilters();
        },
        icon: const Icon(Icons.refresh),
        label: const Text('Clear Filters'),
      ),
    );
  }

  Widget _buildErrorState(
      BuildContext context, WidgetRef ref, Object error) {
    return EmptyState(
      icon: Icons.error_outline,
      title: 'Something went wrong',
      subtitle: 'Could not load auditions. Please try again.',
      action: TextButton.icon(
        onPressed: () => ref.invalidate(auditionsProvider),
        icon: const Icon(Icons.refresh),
        label: const Text('Retry'),
      ),
    );
  }

  void _showCategoryFilter(
      BuildContext context, WidgetRef ref, AuditionFilters filters) {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (ctx) {
        return SafeArea(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Padding(
                padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text('Select Category',
                        style: Theme.of(context).textTheme.titleMedium),
                    if (filters.category != null)
                      TextButton(
                        onPressed: () {
                          ref.read(auditionFiltersProvider.notifier).state =
                              AuditionFilters(
                            location: filters.location,
                            searchQuery: filters.searchQuery,
                          );
                          Navigator.pop(ctx);
                        },
                        child: const Text('Clear'),
                      ),
                  ],
                ),
              ),
              const Divider(),
              ...TalentCategory.values.map((cat) {
                final catName = cat.name;
                return ListTile(
                  title: Text(catName.displayCategory),
                  trailing: filters.category == catName
                      ? const Icon(Icons.check, color: AppColors.primary)
                      : null,
                  onTap: () {
                    ref.read(auditionFiltersProvider.notifier).state =
                        filters.copyWith(category: catName);
                    Navigator.pop(ctx);
                  },
                );
              }),
              const SizedBox(height: 8),
            ],
          ),
        );
      },
    );
  }

  void _showLocationFilter(
      BuildContext context, WidgetRef ref, AuditionFilters filters) {
    final controller = TextEditingController(text: filters.location ?? '');
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (ctx) {
        return Padding(
          padding: EdgeInsets.only(
            left: 16,
            right: 16,
            top: 16,
            bottom: MediaQuery.of(ctx).viewInsets.bottom + 16,
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text('Filter by Location',
                      style: Theme.of(context).textTheme.titleMedium),
                  if (filters.location != null)
                    TextButton(
                      onPressed: () {
                        ref.read(auditionFiltersProvider.notifier).state =
                            AuditionFilters(
                          category: filters.category,
                          searchQuery: filters.searchQuery,
                        );
                        Navigator.pop(ctx);
                      },
                      child: const Text('Clear'),
                    ),
                ],
              ),
              const SizedBox(height: 12),
              TextField(
                controller: controller,
                autofocus: true,
                decoration: InputDecoration(
                  hintText: 'Enter city or location...',
                  prefixIcon: const Icon(Icons.location_on_outlined),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                textInputAction: TextInputAction.done,
                onSubmitted: (value) {
                  if (value.trim().isNotEmpty) {
                    ref.read(auditionFiltersProvider.notifier).state =
                        filters.copyWith(location: value.trim());
                  }
                  Navigator.pop(ctx);
                },
              ),
              const SizedBox(height: 12),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () {
                    final value = controller.text.trim();
                    if (value.isNotEmpty) {
                      ref.read(auditionFiltersProvider.notifier).state =
                          filters.copyWith(location: value);
                    }
                    Navigator.pop(ctx);
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primary,
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    padding: const EdgeInsets.symmetric(vertical: 14),
                  ),
                  child: const Text('Apply'),
                ),
              ),
              const SizedBox(height: 8),
            ],
          ),
        );
      },
    );
  }
}

class _FilterChipWidget extends StatelessWidget {
  final String label;
  final bool isActive;
  final VoidCallback onTap;

  const _FilterChipWidget({
    required this.label,
    required this.isActive,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
        decoration: BoxDecoration(
          color: isActive ? AppColors.primary : AppColors.surfaceVariant,
          borderRadius: BorderRadius.circular(20),
          border: isActive
              ? null
              : Border.all(color: AppColors.border, width: 1),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              label,
              style: TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w500,
                color: isActive ? Colors.white : AppColors.textPrimary,
              ),
            ),
            const SizedBox(width: 4),
            Icon(
              Icons.keyboard_arrow_down,
              size: 18,
              color: isActive ? Colors.white : AppColors.textSecondary,
            ),
          ],
        ),
      ),
    );
  }
}
