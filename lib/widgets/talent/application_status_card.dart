import 'package:flutter/material.dart';
import '../../models/application_model.dart';
import '../../utils/theme/app_colors.dart';
import '../../utils/extensions/date_extensions.dart';

class ApplicationStatusCard extends StatelessWidget {
  final Application application;
  final VoidCallback? onTap;

  const ApplicationStatusCard({super.key, required this.application, this.onTap});

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Expanded(
                    child: Text(
                      application.auditionTitle ?? 'Audition',
                      style: Theme.of(context).textTheme.titleMedium,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  _buildStatusBadge(application.status),
                ],
              ),
              const SizedBox(height: 12),
              _buildTimeline(application.status),
              const SizedBox(height: 12),
              Row(
                children: [
                  const Icon(Icons.access_time, size: 14, color: AppColors.textHint),
                  const SizedBox(width: 4),
                  Text(
                    'Applied ${application.createdAt?.timeAgo ?? ''}',
                    style: const TextStyle(fontSize: 12, color: AppColors.textHint),
                  ),
                  if (application.lastStatusChange != null) ...[
                    const SizedBox(width: 16),
                    Text(
                      'Updated ${application.lastStatusChange!.timeAgo}',
                      style: const TextStyle(fontSize: 12, color: AppColors.textHint),
                    ),
                  ],
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildStatusBadge(String status) {
    final (color, bgColor) = switch (status) {
      'APPLIED' => (AppColors.applied, AppColors.infoLight),
      'VIEWED' => (AppColors.viewed, AppColors.warningLight),
      'SHORTLISTED' => (AppColors.shortlisted, AppColors.successLight),
      'REJECTED' => (AppColors.rejected, AppColors.errorLight),
      _ => (AppColors.textSecondary, AppColors.surfaceVariant),
    };

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(6),
      ),
      child: Text(
        status.replaceAll('_', ' '),
        style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: color),
      ),
    );
  }

  Widget _buildTimeline(String currentStatus) {
    const steps = ['APPLIED', 'VIEWED', 'SHORTLISTED'];
    final currentIndex = steps.indexOf(currentStatus);
    final isRejected = currentStatus == 'REJECTED';

    return Row(
      children: List.generate(steps.length * 2 - 1, (index) {
        if (index.isOdd) {
          final stepIndex = index ~/ 2;
          final isActive = stepIndex < currentIndex;
          return Expanded(
            child: Container(
              height: 2,
              color: isActive ? AppColors.success : AppColors.divider,
            ),
          );
        }
        final stepIndex = index ~/ 2;
        final isActive = stepIndex <= currentIndex && !isRejected || (stepIndex == 0);
        final isCurrent = steps[stepIndex] == currentStatus;

        return Container(
          width: isCurrent ? 28 : 24,
          height: isCurrent ? 28 : 24,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: isRejected && isCurrent
                ? AppColors.error
                : isActive
                    ? AppColors.success
                    : AppColors.divider,
            border: isCurrent ? Border.all(color: AppColors.primary, width: 2) : null,
          ),
          child: Icon(
            isRejected && isCurrent
                ? Icons.close
                : isActive
                    ? Icons.check
                    : null,
            size: 14,
            color: Colors.white,
          ),
        );
      }),
    );
  }
}
