import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../models/audition_model.dart';
import '../../models/application_model.dart';
import '../../providers/audition_provider.dart';
import '../../providers/application_provider.dart';
import '../../providers/auth_provider.dart';
import '../../providers/user_provider.dart';
import '../../utils/theme/app_colors.dart';
import '../../utils/extensions/string_extensions.dart';
import '../../utils/extensions/date_extensions.dart';
import '../../widgets/common/custom_app_bar.dart';
import '../../widgets/common/custom_button.dart';
import '../../widgets/common/loading_indicator.dart';

class AuditionDetailScreen extends ConsumerStatefulWidget {
  final String auditionId;

  const AuditionDetailScreen({super.key, required this.auditionId});

  @override
  ConsumerState<AuditionDetailScreen> createState() =>
      _AuditionDetailScreenState();
}

class _AuditionDetailScreenState extends ConsumerState<AuditionDetailScreen> {
  bool _isApplying = false;
  final _coverMessageController = TextEditingController();

  @override
  void dispose() {
    _coverMessageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final auditionAsync = ref.watch(auditionDetailProvider(widget.auditionId));
    final authState = ref.watch(authStateProvider);
    final currentUserId = authState.valueOrNull?.uid;

    return Scaffold(
      body: auditionAsync.when(
        loading: () => const Scaffold(
          body: LoadingIndicator(message: 'Loading audition details...'),
        ),
        error: (error, stack) => Scaffold(
          appBar: const CustomAppBar(title: 'Audition Detail'),
          body: EmptyState(
            icon: Icons.error_outline,
            title: 'Could not load audition',
            subtitle: 'Something went wrong. Please try again.',
            action: TextButton.icon(
              onPressed: () =>
                  ref.invalidate(auditionDetailProvider(widget.auditionId)),
              icon: const Icon(Icons.refresh),
              label: const Text('Retry'),
            ),
          ),
        ),
        data: (audition) {
          if (audition == null) {
            return Scaffold(
              appBar: const CustomAppBar(title: 'Audition Detail'),
              body: const EmptyState(
                icon: Icons.search_off,
                title: 'Audition not found',
                subtitle:
                    'This audition may have been removed or is no longer available.',
              ),
            );
          }

          final isExpired =
              audition.deadline?.isBefore(DateTime.now()) ?? false;
          final hasAlreadyApplied = _checkIfAlreadyApplied(currentUserId);

          return Scaffold(
            appBar: CustomAppBar(
              title: 'Audition Detail',
              actions: [
                IconButton(
                  icon: const Icon(Icons.share),
                  onPressed: () {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('Share link copied!')),
                    );
                  },
                ),
              ],
            ),
            body: SingleChildScrollView(
              padding: const EdgeInsets.only(bottom: 100),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Header section
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(20),
                    color: AppColors.surface,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        if (isExpired)
                          Container(
                            margin: const EdgeInsets.only(bottom: 12),
                            padding: const EdgeInsets.symmetric(
                                horizontal: 10, vertical: 6),
                            decoration: BoxDecoration(
                              color: AppColors.errorLight,
                              borderRadius: BorderRadius.circular(6),
                            ),
                            child: const Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Icon(Icons.schedule,
                                    size: 16, color: AppColors.error),
                                SizedBox(width: 4),
                                Text(
                                  'Application deadline has passed',
                                  style: TextStyle(
                                      color: AppColors.error,
                                      fontSize: 13,
                                      fontWeight: FontWeight.w500),
                                ),
                              ],
                            ),
                          ),
                        Text(
                          audition.title,
                          style: Theme.of(context)
                              .textTheme
                              .headlineSmall
                              ?.copyWith(fontWeight: FontWeight.bold),
                        ),
                        const SizedBox(height: 16),
                        Wrap(
                          spacing: 8,
                          runSpacing: 8,
                          children: [
                            _buildInfoChip(
                              Icons.category,
                              audition.category.displayCategory,
                            ),
                            _buildInfoChip(
                              Icons.work_outline,
                              (audition.experienceLevel ?? '').displayExperience,
                            ),
                            _buildInfoChip(
                              Icons.location_on_outlined,
                              audition.location ?? '',
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 8),

                  // Key details
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(20),
                    color: AppColors.surface,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Key Details',
                          style: Theme.of(context)
                              .textTheme
                              .titleMedium
                              ?.copyWith(fontWeight: FontWeight.w600),
                        ),
                        const SizedBox(height: 16),
                        if (audition.deadline != null) ...[
                          _buildDetailRow(
                            Icons.schedule,
                            'Application Deadline',
                            audition.deadline!.formattedDate,
                            valueColor:
                                isExpired ? AppColors.error : null,
                          ),
                          const SizedBox(height: 12),
                        ],
                        if (audition.payInfo != null &&
                            audition.payInfo!.isNotEmpty) ...[
                          _buildDetailRow(
                            Icons.payments_outlined,
                            'Compensation',
                            audition.payInfo!,
                          ),
                        ],
                        const SizedBox(height: 12),
                        _buildDetailRow(
                          Icons.people_outline,
                          'Applications',
                          '${audition.applicantCount} received',
                        ),
                        const SizedBox(height: 12),
                        _buildDetailRow(
                          Icons.info_outline,
                          'Status',
                          audition.status.name.displayCategory,
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 8),

                  // Description
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(20),
                    color: AppColors.surface,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Description',
                          style: Theme.of(context)
                              .textTheme
                              .titleMedium
                              ?.copyWith(fontWeight: FontWeight.w600),
                        ),
                        const SizedBox(height: 12),
                        Text(
                          audition.description,
                          style: Theme.of(context)
                              .textTheme
                              .bodyMedium
                              ?.copyWith(
                                height: 1.6,
                                color: AppColors.textSecondary,
                              ),
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 8),

                  // Posted info
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(20),
                    color: AppColors.surface,
                    child: Row(
                      children: [
                        const Icon(Icons.access_time,
                            size: 16, color: AppColors.textHint),
                        const SizedBox(width: 6),
                        Text(
                          'Posted ${audition.createdAt?.timeAgo ?? ''}',
                          style: const TextStyle(
                              fontSize: 13, color: AppColors.textHint),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            bottomSheet: Container(
              width: double.infinity,
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: AppColors.surface,
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.1),
                    blurRadius: 8,
                    offset: const Offset(0, -2),
                  ),
                ],
              ),
              child: SafeArea(
                child: CustomButton(
                  label: hasAlreadyApplied
                      ? 'Already Applied'
                      : isExpired
                          ? 'Deadline Passed'
                          : 'Apply Now',
                  onPressed:
                      (hasAlreadyApplied || isExpired || _isApplying)
                          ? null
                          : () => _showApplyDialog(context, audition),
                  isLoading: _isApplying,
                  icon: hasAlreadyApplied
                      ? Icons.check_circle
                      : isExpired
                          ? Icons.lock_clock
                          : Icons.send,
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  bool _checkIfAlreadyApplied(String? userId) {
    if (userId == null) return false;
    final applicationsAsync =
        ref.watch(talentApplicationsProvider(userId));
    return applicationsAsync.whenOrNull(
          data: (apps) =>
              apps.any((a) => a.auditionId == widget.auditionId),
        ) ??
        false;
  }

  Future<void> _showApplyDialog(
      BuildContext context, Audition audition) async {
    _coverMessageController.clear();

    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Apply for Audition'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              audition.title,
              style: const TextStyle(fontWeight: FontWeight.w600),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: _coverMessageController,
              maxLines: 4,
              maxLength: 500,
              decoration: InputDecoration(
                hintText:
                    'Add a cover message (optional)...',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                alignLabelWithHint: true,
              ),
            ),
            const SizedBox(height: 8),
            const Text(
              'Your profile and media will be shared with the recruiter.',
              style: TextStyle(
                  fontSize: 12, color: AppColors.textHint),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(ctx, true),
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.primary,
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
            ),
            child: const Text('Confirm Application'),
          ),
        ],
      ),
    );

