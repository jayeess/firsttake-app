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
            decoration: const BoxDecoration(
              color: AppColors.primary,
              borderRadius: BorderRadius.only(
                bottomLeft: Radius.circular(20),
                bottomRight: Radius.circular(20),
              ),
            ),
            padding: const EdgeInsets.fromLTRB(16, 0, 16, 20),
            child: Material(
              elevation: 2,
              borderRadius: BorderRadius.circular(12),
              shadowColor: Colors.black26,
              child: TextField(
                decoration: InputDecoration(
                  hintText: 'Search by role, location, or category...',
                  hintStyle: TextStyle(color: AppColors.textHint.withValues(alpha: 0.7), fontSize: 14),
                  prefixIcon:
                      const Icon(Icons.search, color: AppColors.primary),
                  suffixIcon: filters.searchQuery != null &&
                          filters.searchQuery!.isNotEmpty
                      ? IconButton(
                          icon: const Icon(Icons.clear,
                              size: 20, color: AppColors.textHint),
                          onPressed: () {
                            ref.read(auditionFiltersProvider.notifier).state =
                                filters.copyWith(searchQuery: '');
                          },
                        )
                      : null,
                  filled: true,
                  fillColor: Colors.white,
                  contentPadding: const EdgeInsets.symmetric(vertical: 14),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide.none,
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide.none,
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: const BorderSide(color: AppColors.primary, width: 1.5),
                  ),
                ),
                onChanged: (value) {
                  ref.read(auditionFiltersProvider.notifier).state =
                      filters.copyWith(searchQuery: value);
                },
              ),
            ),
          ),

          // Filter chips
          Container(
            padding: const EdgeInsets.symmetric(vertical: 10),
            color: AppColors.background,
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
                return RefreshIndicator(
                  color: AppColors.primary,
                  onRefresh: () async {
                    ref.invalidate(auditionsProvider);
                  },
                  child: auditions.isEmpty
                      ? ListView(
                          children: [
                            SizedBox(
                              height: MediaQuery.of(context).size.height * 0.5,
                              child: _buildEmptyState(context, ref),
                            ),
                          ],
                        )
                      : ListView.builder(
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
    return Center(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: AppColors.primaryLight.withValues(alpha: 0.1),
                shape: BoxShape.circle,
              ),
              child: const Icon(Icons.search_off, size: 48, color: AppColors.primary),
            ),
            const SizedBox(height: 20),
            Text(
              'No auditions found',
              style: Theme.of(context).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w600),
            ),
            const SizedBox(height: 8),
            Text(
              'Try adjusting your search or filters to discover more opportunities.',
              textAlign: TextAlign.center,
              style: TextStyle(color: AppColors.textSecondary, fontSize: 14, height: 1.5),
            ),
            const SizedBox(height: 20),
            OutlinedButton.icon(
              onPressed: () {
                ref.read(auditionFiltersProvider.notifier).state =
                    const AuditionFilters();
              },
              icon: const Icon(Icons.refresh, size: 18),
              label: const Text('Clear All Filters'),
              style: OutlinedButton.styleFrom(
                foregroundColor: AppColors.primary,
                side: const BorderSide(color: AppColors.primary),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
              ),
            ),
          ],
        ),
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
    return Material(
      color: isActive ? AppColors.primary : AppColors.surface,
      elevation: isActive ? 2 : 0,
      shadowColor: isActive ? AppColors.primary.withValues(alpha: 0.3) : Colors.transparent,
      borderRadius: BorderRadius.circular(24),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(24),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(24),
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
                  fontWeight: isActive ? FontWeight.w600 : FontWeight.w500,
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
      ),
    );
  }
}
