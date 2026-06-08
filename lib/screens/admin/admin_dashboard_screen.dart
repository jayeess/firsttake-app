import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../models/user_model.dart';
import '../../models/audition_model.dart';
import '../../providers/user_provider.dart';
import '../../providers/auth_provider.dart';
import '../../utils/theme/app_colors.dart';
import '../../widgets/common/custom_button.dart';
import '../../widgets/common/custom_text_field.dart';
import '../../widgets/common/loading_indicator.dart';

import 'user_management_screen.dart';
import 'recruiter_verification_screen.dart';

// ---------------------------------------------------------------------------
// Providers scoped to the admin dashboard
// ---------------------------------------------------------------------------

final _adminStatsProvider =
    FutureProvider.autoDispose<Map<String, int>>((ref) async {
  return ref.read(firestoreServiceProvider).getAuditionStats();
});

final _pendingVerificationsCountProvider =
    FutureProvider.autoDispose<int>((ref) async {
  final pending =
      await ref.read(firestoreServiceProvider).getPendingRecruiters();
  return pending.length;
});

final _totalApplicationsCountProvider =
    FutureProvider.autoDispose<int>((ref) async {
  // Aggregate application counts from active auditions
  final auditions = await ref
      .read(firestoreServiceProvider)
      .getAllAuditions(limit: 1000);
  int total = 0;
  for (final a in auditions) {
    total += a.applicantCount;
  }
  return total;
});

// ---------------------------------------------------------------------------
// AdminDashboardScreen
// ---------------------------------------------------------------------------

class AdminDashboardScreen extends ConsumerStatefulWidget {
  const AdminDashboardScreen({super.key});

  @override
  ConsumerState<AdminDashboardScreen> createState() =>
      _AdminDashboardScreenState();
}