    if (confirmed == true && mounted) {
      await _submitApplication(audition);
    }
  }

  Future<void> _submitApplication(Audition audition) async {
    final authState = ref.read(authStateProvider);
    final currentUserId = authState.valueOrNull?.uid;
    if (currentUserId == null) return;

    setState(() => _isApplying = true);

    try {
      final application = Application(
        id: '',
        auditionId: audition.id,
        talentId: currentUserId,
        coverMessage: _coverMessageController.text.trim().isEmpty
            ? null
            : _coverMessageController.text.trim(),
        status: 'APPLIED',
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      );

      await ref
          .read(firestoreServiceProvider)
          .submitApplication(application);

      // Invalidate providers to refresh data
      ref.invalidate(talentApplicationsProvider(currentUserId));
      ref.invalidate(auditionDetailProvider(widget.auditionId));

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Application submitted successfully!'),
            backgroundColor: AppColors.success,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to submit application: $e'),
            backgroundColor: AppColors.error,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isApplying = false);
      }
    }
  }

  Widget _buildInfoChip(IconData icon, String label) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: AppColors.surfaceVariant,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 16, color: AppColors.primary),
          const SizedBox(width: 6),
          Text(
            label,
            style: const TextStyle(
                fontSize: 13, color: AppColors.textPrimary),
          ),
        ],
      ),
    );
  }

  Widget _buildDetailRow(IconData icon, String label, String value,
      {Color? valueColor}) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(icon, size: 20, color: AppColors.textHint),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: const TextStyle(
                    fontSize: 12, color: AppColors.textHint),
              ),
              const SizedBox(height: 2),
              Text(
                value,
                style: TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.w500,
                  color: valueColor ?? AppColors.textPrimary,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
