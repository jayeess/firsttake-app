import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';

import '../../models/user_model.dart';
import '../../models/recruiter_profile_model.dart';
import '../../providers/user_provider.dart';
import '../../utils/theme/app_colors.dart';
import '../../widgets/common/custom_button.dart';
import '../../widgets/common/custom_text_field.dart';
import '../../widgets/common/loading_indicator.dart';

// ---------------------------------------------------------------------------
// Providers scoped to verification
// ---------------------------------------------------------------------------

final _pendingRecruitersProvider =
    FutureProvider.autoDispose<List<UserModel>>((ref) async {
  return ref.read(firestoreServiceProvider).getPendingRecruiters();
});

// ---------------------------------------------------------------------------
// RecruiterVerificationScreen
// ---------------------------------------------------------------------------

class RecruiterVerificationScreen extends ConsumerStatefulWidget {
  const RecruiterVerificationScreen({super.key});

  @override
  ConsumerState<RecruiterVerificationScreen> createState() =>
      _RecruiterVerificationScreenState();
}

class _RecruiterVerificationScreenState
    extends ConsumerState<RecruiterVerificationScreen> {
  @override
  Widget build(BuildContext context) {
    final pendingAsync = ref.watch(_pendingRecruitersProvider);

    return SafeArea(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 16, 16, 0),
            child: Text(
              'Verification Queue',
              style: Theme.of(context)
                  .textTheme
                  .headlineSmall
                  ?.copyWith(fontWeight: FontWeight.bold),
            ),
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 4, 16, 16),
            child: Text(
              'Review and verify recruiter accounts',
              style: Theme.of(context)
                  .textTheme
                  .bodyMedium
                  ?.copyWith(color: AppColors.textSecondary),
            ),
          ),

          // List
          Expanded(
            child: pendingAsync.when(
              data: (recruiters) {
                if (recruiters.isEmpty) {
                  return EmptyState(
                    icon: Icons.verified,
                    title: 'All caught up!',
                    subtitle:
                        'There are no pending verification requests at this time.',
                  );
                }
                return RefreshIndicator(
                  onRefresh: () async {
                    ref.invalidate(_pendingRecruitersProvider);
                  },
                  child: ListView.builder(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    itemCount: recruiters.length,
                    itemBuilder: (context, index) {
                      return _PendingRecruiterCard(
                        user: recruiters[index],
                        onReview: () =>
                            _openReviewSheet(recruiters[index]),
                      );
                    },
                  ),
                );
              },
              loading: () => const LoadingIndicator(
                  message: 'Loading verification queue...'),
              error: (e, _) => Center(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(Icons.error_outline,
                        color: AppColors.error, size: 48),
                    const SizedBox(height: 12),
                    Text('Failed to load queue',
                        style: Theme.of(context).textTheme.bodyLarge),
                    const SizedBox(height: 4),
                    Text('$e',
                        style: Theme.of(context)
                            .textTheme
                            .bodySmall
                            ?.copyWith(color: AppColors.textSecondary)),
                    const SizedBox(height: 16),
                    CustomButton(
                      label: 'Retry',
                      variant: ButtonVariant.outline,
                      width: 120,
                      onPressed: () =>
                          ref.invalidate(_pendingRecruitersProvider),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  // -------------------------------------------------------------------------
  // Review bottom sheet
  // -------------------------------------------------------------------------

  void _openReviewSheet(UserModel user) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (ctx) {
        return _RecruiterReviewSheet(
          user: user,
          onActionComplete: () {
            ref.invalidate(_pendingRecruitersProvider);
            Navigator.of(ctx).pop();
          },
        );
      },
    );
  }
}

// ---------------------------------------------------------------------------
// Pending Recruiter Card
// ---------------------------------------------------------------------------

class _PendingRecruiterCard extends ConsumerWidget {
  final UserModel user;
  final VoidCallback onReview;

  const _PendingRecruiterCard({
    required this.user,
    required this.onReview,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final profileAsync = ref.watch(recruiterProfileProvider(user.uid));
    final dateFormat = DateFormat('MMM d, yyyy');

    return Card(
      elevation: 0,
      margin: const EdgeInsets.only(bottom: 10),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: BorderSide(color: AppColors.border),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: profileAsync.when(
          data: (profile) {
            final companyName = profile?.companyName ?? 'Unknown Company';
            return Row(
              children: [
                // Company icon
                Container(
                  width: 48,
                  height: 48,
                  decoration: BoxDecoration(
                    color: AppColors.warningLight,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: const Icon(Icons.business,
                      color: AppColors.warning, size: 24),
                ),
                const SizedBox(width: 12),

                // Info
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        companyName,
                        style: Theme.of(context)
                            .textTheme
                            .bodyMedium
                            ?.copyWith(fontWeight: FontWeight.w600),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 2),
                      Text(
                        user.email,
                        style: Theme.of(context)
                            .textTheme
                            .bodySmall
                            ?.copyWith(color: AppColors.textSecondary),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 2),
                      Text(
                        'Submitted ${dateFormat.format(user.createdAt)}',
                        style: Theme.of(context)
                            .textTheme
                            .bodySmall
                            ?.copyWith(color: AppColors.textHint),
                      ),
                    ],
                  ),
                ),

                const SizedBox(width: 8),

                // Review button
                SizedBox(
                  width: 90,
                  child: CustomButton(
                    label: 'Review',
                    variant: ButtonVariant.primary,
                    height: 36,
                    onPressed: onReview,
                  ),
                ),
              ],
            );
          },
          loading: () => const SizedBox(
            height: 48,
            child: Center(
                child:
                    SizedBox(width: 20, height: 20, child: CircularProgressIndicator(strokeWidth: 2))),
          ),
          error: (_, __) => Row(
            children: [
              Container(
                width: 48,
                height: 48,
                decoration: BoxDecoration(
                  color: AppColors.warningLight,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Icon(Icons.business,
                    color: AppColors.warning, size: 24),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      user.email,
                      style: Theme.of(context)
                          .textTheme
                          .bodyMedium
                          ?.copyWith(fontWeight: FontWeight.w600),
                    ),
                    Text(
                      'Submitted ${dateFormat.format(user.createdAt)}',
                      style: Theme.of(context)
                          .textTheme
                          .bodySmall
                          ?.copyWith(color: AppColors.textHint),
                    ),
                  ],
                ),
              ),
              SizedBox(
                width: 90,
                child: CustomButton(
                  label: 'Review',
                  variant: ButtonVariant.primary,
                  height: 36,
                  onPressed: onReview,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// Recruiter Review Sheet
// ---------------------------------------------------------------------------

class _RecruiterReviewSheet extends ConsumerStatefulWidget {
  final UserModel user;
  final VoidCallback onActionComplete;

  const _RecruiterReviewSheet({
    required this.user,
    required this.onActionComplete,
  });

  @override
  ConsumerState<_RecruiterReviewSheet> createState() =>
      _RecruiterReviewSheetState();
}

class _RecruiterReviewSheetState
    extends ConsumerState<_RecruiterReviewSheet> {
  bool _isApproving = false;
  bool _isRejecting = false;

  @override
  Widget build(BuildContext context) {
    final profileAsync =
        ref.watch(recruiterProfileProvider(widget.user.uid));
    final dateFormat = DateFormat('MMM d, yyyy');

    return DraggableScrollableSheet(
      initialChildSize: 0.7,
      minChildSize: 0.4,
      maxChildSize: 0.9,
      expand: false,
      builder: (context, scrollController) {
        return ListView(
          controller: scrollController,
          padding: const EdgeInsets.all(24),
          children: [
            // Drag indicator
            Center(
              child: Container(
                width: 40,
                height: 4,
                margin: const EdgeInsets.only(bottom: 20),
                decoration: BoxDecoration(
                  color: AppColors.divider,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            ),

            // Title
            Text(
              'Review Recruiter',
              style: Theme.of(context)
                  .textTheme
                  .titleLarge
                  ?.copyWith(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 20),

            profileAsync.when(
              data: (profile) {
                if (profile == null) {
                  return const Center(
                    child: Padding(
                      padding: EdgeInsets.all(24),
                      child: Text('No recruiter profile found.'),
                    ),
                  );
                }

                return Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Company info card
                    Card(
                      elevation: 0,
                      color: AppColors.surfaceVariant,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16),
                      ),
                      child: Padding(
                        padding: const EdgeInsets.all(16),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                Container(
                                  width: 56,
                                  height: 56,
                                  decoration: BoxDecoration(
                                    color: AppColors.primary
                                        .withOpacity(0.1),
                                    borderRadius:
                                        BorderRadius.circular(12),
                                  ),
                                  child: profile.companyLogo != null
                                      ? ClipRRect(
                                          borderRadius:
                                              BorderRadius.circular(12),
                                          child: Image.network(
                                            profile.companyLogo!,
                                            fit: BoxFit.cover,
                                            errorBuilder:
                                                (_, __, ___) =>
                                                    const Icon(
                                              Icons.business,
                                              color: AppColors.primary,
                                              size: 28,
                                            ),
                                          ),
                                        )
                                      : const Icon(Icons.business,
                                          color: AppColors.primary,
                                          size: 28),
                                ),
                                const SizedBox(width: 16),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        profile.companyName,
                                        style: Theme.of(context)
                                            .textTheme
                                            .titleMedium
                                            ?.copyWith(
                                                fontWeight:
                                                    FontWeight.bold),
                                      ),
                                      const SizedBox(height: 2),
                                      Text(
                                        widget.user.email,
                                        style: Theme.of(context)
                                            .textTheme
                                            .bodySmall
                                            ?.copyWith(
                                                color: AppColors
                                                    .textSecondary),
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ),

                    const SizedBox(height: 16),

                    // Detail fields
                    _ReviewDetailRow(
                      icon: Icons.email_outlined,
                      label: 'Email',
                      value: widget.user.email,
                    ),
                    if (profile.phone != null)
                      _ReviewDetailRow(
                        icon: Icons.phone_outlined,
                        label: 'Phone',
                        value: profile.phone!,
                      ),
                    if (profile.address != null)
                      _ReviewDetailRow(
                        icon: Icons.location_on_outlined,
                        label: 'Address',
                        value: profile.address!,
                      ),
                    if (profile.website != null)
                      _ReviewDetailRow(
                        icon: Icons.language,
                        label: 'Website',
                        value: profile.website!,
                      ),
                    if (profile.bio != null &&
                        profile.bio!.isNotEmpty) ...[
                      const SizedBox(height: 12),
                      Text(
                        'About',
                        style: Theme.of(context)
                            .textTheme
                            .titleSmall
                            ?.copyWith(fontWeight: FontWeight.w600),
                      ),
                      const SizedBox(height: 6),
                      Text(
                        profile.bio!,
                        style: Theme.of(context)
                            .textTheme
                            .bodyMedium
                            ?.copyWith(color: AppColors.textSecondary),
                      ),
                    ],

                    _ReviewDetailRow(
                      icon: Icons.calendar_today_outlined,
                      label: 'Submitted',
                      value: dateFormat.format(profile.createdAt),
                    ),

                    // Verification documents
                    const SizedBox(height: 16),
                    Text(
                      'Verification Documents',
                      style: Theme.of(context)
                          .textTheme
                          .titleSmall
                          ?.copyWith(fontWeight: FontWeight.w600),
                    ),
                    const SizedBox(height: 8),

                    if (profile.verificationDocuments.isEmpty)
                      Card(
                        elevation: 0,
                        color: AppColors.warningLight,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: const Padding(
                          padding: EdgeInsets.all(16),
                          child: Row(
                            children: [
                              Icon(Icons.warning_amber,
                                  color: AppColors.warning),
                              SizedBox(width: 12),
                              Expanded(
                                child: Text(
                                  'No verification documents uploaded',
                                  style: TextStyle(
                                      color: AppColors.warning),
                                ),
                              ),
                            ],
                          ),
                        ),
                      )
                    else
                      ...profile.verificationDocuments
                          .asMap()
                          .entries
                          .map((entry) {
                        final index = entry.key;
                        final docUrl = entry.value;
                        return Card(
                          elevation: 0,
                          margin: const EdgeInsets.only(bottom: 8),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                            side: BorderSide(color: AppColors.border),
                          ),
                          child: ListTile(
                            leading: Container(
                              width: 40,
                              height: 40,
                              decoration: BoxDecoration(
                                color: AppColors.infoLight,
                                borderRadius:
                                    BorderRadius.circular(8),
                              ),
                              child: const Icon(
                                  Icons.description_outlined,
                                  color: AppColors.info,
                                  size: 20),
                            ),
                            title: Text(
                              'Document ${index + 1}',
                              style: Theme.of(context)
                                  .textTheme
                                  .bodyMedium
                                  ?.copyWith(
                                      fontWeight: FontWeight.w500),
                            ),
                            subtitle: Text(
                              docUrl,
                              style: Theme.of(context)
                                  .textTheme
                                  .bodySmall
                                  ?.copyWith(
                                      color:
                                          AppColors.textHint),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                            trailing: const Icon(
                                Icons.open_in_new,
                                color: AppColors.primary,
                                size: 20),
                          ),
                        );
                      }),

                    const SizedBox(height: 24),

                    // Action buttons
                    Row(
                      children: [
                        Expanded(
                          child: CustomButton(
                            label: 'Reject',
                            variant: ButtonVariant.danger,
                            isLoading: _isRejecting,
                            icon: Icons.close,
                            onPressed: (_isApproving || _isRejecting)
                                ? null
                                : () => _handleReject(
                                    profile.companyName),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: CustomButton(
                            label: 'Approve',
                            variant: ButtonVariant.primary,
                            isLoading: _isApproving,
                            icon: Icons.check,
                            onPressed: (_isApproving || _isRejecting)
                                ? null
                                : () => _handleApprove(
                                    profile.companyName),
                          ),
                        ),
                      ],
                    ),
                  ],
                );
              },
              loading: () => const SizedBox(
                height: 200,
                child: LoadingIndicator(
                    message: 'Loading recruiter profile...'),
              ),
              error: (e, _) => Padding(
                padding: const EdgeInsets.all(24),
                child: Column(
                  children: [
                    const Icon(Icons.error_outline,
                        color: AppColors.error, size: 48),
                    const SizedBox(height: 12),
                    Text('Failed to load profile: $e'),
                  ],
                ),
              ),
            ),
          ],
        );
      },
    );
  }

  Future<void> _handleApprove(String companyName) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Approve Recruiter'),
        content: Text(
          'Are you sure you want to verify $companyName? '
          'They will be able to post auditions on the platform.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(false),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(true),
            child: const Text('Approve',
                style: TextStyle(color: AppColors.success)),
          ),
        ],
      ),
    );

    if (confirmed != true) return;

    setState(() => _isApproving = true);
    try {
      await ref
          .read(firestoreServiceProvider)
          .verifyRecruiter(widget.user.uid);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('$companyName has been verified'),
            backgroundColor: AppColors.success,
          ),
        );
        widget.onActionComplete();
      }
    } catch (e) {
      if (mounted) {
        setState(() => _isApproving = false);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to approve: $e'),
            backgroundColor: AppColors.error,
          ),
        );
      }
    }
  }

  Future<void> _handleReject(String companyName) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Reject Recruiter'),
        content: Text(
          'Are you sure you want to reject $companyName? '
          'Their account will be suspended.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(false),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(true),
            child: const Text('Reject',
                style: TextStyle(color: AppColors.error)),
          ),
        ],
      ),
    );

    if (confirmed != true) return;

    setState(() => _isRejecting = true);
    try {
      await ref
          .read(firestoreServiceProvider)
          .updateUserStatus(widget.user.uid, AccountStatus.SUSPENDED);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('$companyName has been rejected'),
            backgroundColor: AppColors.warning,
          ),
        );
        widget.onActionComplete();
      }
    } catch (e) {
      if (mounted) {
        setState(() => _isRejecting = false);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to reject: $e'),
            backgroundColor: AppColors.error,
          ),
        );
      }
    }
  }
}

// ---------------------------------------------------------------------------
// Review Detail Row
// ---------------------------------------------------------------------------

class _ReviewDetailRow extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;

  const _ReviewDetailRow({
    required this.icon,
    required this.label,
    required this.value,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        children: [
          Icon(icon, size: 18, color: AppColors.textSecondary),
          const SizedBox(width: 10),
          SizedBox(
            width: 80,
            child: Text(
              label,
              style: Theme.of(context)
                  .textTheme
                  .bodySmall
                  ?.copyWith(color: AppColors.textSecondary),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: Theme.of(context)
                  .textTheme
                  .bodyMedium
                  ?.copyWith(fontWeight: FontWeight.w500),
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ],
      ),
    );
  }
}