class _AdminDashboardScreenState extends ConsumerState<AdminDashboardScreen> {
  int _currentIndex = 0;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: IndexedStack(
        index: _currentIndex,
        children: const [
          _DashboardTab(),
          UserManagementScreen(),
          RecruiterVerificationScreen(),
          _SettingsTab(),
        ],
      ),
      bottomNavigationBar: NavigationBar(
        selectedIndex: _currentIndex,
        onDestinationSelected: (index) {
          setState(() => _currentIndex = index);
        },
        destinations: const [
          NavigationDestination(
            icon: Icon(Icons.dashboard_outlined),
            selectedIcon: Icon(Icons.dashboard),
            label: 'Dashboard',
          ),
          NavigationDestination(
            icon: Icon(Icons.people_outlined),
            selectedIcon: Icon(Icons.people),
            label: 'Users',
          ),
          NavigationDestination(
            icon: Icon(Icons.verified_user_outlined),
            selectedIcon: Icon(Icons.verified_user),
            label: 'Verification',
          ),
          NavigationDestination(
            icon: Icon(Icons.settings_outlined),
            selectedIcon: Icon(Icons.settings),
            label: 'Settings',
          ),
        ],
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// Dashboard tab content
// ---------------------------------------------------------------------------

class _DashboardTab extends ConsumerWidget {
  const _DashboardTab();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final statsAsync = ref.watch(_adminStatsProvider);
    final pendingAsync = ref.watch(_pendingVerificationsCountProvider);
    final applicationsAsync = ref.watch(_totalApplicationsCountProvider);

    return SafeArea(
      child: RefreshIndicator(
        onRefresh: () async {
          ref.invalidate(_adminStatsProvider);
          ref.invalidate(_pendingVerificationsCountProvider);
          ref.invalidate(_totalApplicationsCountProvider);
        },
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            // Header
            Row(
              children: [
                const CircleAvatar(
                  radius: 24,
                  backgroundColor: AppColors.primary,
                  child: Icon(Icons.admin_panel_settings,
                      color: Colors.white, size: 28),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Admin Dashboard',
                        style: Theme.of(context)
                            .textTheme
                            .headlineSmall
                            ?.copyWith(fontWeight: FontWeight.bold),
                      ),
                      Text(
                        'Manage your platform',
                        style: Theme.of(context)
                            .textTheme
                            .bodyMedium
                            ?.copyWith(color: AppColors.textSecondary),
                      ),
                    ],
                  ),
                ),
              ],
            ),

            const SizedBox(height: 24),

            // Stat cards grid
            statsAsync.when(
              data: (stats) {
                final pendingCount = pendingAsync.valueOrNull ?? 0;
                final totalApps = applicationsAsync.valueOrNull ?? 0;

                return GridView.count(
                  crossAxisCount: 2,
                  mainAxisSpacing: 12,
                  crossAxisSpacing: 12,
                  childAspectRatio: 1.5,
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  children: [
                    _StatCard(
                      title: 'Total Users',
                      value: '${stats['totalUsers'] ?? 0}',
                      icon: Icons.people,
                      color: AppColors.primary,
                      backgroundColor: AppColors.infoLight,
                    ),
                    _StatCard(
                      title: 'Active Auditions',
                      value: '${stats['activeAuditions'] ?? 0}',
                      icon: Icons.campaign,
                      color: AppColors.success,
                      backgroundColor: AppColors.successLight,
                    ),
                    _StatCard(
                      title: 'Pending Verifications',
                      value: '$pendingCount',
                      icon: Icons.pending_actions,
                      color: AppColors.warning,
                      backgroundColor: AppColors.warningLight,
                    ),
                    _StatCard(
                      title: 'Total Applications',
                      value: '$totalApps',
                      icon: Icons.description,
                      color: AppColors.secondary,
                      backgroundColor: const Color(0xFFFFF3E0),
                    ),
                  ],
                );
              },
              loading: () => const SizedBox(
                height: 200,
                child: LoadingIndicator(message: 'Loading stats...'),
              ),
              error: (e, _) => Card(
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    children: [
                      const Icon(Icons.error_outline,
                          color: AppColors.error, size: 48),
                      const SizedBox(height: 8),
                      Text('Failed to load stats',
                          style: Theme.of(context).textTheme.bodyLarge),
                      const SizedBox(height: 4),
                      Text('$e',
                          style: Theme.of(context)
                              .textTheme
                              .bodySmall
                              ?.copyWith(color: AppColors.textSecondary)),
                      const SizedBox(height: 12),
                      CustomButton(
                        label: 'Retry',
                        variant: ButtonVariant.outline,
                        width: 120,
                        onPressed: () {
                          ref.invalidate(_adminStatsProvider);
                          ref.invalidate(_pendingVerificationsCountProvider);
                          ref.invalidate(_totalApplicationsCountProvider);
                        },
                      ),
                    ],
                  ),
                ),
              ),
            ),

            const SizedBox(height: 24),

            // Quick actions
            Text(
              'Quick Actions',
              style: Theme.of(context)
                  .textTheme
                  .titleMedium
                  ?.copyWith(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  child: _QuickActionCard(
                    icon: Icons.people,
                    label: 'Manage Users',
                    color: AppColors.primary,
                    onTap: () {
                      // Navigate to Users tab
                      final state = context.findAncestorStateOfType<
                          _AdminDashboardScreenState>();
                      state?.setState(() => state._currentIndex = 1);
                    },
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _QuickActionCard(
                    icon: Icons.verified_user,
                    label: 'Verification Queue',
                    color: AppColors.warning,
                    onTap: () {
                      final state = context.findAncestorStateOfType<
                          _AdminDashboardScreenState>();
                      state?.setState(() => state._currentIndex = 2);
                    },
                  ),
                ),
              ],
            ),

            const SizedBox(height: 24),

            // Recent activity section
            Text(
              'Recent Activity',
              style: Theme.of(context)
                  .textTheme
                  .titleMedium
                  ?.copyWith(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 12),
            _RecentActivityList(),
          ],
        ),
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// Stat Card
// ---------------------------------------------------------------------------

class _StatCard extends StatelessWidget {
  final String title;
  final String value;
  final IconData icon;
  final Color color;
  final Color backgroundColor;

