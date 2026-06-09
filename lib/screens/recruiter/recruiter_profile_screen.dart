import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:go_router/go_router.dart';
import '../../providers/user_provider.dart';
import '../../utils/theme/app_colors.dart';
import '../../widgets/common/loading_indicator.dart';
import '../../widgets/common/custom_button.dart';
import '../../widgets/talent/profile_photo_widget.dart';

class RecruiterProfileScreen extends ConsumerWidget {
  const RecruiterProfileScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) {
      return const Scaffold(
        body: EmptyState(
          icon: Icons.login,
          title: 'Please sign in',
          subtitle: 'You need to be signed in to view your profile.',
        ),
      );
    }

    final profileAsync = ref.watch(recruiterProfileProvider(user.uid));

    return profileAsync.when(
      loading: () => const Scaffold(body: LoadingIndicator(message: 'Loading profile...')),
      error: (e, _) => Scaffold(
        body: EmptyState(
          icon: Icons.error_outline,
          title: 'Could not load profile',
          subtitle: 'Something went wrong. Please try again.',
          action: TextButton.icon(
            onPressed: () => ref.invalidate(recruiterProfileProvider(user.uid)),
            icon: const Icon(Icons.refresh),
            label: const Text('Retry'),
          ),
        ),
      ),
      data: (profile) {
        if (profile == null) {
          return Scaffold(
            body: EmptyState(
              icon: Icons.business_outlined,
              title: 'No profile created yet',
              subtitle: 'Set up your company profile to start posting auditions.',
              action: CustomButton(
                label: 'Create Profile',
                width: 200,
                onPressed: () => context.pushNamed('recruiter-onboarding'),
              ),
            ),
          );
        }

        return SingleChildScrollView(
          child: Column(
            children: [
              // Gradient header
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
                      photoUrl: profile.companyLogo,
                      initials: profile.companyName.isNotEmpty ? profile.companyName[0] : '?',
                      size: 100,
                    ),
                    const SizedBox(height: 16),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Flexible(
                          child: Text(
                            profile.companyName,
                            style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                                  color: Colors.white,
                                  fontWeight: FontWeight.bold,
                                ),
                            textAlign: TextAlign.center,
                          ),
                        ),
                        if (profile.isVerified) ...[
                          const SizedBox(width: 8),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                            decoration: BoxDecoration(
                              color: Colors.white.withValues(alpha: 0.2),
                              borderRadius: BorderRadius.circular(20),
                            ),
                            child: const Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Icon(Icons.verified, size: 16, color: Colors.white),
                                SizedBox(width: 4),
                                Text('Verified', style: TextStyle(fontSize: 12, color: Colors.white, fontWeight: FontWeight.w600)),
                              ],
                            ),
                          ),
                        ],
                      ],
                    ),
                    if (!profile.isVerified) ...[
                      const SizedBox(height: 8),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                        decoration: BoxDecoration(
                          color: AppColors.warning.withValues(alpha: 0.2),
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: const Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(Icons.hourglass_top, size: 16, color: Colors.white),
                            SizedBox(width: 6),
                            Text('Verification Pending', style: TextStyle(fontSize: 13, color: Colors.white, fontWeight: FontWeight.w600)),
                          ],
                        ),
                      ),
                    ],
                    const SizedBox(height: 24),
                  ],
                ),
              ),

              const SizedBox(height: 16),

              if (profile.bio != null && profile.bio!.isNotEmpty) ...[
                Card(
                  margin: const EdgeInsets.symmetric(horizontal: 16),
                  elevation: 2,
                  shadowColor: Colors.black.withValues(alpha: 0.08),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('About', style: Theme.of(context).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w600)),
                        const SizedBox(height: 10),
                        Text(profile.bio!, style: Theme.of(context).textTheme.bodyMedium?.copyWith(height: 1.5, color: AppColors.textSecondary)),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 12),
              ],

              Card(
                margin: const EdgeInsets.symmetric(horizontal: 16),
                elevation: 2,
                shadowColor: Colors.black.withValues(alpha: 0.08),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('Contact Information', style: Theme.of(context).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w600)),
                      const SizedBox(height: 14),
                      if (profile.phone != null && profile.phone!.isNotEmpty)
                        _buildInfoRow(Icons.phone, 'Phone', profile.phone!),
                      if (profile.address != null && profile.address!.isNotEmpty)
                        _buildInfoRow(Icons.location_on, 'Address', profile.address!),
                      if (profile.website != null && profile.website!.isNotEmpty)
                        _buildInfoRow(Icons.language, 'Website', profile.website!),
                      _buildInfoRow(Icons.email, 'Email', user.email ?? ''),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 24),

              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: CustomButton(
                  label: 'Edit Profile',
                  icon: Icons.edit,
                  variant: ButtonVariant.outline,
                  onPressed: () => context.pushNamed('edit-recruiter-profile'),
                ),
              ),
              const SizedBox(height: 32),
            ],
          ),
        );
      },
    );
  }

  Widget _buildInfoRow(IconData icon, String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 14),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: AppColors.primary.withValues(alpha: 0.06),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(icon, size: 20, color: AppColors.primary),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(label, style: const TextStyle(fontSize: 12, color: AppColors.textHint)),
                const SizedBox(height: 2),
                Text(value, style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w500)),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
