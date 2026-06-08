import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../models/application_model.dart';
import '../../providers/application_provider.dart';
import '../../providers/user_provider.dart';
import '../../utils/theme/app_colors.dart';
import '../../utils/extensions/date_extensions.dart';
import '../../utils/extensions/string_extensions.dart';
import '../../widgets/common/custom_app_bar.dart';
import '../../widgets/common/loading_indicator.dart';
import '../../widgets/recruiter/applicant_card.dart';
import '../../routing/route_names.dart';

class ApplicantsListScreen extends ConsumerWidget {
  final String auditionId;

  const ApplicantsListScreen({super.key, required this.auditionId});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final applicationsAsync =
        ref.watch(auditionApplicationsProvider(auditionId));

    return DefaultTabController(
      length: 5,
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Applicants'),
          backgroundColor: AppColors.primary,
          foregroundColor: Colors.white,
          elevation: 0,
          actions: [
            IconButton(
              icon: const Icon(Icons.star),
              tooltip: 'View Shortlist',
              onPressed: () {
                context.pushNamed(
                  RouteNames.shortlist,
                  pathParameters: {'auditionId': auditionId},
                );
              },
            ),
            IconButton(
              icon: const Icon(Icons.edit),
              tooltip: 'Edit Audition',
              onPressed: () {
                context.pushNamed(
                  RouteNames.editAudition,
                  pathParameters: {'auditionId': auditionId},
                );
              },
            ),
          ],
          bottom: const TabBar(
            isScrollable: true,
            indicatorColor: Colors.white,
            labelColor: Colors.white,
            unselectedLabelColor: Colors.white70,
            tabs: [
              Tab(text: 'All'),
              Tab(text: 'Applied'),
              Tab(text: 'Viewed'),
              Tab(text: 'Shortlisted'),
              Tab(text: 'Rejected'),
            ],
          ),
        ),
        body: applicationsAsync.when(
          loading: () =>
              const LoadingIndicator(message: 'Loading applicants...'),
          error: (error, _) => Center(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(Icons.error_outline,
                    size: 48, color: AppColors.error),
                const SizedBox(height: 12),
                Text('Failed to load applicants: $error'),
                const SizedBox(height: 16),
                TextButton(
                  onPressed: () => ref.invalidate(
                      auditionApplicationsProvider(auditionId)),
                  child: const Text('Retry'),
                ),
              ],
            ),
          ),
          data: (applications) {
            return TabBarView(
              children: [
                _FilteredApplicantsList(
                  auditionId: auditionId,
                  applications: applications,
                  filter: null,
                  ref: ref,
                ),
                _FilteredApplicantsList(
                  auditionId: auditionId,
                  applications: applications,
                  filter: 'APPLIED',
                  ref: ref,
                ),
                _FilteredApplicantsList(
                  auditionId: auditionId,
                  applications: applications,
                  filter: 'VIEWED',
                  ref: ref,
                ),
                _FilteredApplicantsList(
                  auditionId: auditionId,
                  applications: applications,
                  filter: 'SHORTLISTED',
                  ref: ref,
                ),
                _FilteredApplicantsList(
                  auditionId: auditionId,
                  applications: applications,
                  filter: 'REJECTED',
                  ref: ref,
                ),
              ],
            );
          },
        ),
      ),
    );
  }
}

class _FilteredApplicantsList extends StatelessWidget {
  final String auditionId;
  final List<Application> applications;
  final String? filter;
  final WidgetRef ref;

  const _FilteredApplicantsList({
    required this.auditionId,
    required this.applications,
    required this.filter,
    required this.ref,
  });

  @override
  Widget build(BuildContext context) {
    final filtered = filter == null
        ? applications
        : applications.where((a) => a.status == filter).toList();

    if (filtered.isEmpty) {
      return EmptyState(
        icon: Icons.people_outline,
        title: filter == null
            ? 'No applicants yet'
            : 'No ${filter!.toLowerCase()} applicants',
        subtitle: filter == null
            ? 'Share your audition to receive applications.'
            : null,
      );
    }

    return RefreshIndicator(
      onRefresh: () async {
        ref.invalidate(auditionApplicationsProvider(auditionId));
      },
      child: ListView.builder(
        padding: const EdgeInsets.symmetric(vertical: 8),
        itemCount: filtered.length,
        itemBuilder: (context, index) {
          final application = filtered[index];
          return ApplicantCard(
            application: application,
            onTap: () {
              context.pushNamed(
                RouteNames.applicantDetail,
                pathParameters: {
                  'auditionId': auditionId,
                  'applicationId': application.id,
                },
              );
            },
            onShortlist: () =>
                _updateStatus(context, application, ApplicationStatus.SHORTLISTED),
            onReject: () =>
                _updateStatus(context, application, ApplicationStatus.REJECTED),
          );
        },
      ),
    );
  }

  Future<void> _updateStatus(
    BuildContext context,
    Application application,
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
