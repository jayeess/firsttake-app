import 'package:flutter/material.dart';
import '../../models/audition_model.dart';
import '../../utils/theme/app_colors.dart';
import '../../utils/extensions/string_extensions.dart';
import '../../utils/extensions/date_extensions.dart';

class AuditionCard extends StatelessWidget {
  final Audition audition;
  final VoidCallback? onTap;

  const AuditionCard({super.key, required this.audition, this.onTap});

  @override
  Widget build(BuildContext context) {
    final isExpired = audition.deadline?.isPast ?? false;

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
                  if (isExpired)
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                      decoration: BoxDecoration(
                        color: AppColors.errorLight,
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: const Text(
                        'Closed',
                        style: TextStyle(color: AppColors.error, fontSize: 12, fontWeight: FontWeight.w600),
                      ),
                    ),
                ],
              ),
              if (audition.companyName != null) ...[
                const SizedBox(height: 6),
                Row(
                  children: [
                    const Icon(Icons.business, size: 16, color: AppColors.primary),
                    const SizedBox(width: 6),
                    Text(
                      audition.companyName!,
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                            color: AppColors.textSecondary,
                            fontWeight: FontWeight.w500,
                          ),
                    ),
                  ],
                ),
              ],
              const SizedBox(height: 12),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: [
                  _buildChip(Icons.category, audition.category.displayCategory),
                  if (audition.location != null && audition.location!.isNotEmpty)
                    _buildChip(Icons.location_on_outlined, audition.location!),
                  if (audition.experienceLevel != null)
                    _buildChip(Icons.work_outline, audition.experienceLevel!.displayExperience),
                ],
              ),
              const SizedBox(height: 14),
              Container(
                padding: const EdgeInsets.only(top: 12),
                decoration: const BoxDecoration(
                  border: Border(top: BorderSide(color: AppColors.divider, width: 0.5)),
                ),
                child: Row(
                  children: [
                    if (audition.deadline != null) ...[
                      Icon(
                        Icons.schedule,
                        size: 16,
                        color: isExpired ? AppColors.error : AppColors.textHint,
                      ),
                      const SizedBox(width: 4),
                      Text(
                        audition.deadline!.daysUntil,
                        style: TextStyle(
                          fontSize: 13,
                          color: isExpired ? AppColors.error : AppColors.textHint,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                    const Spacer(),
                    if (audition.applicantCount > 0) ...[
                      const Icon(Icons.people_outline, size: 16, color: AppColors.textHint),
                      const SizedBox(width: 4),
                      Text(
                        '${audition.applicantCount} applicant${audition.applicantCount == 1 ? '' : 's'}',
                        style: const TextStyle(fontSize: 13, color: AppColors.textHint),
                      ),
                    ],
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildChip(IconData icon, String label) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: AppColors.primary.withValues(alpha: 0.06),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 14, color: AppColors.primary),
          const SizedBox(width: 5),
          Text(label, style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w500, color: AppColors.textSecondary)),
        ],
      ),
    );
  }
}
