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
                      audition.title,
                      style: Theme.of(context).textTheme.titleMedium,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  if (isExpired)
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                      decoration: BoxDecoration(
                        color: AppColors.errorLight,
                        borderRadius: BorderRadius.circular(4),
                      ),
                      child: const Text(
                        'Closed',
                        style: TextStyle(color: AppColors.error, fontSize: 12, fontWeight: FontWeight.w600),
                      ),
                    ),
                ],
              ),
              const SizedBox(height: 8),
              if (audition.companyName != null)
                Row(
                  children: [
                    const Icon(Icons.business, size: 16, color: AppColors.textSecondary),
                    const SizedBox(width: 4),
                    Text(
                      audition.companyName!,
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(color: AppColors.textSecondary),
                    ),
                  ],
                ),
              const SizedBox(height: 8),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: [
                  _buildChip(Icons.category, audition.category.displayCategory),
                  if (audition.location != null && audition.location!.isNotEmpty)
                    _buildChip(Icons.location_on, audition.location!),
                  if (audition.experienceLevel != null)
                    _buildChip(Icons.work, audition.experienceLevel!.displayExperience),
                ],
              ),
              const SizedBox(height: 12),
              Row(
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
                  if (audition.applicantCount > 0)
                    Text(
                      '${audition.applicantCount} applicant${audition.applicantCount == 1 ? '' : 's'}',
                      style: const TextStyle(fontSize: 13, color: AppColors.textHint),
                    ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildChip(IconData icon, String label) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: AppColors.surfaceVariant,
        borderRadius: BorderRadius.circular(6),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 14, color: AppColors.textSecondary),
          const SizedBox(width: 4),
          Text(label, style: const TextStyle(fontSize: 12, color: AppColors.textSecondary)),
        ],
      ),
    );
  }
}
