import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../models/application_model.dart';
import '../../providers/application_provider.dart';
import '../../providers/auth_provider.dart';
import '../../routing/route_names.dart';
import '../../utils/theme/app_colors.dart';
import '../../widgets/talent/application_status_card.dart';
import '../../widgets/common/loading_indicator.dart';

class MyApplicationsScreen extends ConsumerWidget {
  const MyApplicationsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final authState = ref.watch(authStateProvider);
    final currentUserId = authState.valueOrNull?.uid;

    if (currentUserId == null) {
      return const Scaffold(
        body: EmptyState(
          icon: Icons.login,
          title: 'Please sign in',
          subtitle: 'You need to be signed in to view your applications.',
        ),
      );
    }

    return _ApplicationsContent(userId: currentUserId);
  }
}

class _ApplicationsContent extends ConsumerWidget {
  final String userId;

  const _ApplicationsContent({required this.userId});

  static const _tabs = [
    'All',
    'Applied',
    'Viewed',
    'Shortlisted',
    'Rejected',
  ];

  static const _statusMap = {
    'Applied': 'APPLIED',
    'Viewed': 'VIEWED',
    'Shortlisted': 'SHORTLISTED',
    'Rejected': 'REJECTED',
  };

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final applicationsAsync =
        ref.watch(talentApplicationsProvider(userId));

    return DefaultTabController(
      length: _tabs.length,
      child: Scaffold(
        appBar: AppBar(
          title: const Text('My Applications'),
          backgroundColor: AppColors.primary,
          foregroundColor: Colors.white,
          automaticallyImplyLeading: false,
          elevation: 0,
          bottom: TabBar(
            isScrollable: true,
            indicatorColor: Colors.white,
            indicatorWeight: 3,
            labelColor: Colors.white,
            unselectedLabelColor: Colors.white70,
            labelStyle: const TextStyle(
                fontSize: 14, fontWeight: FontWeight.w600),
            unselectedLabelStyle: const TextStyle(fontSize: 14),
            tabAlignment: TabAlignment.start,
            tabs: _tabs.map((t) => Tab(text: t)).toList(),
          ),
        ),
        body: applicationsAsync.when(
          loading: () => const ShimmerList(),
          error: (error, stack) => EmptyState(
            icon: Icons.error_outline,
            title: 'Could not load applications',
            subtitle: 'Please try again later.',
            action: TextButton.icon(
              onPressed: () =>
                  ref.invalidate(talentApplicationsProvider(userId)),
              icon: const Icon(Icons.refresh),
              label: const Text('Retry'),
            ),
          ),
          data: (applications) {
            return TabBarView(
              children: _tabs.map((tab) {
                final filtered = tab == 'All'
                    ? applications
                    : applications
                        .where((a) => a.status == _statusMap[tab])
                        .toList();

                if (filtered.isEmpty) {
                  return _buildEmptyTabState(context, ref, tab);
                }

                return RefreshIndicator(
                  color: AppColors.primary,
                  onRefresh: () async {
                    ref.invalidate(talentApplicationsProvider(userId));
                  },
                  child: ListView.builder(
                    padding: const EdgeInsets.only(top: 8, bottom: 24),
                    itemCount: filtered.length,
                    itemBuilder: (context, index) {
                      final application = filtered[index];
                      return ApplicationStatusCard(
                        application: application,
                        onTap: () {
                          context.pushNamed(
                            RouteNames.auditionDetail,
                            pathParameters: {
                              'id': application.auditionId
                            },
                          );
                        },
                      );
                    },
                  ),
                );
              }).toList(),
            );
          },
        ),
      ),
    );
  }

  Widget _buildEmptyTabState(
      BuildContext context, WidgetRef ref, String tab) {
    final (icon, title, subtitle) = switch (tab) {
      'All' => (
          Icons.assignment_outlined,
          'No applications yet',
          'Start browsing auditions and apply for opportunities that match your talent.'
        ),
      'Applied' => (
          Icons.send_outlined,
          'No pending applications',
          'Applications you submit will appear here.'
        ),
      'Viewed' => (
          Icons.visibility_outlined,
          'No viewed applications',
          'When a recruiter views your application, it will show here.'
        ),
      'Shortlisted' => (
          Icons.star_outline,
          'No shortlisted applications',
          'Applications that recruiters shortlist will appear here.'
        ),
      'Rejected' => (
          Icons.block_outlined,
          'No rejected applications',
          'Rejected applications will appear here.'
        ),
      _ => (
          Icons.assignment_outlined,
          'No applications',
          'Nothing to show.'
        ),
    };

    return EmptyState(
      icon: icon,
      title: title,
      subtitle: subtitle,
      action: tab == 'All'
          ? TextButton.icon(
              onPressed: () {
                // Navigate to browse tab - parent TalentHomeScreen handles this
              },
              icon: const Icon(Icons.search),
              label: const Text('Browse Auditions'),
            )
          : null,
    );
  }
}
