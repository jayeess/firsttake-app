import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../models/talent_profile_model.dart';
import '../../providers/auth_provider.dart';
import '../../providers/user_provider.dart';
import '../../providers/application_provider.dart';
import '../../routing/route_names.dart';
import '../../utils/theme/app_colors.dart';
import '../../utils/extensions/string_extensions.dart';
import '../../widgets/talent/profile_photo_widget.dart';
import '../../widgets/common/custom_button.dart';
import '../../widgets/common/loading_indicator.dart';

class TalentProfileScreen extends ConsumerWidget {
  const TalentProfileScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final authState = ref.watch(authStateProvider);
    final currentUserId = authState.valueOrNull?.uid;

    if (currentUserId == null) {
      return const Scaffold(
        body: EmptyState(
          icon: Icons.login,
          title: 'Please sign in',
          subtitle: 'You need to be signed in to view your profile.',
        ),
      );
    }

    final profileAsync = ref.watch(talentProfileProvider(currentUserId));
    final applicationsAsync =
        ref.watch(talentApplicationsProvider(currentUserId));

    return Scaffold(
      appBar: AppBar(
        title: const Text('My Profile'),
        backgroundColor: AppColors.primary,
        foregroundColor: Colors.white,
        automaticallyImplyLeading: false,
        elevation: 0,
        actions: [
          IconButton(
            icon: const Icon(Icons.edit),
            onPressed: () => context.pushNamed(RouteNames.editTalentProfile),
          ),
        ],
      ),
      body: profileAsync.when(
        loading: () =>
            const LoadingIndicator(message: 'Loading profile...'),
        error: (error, stack) => EmptyState(
          icon: Icons.error_outline,
          title: 'Could not load profile',
          subtitle: 'Something went wrong. Please try again.',
          action: TextButton.icon(
            onPressed: () =>
                ref.invalidate(talentProfileProvider(currentUserId)),
            icon: const Icon(Icons.refresh),
            label: const Text('Retry'),
          ),
        ),
        data: (profile) {
          if (profile == null) {
            return EmptyState(
              icon: Icons.person_add_outlined,
              title: 'Complete your profile',
              subtitle:
                  'Set up your talent profile to start applying for auditions.',
              action: CustomButton(
                label: 'Set Up Profile',
                width: 200,
                onPressed: () =>
                    context.pushNamed(RouteNames.talentOnboarding),
              ),
            );
          }

          final applicationCount = applicationsAsync.whenOrNull(
                data: (apps) => apps.length,
              ) ??
              0;

          return RefreshIndicator(
            color: AppColors.primary,
            onRefresh: () async {
              ref.invalidate(talentProfileProvider(currentUserId));
              ref.invalidate(
                  talentApplicationsProvider(currentUserId));
            },
            child: SingleChildScrollView(
              physics: const AlwaysScrollableScrollPhysics(),
              child: Column(
                children: [
                  // Profile header with gradient
                  Container(
                    width: double.infinity,
                    decoration: const BoxDecoration(
                      gradient: LinearGradient(
                        colors: [AppColors.primary, AppColors.primaryDark],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ),
                    ),
                    child: Column(
                      children: [
                        const SizedBox(height: 24),
                        ProfilePhotoWidget(
                          photoUrl: profile.profilePhotoUrl,
                          initials:
                              '${profile.firstName} ${profile.lastName}'
                                  .initials,
                          size: 100,
                          showEditIcon: true,
                          onTap: () =>
                              context.pushNamed(RouteNames.mediaUpload),
                        ),
                        const SizedBox(height: 16),
                        Text(
                          '${profile.firstName} ${profile.lastName}',
                          style: Theme.of(context)
                              .textTheme
                              .headlineSmall
                              ?.copyWith(
                                fontWeight: FontWeight.bold,
                                color: Colors.white,
                              ),
                        ),
                        const SizedBox(height: 6),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 5),
                          decoration: BoxDecoration(
                            color: Colors.white.withValues(alpha: 0.2),
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: Text(
                            profile.category.name.displayCategory,
                            style: const TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.w600,
                              fontSize: 14,
                            ),
                          ),
                        ),
                        const SizedBox(height: 10),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            if (profile.location != null &&
                                profile.location!.isNotEmpty) ...[
                              Icon(Icons.location_on,
                                  size: 16,
                                  color: Colors.white.withValues(alpha: 0.8)),
                              const SizedBox(width: 4),
                              Text(
                                profile.location!,
                                style: TextStyle(
                                    color: Colors.white.withValues(alpha: 0.9)),
                              ),
                              const SizedBox(width: 16),
                            ],
                            Icon(Icons.work_outline,
                                size: 16,
                                color: Colors.white.withValues(alpha: 0.8)),
                            const SizedBox(width: 4),
                            Text(
                              experienceLevelToString[
                                      profile.experienceLevel]!
                                  .displayExperience,
                              style: TextStyle(
                                  color: Colors.white.withValues(alpha: 0.9)),
                            ),
                          ],
                        ),
                        const SizedBox(height: 24),
                      ],
                    ),
                  ),

                  // Profile completion CTA
                  if (profile.bio == null || profile.bio!.isEmpty || profile.profilePhotoUrl == null)
                    Container(
                      width: double.infinity,
                      margin: const EdgeInsets.fromLTRB(16, 12, 16, 4),
                      padding: const EdgeInsets.all(14),
                      decoration: BoxDecoration(
                        color: AppColors.warningLight,
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: AppColors.warning.withValues(alpha: 0.3)),
                      ),
                      child: Row(
                        children: [
                          const Icon(Icons.tips_and_updates_outlined, size: 22, color: AppColors.warning),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const Text(
                                  'Complete your profile',
                                  style: TextStyle(fontWeight: FontWeight.w600, fontSize: 14),
                                ),
                                const SizedBox(height: 2),
                                Text(
                                  profile.bio == null || profile.bio!.isEmpty
                                      ? 'Add a bio to stand out to recruiters.'
                                      : 'Add a profile photo for a professional look.',
                                  style: const TextStyle(fontSize: 13, color: AppColors.textSecondary),
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(width: 8),
                          TextButton(
                            onPressed: () => context.pushNamed(RouteNames.editTalentProfile),
                            style: TextButton.styleFrom(
                              foregroundColor: AppColors.warning,
                              padding: const EdgeInsets.symmetric(horizontal: 12),
                            ),
                            child: const Text('Update', style: TextStyle(fontWeight: FontWeight.w600)),
                          ),
                        ],
                      ),
                    ),

                  const SizedBox(height: 8),

                  // Stats section
                  Container(
                    width: double.infinity,
                    margin: const EdgeInsets.symmetric(horizontal: 16),
                    padding: const EdgeInsets.symmetric(
                        horizontal: 16, vertical: 20),
                    decoration: BoxDecoration(
                      color: AppColors.surface,
                      borderRadius: BorderRadius.circular(14),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withValues(alpha: 0.06),
                          blurRadius: 10,
                          offset: const Offset(0, 2),
                        ),
                      ],
                    ),
                    child: Row(
                      children: [
                        Expanded(
                          child: _buildStatItem(
                            context,
                            Icons.assignment,
                            '$applicationCount',
                            'Applications',
                          ),
                        ),
                        Container(
                          width: 1,
                          height: 40,
                          color: AppColors.divider,
                        ),
                        Expanded(
                          child: _buildStatItem(
                            context,
                            Icons.visibility,
                            '${applicationsAsync.whenOrNull(data: (apps) => apps.where((a) => a.status == 'VIEWED' || a.status == 'SHORTLISTED').length) ?? 0}',
                            'Viewed',
                          ),
                        ),
                        Container(
                          width: 1,
                          height: 40,
                          color: AppColors.divider,
                        ),
                        Expanded(
                          child: _buildStatItem(
                            context,
                            Icons.star,
                            '${applicationsAsync.whenOrNull(data: (apps) => apps.where((a) => a.status == 'SHORTLISTED').length) ?? 0}',
                            'Shortlisted',
                          ),
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 8),

                  // Bio section
                  if (profile.bio != null &&
                      profile.bio!.isNotEmpty)
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(20),
                      margin: const EdgeInsets.symmetric(horizontal: 16),
                      decoration: BoxDecoration(
                        color: AppColors.surface,
                        borderRadius: BorderRadius.circular(14),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withValues(alpha: 0.06),
                            blurRadius: 10,
                            offset: const Offset(0, 2),
                          ),
                        ],
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'About',
                            style: Theme.of(context)
                                .textTheme
                                .titleMedium
                                ?.copyWith(fontWeight: FontWeight.w600),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            profile.bio!,
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

                  // Personal details
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(20),
                    margin: const EdgeInsets.symmetric(horizontal: 16),
                    decoration: BoxDecoration(
                      color: AppColors.surface,
                      borderRadius: BorderRadius.circular(14),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withValues(alpha: 0.06),
                          blurRadius: 10,
                          offset: const Offset(0, 2),
                        ),
                      ],
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Personal Details',
                          style: Theme.of(context)
                              .textTheme
                              .titleMedium
                              ?.copyWith(fontWeight: FontWeight.w600),
                        ),
                        const SizedBox(height: 16),
                        if (profile.age != null)
                          _buildDetailRow('Age', '${profile.age}'),
                        if (profile.gender != null)
                          _buildDetailRow(
                              'Gender', profile.gender!.name.capitalize),
                        if (profile.height != null)
                          _buildDetailRow(
                              'Height', '${profile.height} cm'),
                      ],
                    ),
                  ),

                  const SizedBox(height: 8),

                  // Social links
                  if (_hasSocialLinks(profile))
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(20),
                      margin: const EdgeInsets.symmetric(horizontal: 16),
                      decoration: BoxDecoration(
                        color: AppColors.surface,
                        borderRadius: BorderRadius.circular(14),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withValues(alpha: 0.06),
                            blurRadius: 10,
                            offset: const Offset(0, 2),
                          ),
                        ],
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Social Links',
                            style: Theme.of(context)
                                .textTheme
                                .titleMedium
                                ?.copyWith(fontWeight: FontWeight.w600),
                          ),
                          const SizedBox(height: 12),
                          if (profile.instagramUrl != null &&
                              profile.instagramUrl!.isNotEmpty)
                            _buildSocialLink(
                              context,
                              Icons.camera_alt_outlined,
                              'Instagram',
                              profile.instagramUrl!,
                            ),
                          if (profile.youtubeUrl != null &&
                              profile.youtubeUrl!.isNotEmpty)
                            _buildSocialLink(
                              context,
                              Icons.play_circle_outline,
                              'YouTube',
                              profile.youtubeUrl!,
                            ),
                          if (profile.websiteUrl != null &&
                              profile.websiteUrl!.isNotEmpty)
                            _buildSocialLink(
                              context,
                              Icons.language,
                              'Website',
                              profile.websiteUrl!,
                            ),
                        ],
                      ),
                    ),

                  const SizedBox(height: 8),

                  // Action buttons
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(20),
                    margin: const EdgeInsets.symmetric(horizontal: 16),
                    child: Column(
                      children: [
                        CustomButton(
                          label: 'Edit Profile',
                          icon: Icons.edit,
                          variant: ButtonVariant.outline,
                          onPressed: () => context
                              .pushNamed(RouteNames.editTalentProfile),
                        ),
                        const SizedBox(height: 12),
                        CustomButton(
                          label: 'Manage Media',
                          icon: Icons.photo_library,
                          variant: ButtonVariant.secondary,
                          onPressed: () =>
                              context.pushNamed(RouteNames.mediaUpload),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 32),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  bool _hasSocialLinks(TalentProfile profile) {
    return (profile.instagramUrl != null &&
            profile.instagramUrl!.isNotEmpty) ||
        (profile.youtubeUrl != null &&
            profile.youtubeUrl!.isNotEmpty) ||
        (profile.websiteUrl != null &&
            profile.websiteUrl!.isNotEmpty);
  }

  Widget _buildStatItem(
    BuildContext context,
    IconData icon,
    String value,
    String label,
  ) {
    return Column(
      children: [
        Icon(icon, color: AppColors.primary, size: 24),
        const SizedBox(height: 8),
        Text(
          value,
          style: Theme.of(context)
              .textTheme
              .titleLarge
              ?.copyWith(fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 2),
        Text(
          label,
          style: const TextStyle(
              fontSize: 12, color: AppColors.textSecondary),
        ),
      ],
    );
  }

  Widget _buildDetailRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Row(
        children: [
          SizedBox(
            width: 100,
            child: Text(
              label,
              style: const TextStyle(
                  color: AppColors.textHint, fontSize: 14),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: const TextStyle(
                  fontWeight: FontWeight.w500, fontSize: 14),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSocialLink(
    BuildContext context,
    IconData icon,
    String label,
    String url,
  ) {
    return ListTile(
      dense: true,
      contentPadding: EdgeInsets.zero,
      leading: Icon(icon, color: AppColors.primary),
      title: Text(label),
      subtitle: Text(
        url,
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
        style: const TextStyle(
            color: AppColors.textHint, fontSize: 12),
      ),
      trailing:
          const Icon(Icons.open_in_new, size: 18, color: AppColors.textHint),
      onTap: () async {
        final uri = Uri.tryParse(
            url.startsWith('http') ? url : 'https://$url');
        if (uri != null && await canLaunchUrl(uri)) {
          await launchUrl(uri, mode: LaunchMode.externalApplication);
        }
      },
    );
  }
}
