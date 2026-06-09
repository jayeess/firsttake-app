import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../models/audition_model.dart';
import '../../providers/auth_provider.dart';
import '../../providers/audition_provider.dart';
import '../../utils/theme/app_colors.dart';
import '../../utils/extensions/date_extensions.dart';
import '../../utils/extensions/string_extensions.dart';
import '../../widgets/common/loading_indicator.dart';
import '../../routing/route_names.dart';
import 'post_audition_screen.dart';
import 'recruiter_profile_screen.dart';

class RecruiterHomeScreen extends ConsumerStatefulWidget {
  const RecruiterHomeScreen({super.key});

  @override
  ConsumerState<RecruiterHomeScreen> createState() =>
      _RecruiterHomeScreenState();
}

class _RecruiterHomeScreenState extends ConsumerState<RecruiterHomeScreen> {
  int _currentIndex = 0;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: IndexedStack(
        index: _currentIndex,
        children: const [
          _PostAuditionTab(),
          _MyAuditionsTab(),
          _ProfileTab(),
          _SettingsTab(),
        ],
      ),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _currentIndex,
        onTap: (index) => setState(() => _currentIndex = index),
        type: BottomNavigationBarType.fixed,
        selectedItemColor: AppColors.primary,
        unselectedItemColor: AppColors.textHint,
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.add_circle_outline),
            activeIcon: Icon(Icons.add_circle),
            label: 'Post Audition',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.list_alt_outlined),
            activeIcon: Icon(Icons.list_alt),
            label: 'My Auditions',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.person_outline),
            activeIcon: Icon(Icons.person),
            label: 'Profile',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.settings_outlined),
            activeIcon: Icon(Icons.settings),
            label: 'Settings',
          ),
        ],
      ),
    );
  }
}

class _PostAuditionTab extends StatelessWidget {
  const _PostAuditionTab();

  @override
  Widget build(BuildContext context) {
    return const PostAuditionScreen();
  }
}

class _MyAuditionsTab extends ConsumerWidget {
  const _MyAuditionsTab();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final authState = ref.watch(authStateProvider);
    final userId = authState.valueOrNull?.uid;

    if (userId == null) {
      return const Scaffold(
        body: EmptyState(
          icon: Icons.login,
          title: 'Please sign in',
          subtitle: 'You need to be signed in to view your auditions.',
        ),
      );
    }

    final auditionsAsync = ref.watch(recruiterAuditionsProvider(userId));

    return Scaffold(
      appBar: AppBar(
        title: const Text('My Auditions'),
        backgroundColor: AppColors.primary,
        foregroundColor: Colors.white,
        elevation: 0,
        automaticallyImplyLeading: false,
      ),
      body: auditionsAsync.when(
        loading: () => const LoadingIndicator(message: 'Loading auditions...'),
        error: (error, _) => EmptyState(
          icon: Icons.error_outline,
          title: 'Could not load auditions',
          subtitle: 'Something went wrong. Please try again.',
          action: TextButton.icon(
            onPressed: () =>
                ref.invalidate(recruiterAuditionsProvider(userId)),
            icon: const Icon(Icons.refresh),
            label: const Text('Retry'),
          ),
        ),
        data: (auditions) {
          if (auditions.isEmpty) {
            return const EmptyState(
              icon: Icons.campaign_outlined,
              title: 'No auditions yet',
              subtitle:
                  'Post your first audition to start receiving applications.',
            );
          }

          return RefreshIndicator(
            onRefresh: () async {
              ref.invalidate(recruiterAuditionsProvider(userId));
            },
            child: ListView.builder(
              padding: const EdgeInsets.symmetric(vertical: 12),
              itemCount: auditions.length,
              itemBuilder: (context, index) {
                final audition = auditions[index];
                return _AuditionListCard(audition: audition);
              },
            ),
          );
        },
      ),
    );
  }
}

class _AuditionListCard extends StatelessWidget {
  final Audition audition;

  const _AuditionListCard({required this.audition});

