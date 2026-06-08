import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../providers/application_provider.dart';
import '../../providers/user_provider.dart';
import '../../models/application_model.dart';
import '../../utils/theme/app_colors.dart';
import '../../widgets/common/loading_indicator.dart';
import '../../widgets/recruiter/applicant_card.dart';

class ShortlistScreen extends ConsumerWidget {
  final String auditionId;

  const ShortlistScreen({super.key, required this.auditionId});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final applicationsAsync = ref.watch(auditionApplicationsProvider(auditionId));

    return Scaffold(
      appBar: AppBar(
        title: const Text('Shortlisted Candidates'),
        backgroundColor: AppColors.primary,
        foregroundColor: Colors.white,
      ),
      body: applicationsAsync.when(
        loading: () => const LoadingIndicator(message: 'Loading shortlist...'),
        error: (e, _) => Center(child: Text('Error: $e')),
        data: (applications) {
          final shortlisted = applications.where((a) => a.status == 'SHORTLISTED').toList();

          if (shortlisted.isEmpty) {
            return const EmptyState(
              icon: Icons.star_outline,
              title: 'No Shortlisted Candidates',
              subtitle: 'Shortlisted candidates will appear here.',
            );
          }

          return ListView.builder(
            padding: const EdgeInsets.symmetric(vertical: 8),
            itemCount: shortlisted.length,
            itemBuilder: (context, index) {
              final app = shortlisted[index];
              return ApplicantCard(
                application: app,
                onTap: () => context.pushNamed(
                  'applicant-detail',
                  pathParameters: {
                    'auditionId': auditionId,
                    'applicationId': app.id,
                  },
                ),
                onReject: () => _handleReject(context, ref, app),
              );
            },
          );
        },
      ),
    );
  }

  Future<void> _handleReject(BuildContext context, WidgetRef ref, Application app) async {
    final reason = await showDialog<String>(
      context: context,
      builder: (ctx) {
        final controller = TextEditingController();
        return AlertDialog(
          title: const Text('Remove from Shortlist'),
          content: TextField(
            controller: controller,
            decoration: const InputDecoration(
              hintText: 'Reason (optional)',
              border: OutlineInputBorder(),
            ),
            maxLines: 3,
          ),
          actions: [
            TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Cancel')),
            TextButton(
              onPressed: () => Navigator.pop(ctx, controller.text),
              child: const Text('Reject', style: TextStyle(color: AppColors.error)),
            ),
          ],
        );
      },
    );

    if (reason != null) {
      try {
        await ref.read(firestoreServiceProvider).updateApplicationStatus(
          auditionId,
          app.id,
          ApplicationStatus.REJECTED,
          reason: reason.isNotEmpty ? reason : null,
        );
        ref.invalidate(auditionApplicationsProvider(auditionId));
      } catch (e) {
        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Failed: $e'), backgroundColor: AppColors.error),
          );
        }
      }
    }
  }
}
