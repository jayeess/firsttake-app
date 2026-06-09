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
      elevation: 2,
      shadowColor: Colors.black.withValues(alpha: 0.08),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(14),
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
    final (color, bgColor, label) = switch (status) {
      'APPLIED' => (AppColors.applied, AppColors.infoLight, 'Applied'),
      'VIEWED' => (AppColors.viewed, AppColors.warningLight, 'Viewed'),
      'SHORTLISTED' => (AppColors.shortlisted, AppColors.successLight, 'Shortlisted'),
      'REJECTED' => (AppColors.rejected, AppColors.errorLight, 'Rejected'),
      _ => (AppColors.textSecondary, AppColors.surfaceVariant, status.replaceAll('_', ' ')),
    };

    final icon = switch (status) {
      'APPLIED' => Icons.send_rounded,
      'VIEWED' => Icons.visibility_rounded,
      'SHORTLISTED' => Icons.star_rounded,
      'REJECTED' => Icons.block_rounded,
      _ => Icons.circle,
    };

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 13, color: color),
          const SizedBox(width: 4),
          Text(
            label,
            style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: color),
          ),
        ],
      ),
    );
  }

  Widget _buildTimeline(String currentStatus) {
    const steps = ['APPLIED', 'VIEWED', 'SHORTLISTED'];
    const stepLabels = ['Applied', 'Viewed', 'Shortlisted'];
    final currentIndex = steps.indexOf(currentStatus);
    final isRejected = currentStatus == 'REJECTED';

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 4),
      child: Row(
        children: List.generate(steps.length * 2 - 1, (index) {
          if (index.isOdd) {
            final stepIndex = index ~/ 2;
            final isActive = stepIndex < currentIndex;
            return Expanded(
              child: Container(
                height: 3,
                margin: const EdgeInsets.symmetric(horizontal: 2),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(2),
                  color: isRejected
                      ? AppColors.divider
                      : isActive
                          ? AppColors.success
                          : AppColors.divider,
                ),
              ),
            );
          }
          final stepIndex = index ~/ 2;
          final isActive = stepIndex <= currentIndex && !isRejected || (stepIndex == 0);
          final isCurrent = steps[stepIndex] == currentStatus;

          return Column(
            children: [
              Container(
                width: isCurrent ? 28 : 22,
                height: isCurrent ? 28 : 22,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: isRejected && isCurrent
                      ? AppColors.error
                      : isActive
                          ? AppColors.success
                          : AppColors.surfaceVariant,
                  border: isCurrent
                      ? Border.all(
                          color: isRejected ? AppColors.error : AppColors.success,
                          width: 2.5,
                        )
                      : null,
                  boxShadow: isCurrent
                      ? [
                          BoxShadow(
                            color: (isRejected ? AppColors.error : AppColors.success).withValues(alpha: 0.25),
                            blurRadius: 6,
                            offset: const Offset(0, 2),
                          ),
                        ]
                      : null,
                ),
                child: Icon(
                  isRejected && isCurrent
                      ? Icons.close_rounded
                      : isActive
                          ? Icons.check_rounded
                          : null,
                  size: 13,
                  color: Colors.white,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                stepLabels[stepIndex],
                style: TextStyle(
                  fontSize: 10,
                  fontWeight: isCurrent ? FontWeight.w600 : FontWeight.w400,
                  color: isActive ? AppColors.textPrimary : AppColors.textHint,
                ),
              ),
            ],
          );
        }),
      ),
    );
  }
}
