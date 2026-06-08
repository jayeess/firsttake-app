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
      return const Scaffold(body: Center(child: Text('Not logged in')));
    }

    final profileAsync = ref.watch(recruiterProfileProvider(user.uid));

    return profileAsync.when(
      loading: () => const Scaffold(body: LoadingIndicator(message: 'Loading profile...')),
      error: (e, _) => Scaffold(
        body: Center(child: Text('Error: $e')),
      ),
      data: (profile) {
        if (profile == null) {
          return Scaffold(
            body: Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Icon(Icons.business_outlined, size: 64, color: AppColors.textHint),
                  const SizedBox(height: 16),
                  const Text('No profile created yet'),
                  const SizedBox(height: 16),
                  CustomButton(
                    label: 'Create Profile',
                    width: 200,
                    onPressed: () => context.pushNamed('recruiter-onboarding'),
                  ),
                ],
              ),
            ),
          );
        }

        return SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            children: [
              const SizedBox(height: 16),
              ProfilePhotoWidget(
                photoUrl: profile.companyLogo,
                initials: profile.companyName.isNotEmpty ? profile.companyName[0] : '?',
                size: 100,
              ),
              const SizedBox(height: 16),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    profile.companyName,
                    style: Theme.of(context).textTheme.headlineMedium,
                  ),
                  if (profile.isVerified) ...[
                    const SizedBox(width: 8),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                      decoration: BoxDecoration(
                        color: AppColors.successLight,
                        borderRadius: BorderRadius.circular(6),
                      ),
                      child: const Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(Icons.verified, size: 16, color: AppColors.success),
                          SizedBox(width: 4),
                          Text('Verified', style: TextStyle(fontSize: 12, color: AppColors.success, fontWeight: FontWeight.w600)),
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
                    color: AppColors.warningLight,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: const Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(Icons.hourglass_top, size: 16, color: AppColors.warning),
                      SizedBox(width: 6),
                      Text('Verification Pending', style: TextStyle(fontSize: 13, color: AppColors.warning, fontWeight: FontWeight.w600)),
                    ],
                  ),
                ),
              ],
              const SizedBox(height: 24),

              if (profile.bio != null && profile.bio!.isNotEmpty) ...[
                Card(
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('About', style: Theme.of(context).textTheme.titleMedium),
                        const SizedBox(height: 8),
                        Text(profile.bio!, style: Theme.of(context).textTheme.bodyMedium),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 12),
              ],

              Card(
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('Contact Information', style: Theme.of(context).textTheme.titleMedium),
                      const SizedBox(height: 12),
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

              CustomButton(
                label: 'Edit Profile',
                icon: Icons.edit,
                variant: ButtonVariant.outline,
                onPressed: () => context.pushNamed('edit-recruiter-profile'),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildInfoRow(IconData icon, String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        children: [
          Icon(icon, size: 20, color: AppColors.textSecondary),
          const SizedBox(width: 12),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(label, style: const TextStyle(fontSize: 12, color: AppColors.textHint)),
              Text(value, style: const TextStyle(fontSize: 14)),
            ],
          ),
        ],
      ),
    );
  }
}
