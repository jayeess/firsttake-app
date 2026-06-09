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
      elevation: 2,
      shadowColor: Colors.black.withValues(alpha: 0.08),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(14),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            children: [
              Row(
                children: [
                  ProfilePhotoWidget(
                    photoUrl: application.talentPhotoUrl,
                    initials: application.talentName?.isNotEmpty == true
                        ? application.talentName![0].toUpperCase()
                        : '?',
                    size: 52,
                  ),
                  const SizedBox(width: 14),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          application.talentName ?? 'Unknown',
                          style: Theme.of(context).textTheme.titleMedium?.copyWith(
                                fontWeight: FontWeight.w600,
                              ),
                        ),
                        const SizedBox(height: 4),
                        if (application.talentCategory != null)
                          Text(
                            application.talentCategory!,
                            style: Theme.of(context).textTheme.bodySmall?.copyWith(
                                  color: AppColors.primary,
                                  fontWeight: FontWeight.w500,
                                ),
                          ),
                        const SizedBox(height: 4),
                        Row(
                          children: [
                            const Icon(Icons.access_time, size: 13, color: AppColors.textHint),
                            const SizedBox(width: 3),
                            Text(
                              application.createdAt?.timeAgo ?? '',
                              style: const TextStyle(fontSize: 12, color: AppColors.textHint),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                  _buildStatusChip(application.status),
                ],
              ),
              if (application.status == 'APPLIED' || application.status == 'VIEWED') ...[
                const SizedBox(height: 12),
                Container(
                  padding: const EdgeInsets.only(top: 12),
                  decoration: const BoxDecoration(
                    border: Border(top: BorderSide(color: AppColors.divider, width: 0.5)),
                  ),
                  child: Row(
                    children: [
                      Expanded(
                        child: OutlinedButton.icon(
                          onPressed: onShortlist,
                          icon: const Icon(Icons.star_outline_rounded, size: 18),
                          label: const Text('Shortlist'),
                          style: OutlinedButton.styleFrom(
                            foregroundColor: AppColors.shortlisted,
                            side: const BorderSide(color: AppColors.shortlisted, width: 1.2),
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                            padding: const EdgeInsets.symmetric(vertical: 10),
                          ),
                        ),
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: OutlinedButton.icon(
                          onPressed: onReject,
                          icon: const Icon(Icons.close_rounded, size: 18),
                          label: const Text('Reject'),
                          style: OutlinedButton.styleFrom(
                            foregroundColor: AppColors.rejected,
                            side: BorderSide(color: AppColors.rejected.withValues(alpha: 0.5), width: 1.2),
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                            padding: const EdgeInsets.symmetric(vertical: 10),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildStatusChip(String status) {
    final (color, bgColor, label) = switch (status) {
      'APPLIED' => (AppColors.applied, AppColors.infoLight, 'Applied'),
      'VIEWED' => (AppColors.viewed, AppColors.warningLight, 'Viewed'),
      'SHORTLISTED' => (AppColors.shortlisted, AppColors.successLight, 'Shortlisted'),
      'REJECTED' => (AppColors.rejected, AppColors.errorLight, 'Rejected'),
      _ => (AppColors.textSecondary, AppColors.surfaceVariant, status),
    };

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(
        label,
        style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: color),
      ),
    );
  }
}