  const _StatCard({
    required this.title,
    required this.value,
    required this.icon,
    required this.color,
    required this.backgroundColor,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 0,
      color: backgroundColor,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Icon(icon, color: color, size: 28),
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: color.withOpacity(0.15),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Icon(Icons.trending_up, color: color, size: 16),
                ),
              ],
            ),
            const Spacer(),
            Text(
              value,
              style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: color,
                  ),
            ),
            const SizedBox(height: 2),
            Text(
              title,
              style: Theme.of(context)
                  .textTheme
                  .bodySmall
                  ?.copyWith(color: AppColors.textSecondary),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ],
        ),
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// Quick Action Card
// ---------------------------------------------------------------------------

class _QuickActionCard extends StatelessWidget {
  final IconData icon;
  final String label;
  final Color color;
  final VoidCallback onTap;

  const _QuickActionCard({
    required this.icon,
    required this.label,
    required this.color,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: BorderSide(color: AppColors.border),
      ),
      child: InkWell(
        borderRadius: BorderRadius.circular(16),
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 16),
          child: Column(
            children: [
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: color.withOpacity(0.1),
                  shape: BoxShape.circle,
                ),
                child: Icon(icon, color: color, size: 28),
              ),
              const SizedBox(height: 12),
              Text(
                label,
                style: Theme.of(context)
                    .textTheme
                    .bodyMedium
                    ?.copyWith(fontWeight: FontWeight.w600),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// Recent Activity List (fetches recent users as activity proxy)
// ---------------------------------------------------------------------------

class _RecentActivityList extends ConsumerWidget {
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final statsAsync = ref.watch(_adminStatsProvider);

    return statsAsync.when(
      data: (stats) {
        // Build mock activity entries from real stats
        final activities = <_ActivityItem>[
          _ActivityItem(
            icon: Icons.person_add,
            color: AppColors.success,
            title: 'Platform has ${stats['totalTalents'] ?? 0} talents registered',
            timestamp: 'Current',
          ),
          _ActivityItem(
            icon: Icons.business,
            color: AppColors.primary,
            title: '${stats['totalRecruiters'] ?? 0} recruiters on the platform',
            timestamp: 'Current',
          ),
          _ActivityItem(
            icon: Icons.campaign,
            color: AppColors.secondary,
            title: '${stats['activeAuditions'] ?? 0} active auditions posted',
            timestamp: 'Current',
          ),
          _ActivityItem(
            icon: Icons.archive,
            color: AppColors.textSecondary,
            title: '${stats['closedAuditions'] ?? 0} auditions closed',
            timestamp: 'Current',
          ),
        ];

        return Card(
          elevation: 0,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
            side: BorderSide(color: AppColors.border),
          ),
          child: ListView.separated(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            padding: const EdgeInsets.symmetric(vertical: 8),
            itemCount: activities.length,
            separatorBuilder: (_, __) =>
                const Divider(height: 1, indent: 72),
            itemBuilder: (context, index) {
              final item = activities[index];
              return ListTile(
                leading: Container(
                  width: 40,
                  height: 40,
                  decoration: BoxDecoration(
                    color: item.color.withOpacity(0.1),
                    shape: BoxShape.circle,
                  ),
                  child: Icon(item.icon, color: item.color, size: 20),
                ),
                title: Text(
                  item.title,
                  style: Theme.of(context).textTheme.bodyMedium,
                ),
                trailing: Text(
                  item.timestamp,
                  style: Theme.of(context)
                      .textTheme
                      .bodySmall
                      ?.copyWith(color: AppColors.textHint),
                ),
              );
            },
          ),
        );
      },
      loading: () =>
          const SizedBox(height: 100, child: LoadingIndicator()),
      error: (e, _) => Card(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Text('Failed to load activity: $e'),
        ),
      ),
    );
  }
}

class _ActivityItem {
  final IconData icon;
  final Color color;
  final String title;
  final String timestamp;

  const _ActivityItem({
    required this.icon,
    required this.color,
    required this.title,
    required this.timestamp,
  });
}