  @override
  Widget build(BuildContext context) {
    final statusColor = switch (audition.status) {
      AuditionStatus.ACTIVE => AppColors.success,
      AuditionStatus.CLOSED => AppColors.error,
      AuditionStatus.CANCELLED => AppColors.textHint,
      AuditionStatus.DRAFT => AppColors.warning,
    };

    final statusLabel = switch (audition.status) {
      AuditionStatus.ACTIVE => 'Active',
      AuditionStatus.CLOSED => 'Closed',
      AuditionStatus.CANCELLED => 'Cancelled',
      AuditionStatus.DRAFT => 'Draft',
    };

    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
      elevation: 2,
      shadowColor: Colors.black.withValues(alpha: 0.08),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
      child: InkWell(
        onTap: () {
          context.pushNamed(
            RouteNames.applicantsList,
            pathParameters: {'auditionId': audition.id},
          );
        },
        borderRadius: BorderRadius.circular(14),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(
                    child: Text(
                      audition.title,
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.w600,
                          ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  const SizedBox(width: 8),
                  Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                    decoration: BoxDecoration(
                      color: statusColor.withValues(alpha: 0.12),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Text(
                      statusLabel,
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                        color: statusColor,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 14),
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                    decoration: BoxDecoration(
                      color: AppColors.primary.withValues(alpha: 0.06),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Icon(Icons.people_outline,
                            size: 16, color: AppColors.primary),
                        const SizedBox(width: 5),
                        Text(
                          '${audition.applicantCount} applicant${audition.applicantCount == 1 ? '' : 's'}',
                          style: const TextStyle(
                            fontSize: 13,
                            fontWeight: FontWeight.w500,
                            color: AppColors.textSecondary,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 10),
                  Icon(Icons.schedule,
                      size: 16,
                      color: audition.deadline!.isPast
                          ? AppColors.error
                          : AppColors.textSecondary),
                  const SizedBox(width: 4),
                  Text(
                    audition.deadline!.daysUntil,
                    style: TextStyle(
                      fontSize: 13,
                      color: audition.deadline!.isPast
                          ? AppColors.error
                          : AppColors.textSecondary,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              Container(
                padding: const EdgeInsets.only(top: 12),
                decoration: const BoxDecoration(
                  border: Border(top: BorderSide(color: AppColors.divider, width: 0.5)),
                ),
                child: Row(
                  children: [
                    const Icon(Icons.location_on_outlined,
                        size: 14, color: AppColors.textHint),
                    const SizedBox(width: 4),
                    Text(
                      audition.location ?? '',
                      style:
                          const TextStyle(fontSize: 12, color: AppColors.textHint),
                    ),
                    const Spacer(),
                    Text(
                      'Deadline: ${audition.deadline!.formattedDate}',
                      style:
                          const TextStyle(fontSize: 12, color: AppColors.textHint),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _ProfileTab extends StatelessWidget {
  const _ProfileTab();

  @override
  Widget build(BuildContext context) {
    return const RecruiterProfileScreen();
  }
}

class _SettingsTab extends ConsumerStatefulWidget {
  const _SettingsTab();

  @override
  ConsumerState<_SettingsTab> createState() => _SettingsTabState();
}

class _SettingsTabState extends ConsumerState<_SettingsTab> {
  bool _notificationsEnabled = true;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Settings'),
        backgroundColor: AppColors.primary,
        foregroundColor: Colors.white,
        elevation: 0,
        automaticallyImplyLeading: false,
      ),
      body: ListView(
        children: [
          const SizedBox(height: 16),
          _buildSectionHeader(context, 'Notifications'),
          SwitchListTile(
            title: const Text('Push Notifications'),
            subtitle: const Text('Receive alerts for new applications'),
            value: _notificationsEnabled,
            activeColor: AppColors.primary,
            onChanged: (value) {
              setState(() => _notificationsEnabled = value);
            },
          ),
          const Divider(height: 1),
          const SizedBox(height: 16),
          _buildSectionHeader(context, 'Account'),
          ListTile(
            leading: const Icon(Icons.email_outlined),
            title: const Text('Email'),
            subtitle: Text(
              ref.watch(authStateProvider).valueOrNull?.email ?? '',
            ),
          ),
          ListTile(
            leading: const Icon(Icons.lock_outline),
            title: const Text('Change Password'),
            trailing: const Icon(Icons.chevron_right),
            onTap: () {
              context.pushNamed(RouteNames.forgotPassword);
            },
          ),
          ListTile(
            leading: const Icon(Icons.privacy_tip_outlined),
            title: const Text('Privacy Policy'),
            trailing: const Icon(Icons.chevron_right),
            onTap: () {},
          ),
          ListTile(
            leading: const Icon(Icons.description_outlined),
            title: const Text('Terms of Service'),
            trailing: const Icon(Icons.chevron_right),
            onTap: () {},
          ),
          const Divider(height: 1),
          const SizedBox(height: 16),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: OutlinedButton.icon(
              onPressed: () async {
                final confirmed = await showDialog<bool>(
                  context: context,
                  builder: (ctx) => AlertDialog(
                    title: const Text('Logout'),
                    content:
                        const Text('Are you sure you want to log out?'),
                    actions: [
                      TextButton(
                        onPressed: () => Navigator.pop(ctx, false),
                        child: const Text('Cancel'),
                      ),
                      TextButton(
                        onPressed: () => Navigator.pop(ctx, true),
                        child: const Text(
                          'Logout',
                          style: TextStyle(color: AppColors.error),
                        ),
                      ),
                    ],
                  ),
                );

                if (confirmed == true && mounted) {
                  await ref.read(authNotifierProvider.notifier).signOut();
                  if (mounted) {
                    context.goNamed(RouteNames.login);
                  }
                }
              },
              icon: const Icon(Icons.logout, color: AppColors.error),
              label: const Text(
                'Logout',
                style: TextStyle(color: AppColors.error),
              ),
              style: OutlinedButton.styleFrom(
                side: const BorderSide(color: AppColors.error),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                padding: const EdgeInsets.symmetric(vertical: 14),
              ),
            ),
          ),
          const SizedBox(height: 32),
        ],
      ),
    );
  }

  Widget _buildSectionHeader(BuildContext context, String title) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      child: Text(
        title,
        style: Theme.of(context).textTheme.titleSmall?.copyWith(
              color: AppColors.textSecondary,
              fontWeight: FontWeight.w600,
            ),
      ),
    );
  }
}
