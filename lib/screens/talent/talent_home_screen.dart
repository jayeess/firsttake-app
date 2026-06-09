import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../providers/auth_provider.dart';
import '../../routing/route_names.dart';
import '../../utils/theme/app_colors.dart';
import 'audition_list_screen.dart';
import 'my_applications_screen.dart';
import 'talent_profile_screen.dart';

class TalentHomeScreen extends ConsumerStatefulWidget {
  const TalentHomeScreen({super.key});

  @override
  ConsumerState<TalentHomeScreen> createState() => TalentHomeScreenState();
}

class TalentHomeScreenState extends ConsumerState<TalentHomeScreen> {
  int _currentIndex = 0;

  void switchToTab(int index) {
    setState(() => _currentIndex = index);
  }

  final List<Widget> _tabs = const [
    AuditionListScreen(),
    MyApplicationsScreen(),
    TalentProfileScreen(),
    _SettingsTab(),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: IndexedStack(
        index: _currentIndex,
        children: _tabs,
      ),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _currentIndex,
        onTap: (index) => setState(() => _currentIndex = index),
        type: BottomNavigationBarType.fixed,
        selectedItemColor: AppColors.primary,
        unselectedItemColor: AppColors.textHint,
        backgroundColor: AppColors.surface,
        elevation: 8,
        selectedFontSize: 12,
        unselectedFontSize: 12,
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.search),
            activeIcon: Icon(Icons.search),
            label: 'Browse',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.assignment_outlined),
            activeIcon: Icon(Icons.assignment),
            label: 'Applications',
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

class _SettingsTab extends ConsumerWidget {
  const _SettingsTab();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final authState = ref.watch(authStateProvider);
    final userEmail = authState.valueOrNull?.email ?? '';

    return Scaffold(
      appBar: AppBar(
        title: const Text('Settings'),
        backgroundColor: AppColors.primary,
        foregroundColor: Colors.white,
        automaticallyImplyLeading: false,
        elevation: 0,
      ),
      body: ListView(
        children: [
          const SizedBox(height: 16),
          _buildSectionHeader(context, 'Account'),
          ListTile(
            leading: const Icon(Icons.email_outlined, color: AppColors.primary),
            title: const Text('Email'),
            subtitle: Text(userEmail),
          ),
          ListTile(
            leading:
                const Icon(Icons.lock_outline, color: AppColors.primary),
            title: const Text('Change Password'),
            trailing: const Icon(Icons.chevron_right),
            onTap: () {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Password reset email will be sent.'),
                ),
              );
            },
          ),
          const Divider(height: 32),
          _buildSectionHeader(context, 'Profile'),
          ListTile(
            leading:
                const Icon(Icons.edit_outlined, color: AppColors.primary),
            title: const Text('Edit Profile'),
            trailing: const Icon(Icons.chevron_right),
            onTap: () => context.pushNamed(RouteNames.editTalentProfile),
          ),
          ListTile(
            leading: const Icon(Icons.photo_library_outlined,
                color: AppColors.primary),
            title: const Text('Manage Media'),
            trailing: const Icon(Icons.chevron_right),
            onTap: () => context.pushNamed(RouteNames.mediaUpload),
          ),
          const Divider(height: 32),
          _buildSectionHeader(context, 'Legal'),
          ListTile(
            leading:
                const Icon(Icons.privacy_tip_outlined, color: AppColors.primary),
            title: const Text('Privacy Policy'),
            trailing: const Icon(Icons.chevron_right, color: AppColors.textHint),
            onTap: () {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Privacy Policy coming soon.')),
              );
            },
          ),
          ListTile(
            leading:
                const Icon(Icons.info_outline, color: AppColors.primary),
            title: const Text('Terms of Service'),
            trailing: const Icon(Icons.chevron_right, color: AppColors.textHint),
            onTap: () {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Terms of Service coming soon.')),
              );
            },
          ),
          const Divider(height: 32),
          ListTile(
            leading: const Icon(Icons.logout, color: AppColors.error),
            title: const Text(
              'Sign Out',
              style: TextStyle(color: AppColors.error),
            ),
            onTap: () async {
              final shouldLogout = await showDialog<bool>(
                context: context,
                builder: (ctx) => AlertDialog(
                  title: const Text('Sign Out'),
                  content:
                      const Text('Are you sure you want to sign out?'),
                  actions: [
                    TextButton(
                      onPressed: () => Navigator.pop(ctx, false),
                      child: const Text('Cancel'),
                    ),
                    TextButton(
                      onPressed: () => Navigator.pop(ctx, true),
                      child: const Text(
                        'Sign Out',
                        style: TextStyle(color: AppColors.error),
                      ),
                    ),
                  ],
                ),
              );
              if (shouldLogout == true && context.mounted) {
                await ref.read(authNotifierProvider.notifier).signOut();
                if (context.mounted) {
                  context.goNamed(RouteNames.login);
                }
              }
            },
          ),
          const SizedBox(height: 24),
          Center(
            child: Text(
              'FirstTake v1.0.0',
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

  Widget _buildSectionHeader(BuildContext context, String title) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      child: Text(
        title.toUpperCase(),
        style: Theme.of(context).textTheme.labelSmall?.copyWith(
              color: AppColors.textHint,
              fontWeight: FontWeight.w600,
              letterSpacing: 1.2,
            ),
      ),
    );
  }
}
