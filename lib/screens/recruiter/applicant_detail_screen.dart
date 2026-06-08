import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../models/application_model.dart';
import '../../models/talent_profile_model.dart';
import '../../models/media_file_model.dart';
import '../../providers/application_provider.dart';
import '../../providers/user_provider.dart';
import '../../utils/theme/app_colors.dart';
import '../../utils/extensions/date_extensions.dart';
import '../../utils/extensions/string_extensions.dart';
import '../../widgets/common/custom_app_bar.dart';
import '../../widgets/common/custom_button.dart';
import '../../widgets/common/loading_indicator.dart';
import '../../widgets/talent/profile_photo_widget.dart';
import '../../widgets/recruiter/applicant_video_player.dart';

/// Provider that fetches a single application by its id within an audition.
final _applicationDetailProvider = FutureProvider.autoDispose
    .family<Application?, ({String auditionId, String applicationId})>(
  (ref, params) async {
    final applications = await ref
        .watch(auditionApplicationsProvider(params.auditionId).future);
    return applications
        .cast<Application?>()
        .firstWhere(
          (a) => a?.id == params.applicationId,
          orElse: () => null,
        );
  },
);

class ApplicantDetailScreen extends ConsumerWidget {
  final String auditionId;
  final String applicationId;

  const ApplicantDetailScreen({
    super.key,
    required this.auditionId,
    required this.applicationId,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final appAsync = ref.watch(
      _applicationDetailProvider(
        (auditionId: auditionId, applicationId: applicationId),
      ),
    );

    return Scaffold(
      appBar: const CustomAppBar(title: 'Applicant Details'),
      body: appAsync.when(
        loading: () =>
            const LoadingIndicator(message: 'Loading applicant...'),
        error: (error, _) => Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(Icons.error_outline,
                  size: 48, color: AppColors.error),
              const SizedBox(height: 12),
              Text('Error: $error'),
            ],
          ),
        ),
        data: (application) {
          if (application == null) {
            return const Center(child: Text('Application not found.'));
          }

          return _ApplicantDetailBody(
            application: application,
            auditionId: auditionId,
          );
        },
      ),
    );
  }
}

class _ApplicantDetailBody extends ConsumerWidget {
  final Application application;
  final String auditionId;

