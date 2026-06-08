import 'package:flutter/material.dart';
import '../../models/application_model.dart';
import '../../utils/theme/app_colors.dart';
import '../../utils/extensions/date_extensions.dart';
import '../talent/profile_photo_widget.dart';

class ApplicantCard extends StatelessWidget {
  final Application application;
  final VoidCallback? onTap;
  final VoidCallback? onShortlist;
  final VoidCallback? onReject;

  const ApplicantCard({
    super.key,
    required this.application,
    this.onTap,
    this.onShortlist,
    this.onReject,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              ProfilePhotoWidget(
                photoUrl: application.talentPhotoUrl,
                initials: application.talentName?.isNotEmpty == true
                    ? application.talentName![0].toUpperCase()
                    : '?',
                size: 56,
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      application.talentName ?? 'Unknown',
                      style: Theme.of(context).textTheme.titleMedium,
                    ),
                    const SizedBox(height: 4),
                    if (application.talentCategory != null)
                      Text(
                        application.talentCategory!,
                        style: Theme.of(context).textTheme.bodySmall,
                      ),
                    const SizedBox(height: 4),
                    Text(
                      application.createdAt?.timeAgo ?? '',
                      style: const TextStyle(fontSize: 12, color: AppColors.textHint),
                    ),
                  ],
                ),
              ),
              Column(
                children: [
                  _buildStatusChip(application.status),
                  if (application.status == 'APPLIED' || application.status == 'VIEWED') ...[
                    const SizedBox(height: 8),
                    Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        _buildActionButton(
                          Icons.star_outline,
                          AppColors.shortlisted,
                          onShortlist,
                        ),
                        const SizedBox(width: 8),
                        _buildActionButton(
                          Icons.close,
                          AppColors.rejected,
                          onReject,
                        ),
                      ],
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

  Widget _buildStatusChip(String status) {
    final (color, bgColor) = switch (status) {
      'APPLIED' => (AppColors.applied, AppColors.infoLight),
      'VIEWED' => (AppColors.viewed, AppColors.warningLight),
      'SHORTLISTED' => (AppColors.shortlisted, AppColors.successLight),
      'REJECTED' => (AppColors.rejected, AppColors.errorLight),
      _ => (AppColors.textSecondary, AppColors.surfaceVariant),
    };

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(4),
      ),
      child: Text(
        status,
        style: TextStyle(fontSize: 11, fontWeight: FontWeight.w600, color: color),
      ),
    );
  }

  Widget _buildActionButton(IconData icon, Color color, VoidCallback? onTap) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(8),
      child: Container(
        padding: const EdgeInsets.all(6),
        decoration: BoxDecoration(
          border: Border.all(color: color.withValues(alpha: 0.3)),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Icon(icon, size: 18, color: color),
      ),
    );
  }
}