// ---------------------------------------------------------------------------
// Settings tab
// ---------------------------------------------------------------------------

class _SettingsTab extends ConsumerWidget {
  const _SettingsTab();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return SafeArea(
      child: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          Text(
            'Settings',
            style: Theme.of(context)
                .textTheme
                .headlineSmall
                ?.copyWith(fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 24),

          // Account section
          Text(
            'Account',
            style: Theme.of(context)
                .textTheme
                .titleMedium
                ?.copyWith(
                    fontWeight: FontWeight.w600,
                    color: AppColors.textSecondary),
          ),
          const SizedBox(height: 8),
          Card(
            elevation: 0,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
              side: BorderSide(color: AppColors.border),
            ),
            child: Column(
              children: [
                ListTile(
                  leading: const Icon(Icons.person_outline),
                  title: const Text('Admin Profile'),
                  trailing: const Icon(Icons.chevron_right),
                  onTap: () {},
                ),
                const Divider(height: 1, indent: 16, endIndent: 16),
                ListTile(
                  leading: const Icon(Icons.security_outlined),
                  title: const Text('Security'),
                  trailing: const Icon(Icons.chevron_right),
                  onTap: () {},
                ),
                const Divider(height: 1, indent: 16, endIndent: 16),
                ListTile(
                  leading: const Icon(Icons.notifications_outlined),
                  title: const Text('Notifications'),
                  trailing: const Icon(Icons.chevron_right),
                  onTap: () {},
                ),
              ],
            ),
          ),

          const SizedBox(height: 24),

          // Platform section
          Text(
            'Platform',
            style: Theme.of(context)
                .textTheme
                .titleMedium
                ?.copyWith(
                    fontWeight: FontWeight.w600,
                    color: AppColors.textSecondary),
          ),
          const SizedBox(height: 8),
          Card(
            elevation: 0,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
              side: BorderSide(color: AppColors.border),
            ),
            child: Column(
              children: [
                ListTile(
                  leading: const Icon(Icons.category_outlined),
                  title: const Text('Categories'),
                  trailing: const Icon(Icons.chevron_right),
                  onTap: () {},
                ),
                const Divider(height: 1, indent: 16, endIndent: 16),
                ListTile(
                  leading: const Icon(Icons.report_outlined),
                  title: const Text('Reported Content'),
                  trailing: const Icon(Icons.chevron_right),
                  onTap: () {},
                ),
                const Divider(height: 1, indent: 16, endIndent: 16),
                ListTile(
                  leading: const Icon(Icons.analytics_outlined),
                  title: const Text('Analytics'),
                  trailing: const Icon(Icons.chevron_right),
                  onTap: () {},
                ),
              ],
            ),
          ),

          const SizedBox(height: 32),

          // Sign out
          CustomButton(
            label: 'Sign Out',
            variant: ButtonVariant.danger,
            icon: Icons.logout,
            onPressed: () async {
              final confirm = await showDialog<bool>(
                context: context,
                builder: (ctx) => AlertDialog(
                  title: const Text('Sign Out'),
                  content:
                      const Text('Are you sure you want to sign out?'),
                  actions: [
                    TextButton(
                      onPressed: () => Navigator.of(ctx).pop(false),
                      child: const Text('Cancel'),
                    ),
                    TextButton(
                      onPressed: () => Navigator.of(ctx).pop(true),
                      child: const Text('Sign Out',
                          style: TextStyle(color: AppColors.error)),
                    ),
                  ],
                ),
              );
              if (confirm == true && context.mounted) {
                await ref.read(authNotifierProvider.notifier).signOut();
                if (context.mounted) {
                  context.go('/login');
                }
              }
            },
          ),

          const SizedBox(height: 16),

          Center(
            child: Text(
              'FirstTake Admin v1.0.0',
              style: Theme.of(context)
                  .textTheme
                  .bodySmall
                  ?.copyWith(color: AppColors.textHint),
            ),
          ),
          const SizedBox(height: 32),
        ],
      ),
    );
  }
}