  const _ApplicantDetailBody({
    required this.application,
    required this.auditionId,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final talentProfileAsync =
        ref.watch(talentProfileProvider(application.talentId));

    return talentProfileAsync.when(
      loading: () =>
          const LoadingIndicator(message: 'Loading profile...'),
      error: (error, _) => Center(
        child: Text('Failed to load profile: $error'),
      ),
      data: (profile) {
        return Column(
          children: [
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildProfileHeader(context, profile),
                    const SizedBox(height: 20),
                    _buildStatusBadge(context),
                    const SizedBox(height: 20),
                    if (profile?.bio != null &&
                        profile!.bio!.isNotEmpty) ...[
                      _buildSectionTitle(context, 'About'),
                      const SizedBox(height: 8),
                      Text(
                        profile.bio!,
                        style: const TextStyle(
                          fontSize: 14,
                          color: AppColors.textSecondary,
                          height: 1.5,
                        ),
                      ),
                      const SizedBox(height: 20),
                    ],
                    if (application.coverMessage != null &&
                        application.coverMessage!.isNotEmpty) ...[
                      _buildSectionTitle(context, 'Cover Message'),
                      const SizedBox(height: 8),
                      Container(
                        width: double.infinity,
                        padding: const EdgeInsets.all(14),
                        decoration: BoxDecoration(
                          color: AppColors.surfaceVariant,
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: Text(
                          application.coverMessage!,
                          style: const TextStyle(
                            fontSize: 14,
                            color: AppColors.textPrimary,
                            height: 1.5,
                            fontStyle: FontStyle.italic,
                          ),
                        ),
                      ),
                      const SizedBox(height: 20),
                    ],
                    _buildSectionTitle(context, 'Introduction Video'),
                    const SizedBox(height: 8),
                    const ApplicantVideoPlayer(),
                    const SizedBox(height: 20),
                    _buildSectionTitle(context, 'Portfolio'),
                    const SizedBox(height: 8),
                    _buildPortfolioGrid(context),
                    const SizedBox(height: 20),
                    if (_hasSocialLinks(profile)) ...[
                      _buildSectionTitle(context, 'Social Links'),
                      const SizedBox(height: 8),
                      _buildSocialLinks(context, profile!),
                      const SizedBox(height: 20),
                    ],
                    _buildApplicationInfo(context),
                    const SizedBox(height: 24),
                  ],
                ),
              ),
            ),
            if (application.status == 'APPLIED' ||
                application.status == 'VIEWED')
              _buildBottomActions(context, ref),
          ],
        );
      },
    );
  }

  Widget _buildProfileHeader(
      BuildContext context, TalentProfile? profile) {
    final name = profile != null
        ? '${profile.firstName} ${profile.lastName}'
        : 'Unknown Applicant';
    final category = profile?.category.name.displayCategory ?? '';
    final experience = profile != null
        ? (experienceLevelToString[profile.experienceLevel] ?? '')
            .displayExperience
        : '';
    final location = profile?.location ?? '';

    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        ProfilePhotoWidget(
          photoUrl: profile?.profilePhotoUrl,
          initials: profile != null
              ? '${profile.firstName[0]}${profile.lastName[0]}'.toUpperCase()
              : '?',
          size: 80,
        ),
        const SizedBox(width: 16),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                name,
                style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
              ),
              if (category.isNotEmpty) ...[
                const SizedBox(height: 4),
                Text(
                  category,
                  style: const TextStyle(
                    fontSize: 15,
                    color: AppColors.primary,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
              if (experience.isNotEmpty) ...[
                const SizedBox(height: 4),
                Row(
                  children: [
                    const Icon(Icons.work_outline,
                        size: 14, color: AppColors.textSecondary),
                    const SizedBox(width: 4),
                    Text(
                      experience,
                      style: const TextStyle(
                        fontSize: 13,
                        color: AppColors.textSecondary,
                      ),
                    ),
                  ],
                ),
              ],
              if (location.isNotEmpty) ...[
                const SizedBox(height: 4),
                Row(
                  children: [
                    const Icon(Icons.location_on_outlined,
                        size: 14, color: AppColors.textSecondary),
                    const SizedBox(width: 4),
                    Flexible(
                      child: Text(
                        location,
                        style: const TextStyle(
                          fontSize: 13,
                          color: AppColors.textSecondary,
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildStatusBadge(BuildContext context) {
    final (label, color, bgColor) = switch (application.status) {
      'APPLIED' => ('Applied', AppColors.applied, AppColors.infoLight),
      'VIEWED' => ('Viewed', AppColors.viewed, AppColors.warningLight),
      'SHORTLISTED' =>
        ('Shortlisted', AppColors.shortlisted, AppColors.successLight),
      'REJECTED' =>
        ('Rejected', AppColors.rejected, AppColors.errorLight),
      _ => (application.status, AppColors.textSecondary, AppColors.surfaceVariant),
    };

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            application.status == 'SHORTLISTED'
                ? Icons.star
                : application.status == 'REJECTED'
                    ? Icons.close
                    : Icons.circle,
            size: 14,
            color: color,
          ),
          const SizedBox(width: 6),
          Text(
            label,
            style: TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w600,
              color: color,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSectionTitle(BuildContext context, String title) {
    return Text(
      title,
      style: Theme.of(context).textTheme.titleMedium?.copyWith(
            fontWeight: FontWeight.w600,
          ),
    );
  }

  Widget _buildPortfolioGrid(BuildContext context) {
    // Placeholder grid for portfolio photos. In production, these would
    // be loaded from the talent's media files collection.
    return Container(
      height: 200,
      width: double.infinity,
      decoration: BoxDecoration(
        color: AppColors.surfaceVariant,
        borderRadius: BorderRadius.circular(12),
      ),
      child: const Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.photo_library_outlined,
                size: 48, color: AppColors.textHint),
            SizedBox(height: 8),
            Text(
              'Portfolio photos will appear here',
              style: TextStyle(color: AppColors.textHint),
            ),
          ],
        ),
      ),
    );
  }

  bool _hasSocialLinks(TalentProfile? profile) {
    if (profile == null) return false;
    return (profile.instagramUrl != null &&
            profile.instagramUrl!.isNotEmpty) ||
        (profile.youtubeUrl != null && profile.youtubeUrl!.isNotEmpty) ||
        (profile.websiteUrl != null && profile.websiteUrl!.isNotEmpty);
  }

  Widget _buildSocialLinks(BuildContext context, TalentProfile profile) {
    return Column(
      children: [
        if (profile.instagramUrl != null &&
            profile.instagramUrl!.isNotEmpty)
          _socialLinkTile(
            Icons.camera_alt_outlined,
            'Instagram',
            profile.instagramUrl!,
          ),
        if (profile.youtubeUrl != null &&
            profile.youtubeUrl!.isNotEmpty)
          _socialLinkTile(
            Icons.play_circle_outline,
            'YouTube',
            profile.youtubeUrl!,
          ),
        if (profile.websiteUrl != null &&
            profile.websiteUrl!.isNotEmpty)
          _socialLinkTile(
            Icons.language,
            'Website',
            profile.websiteUrl!,
          ),
      ],
    );
  }

  Widget _socialLinkTile(IconData icon, String label, String url) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        children: [
          Icon(icon, size: 18, color: AppColors.primary),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: const TextStyle(
                    fontSize: 12,
                    color: AppColors.textHint,
                  ),
                ),
                Text(
                  url,
                  style: const TextStyle(
                    fontSize: 14,
                    color: AppColors.primary,
                    decoration: TextDecoration.underline,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildApplicationInfo(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: AppColors.surfaceVariant,
        borderRadius: BorderRadius.circular(10),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Application Info',
            style: Theme.of(context).textTheme.titleSmall?.copyWith(
                  fontWeight: FontWeight.w600,
                ),
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              const Icon(Icons.schedule,
                  size: 14, color: AppColors.textSecondary),
              const SizedBox(width: 6),
              Text(
                'Applied: ${application.createdAt!.formattedDateTime}',
                style: const TextStyle(
                  fontSize: 13,
                  color: AppColors.textSecondary,
                ),
              ),
            ],
          ),
          if (application.recruiterNotes != null &&
              application.recruiterNotes!.isNotEmpty) ...[
            const SizedBox(height: 6),
            Text(
              'Notes: ${application.recruiterNotes}',
              style: const TextStyle(
                fontSize: 13,
                color: AppColors.textSecondary,
              ),
            ),
          ],
          if (application.rejectionReason != null &&
              application.rejectionReason!.isNotEmpty) ...[
            const SizedBox(height: 6),
            Text(
              'Rejection reason: ${application.rejectionReason}',
              style: const TextStyle(
                fontSize: 13,
                color: AppColors.rejected,
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildBottomActions(BuildContext context, WidgetRef ref) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: const BoxDecoration(
        color: AppColors.surface,
        boxShadow: [
          BoxShadow(
            color: Colors.black12,
            blurRadius: 8,
            offset: Offset(0, -2),
          ),
        ],
      ),
      child: SafeArea(
        child: Row(
          children: [
            Expanded(
              child: CustomButton(
                label: 'Reject',
                variant: ButtonVariant.danger,
                icon: Icons.close,
                onPressed: () => _updateStatus(
                  context,
                  ref,
                  ApplicationStatus.REJECTED,
                ),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: CustomButton(
                label: 'Shortlist',
                variant: ButtonVariant.primary,
                icon: Icons.star_outline,
                onPressed: () => _updateStatus(
                  context,
                  ref,
                  ApplicationStatus.SHORTLISTED,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _updateStatus(
    BuildContext context,
    WidgetRef ref,
    ApplicationStatus newStatus,
  ) async {
    try {
      final firestoreService = ref.read(firestoreServiceProvider);
      await firestoreService.updateApplicationStatus(
        auditionId,
        application.id,
        newStatus,
      );
      ref.invalidate(auditionApplicationsProvider(auditionId));

      if (context.mounted) {
        final label = newStatus == ApplicationStatus.SHORTLISTED
            ? 'shortlisted'
            : 'rejected';
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Applicant $label.'),
            backgroundColor: newStatus == ApplicationStatus.SHORTLISTED
                ? AppColors.success
                : AppColors.error,
          ),
        );
        context.pop();
      }
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error: ${e.toString()}'),
            backgroundColor: AppColors.error,
          ),
        );
      }
    }
  }
}
