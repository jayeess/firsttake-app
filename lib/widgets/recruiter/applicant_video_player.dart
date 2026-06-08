import 'package:flutter/material.dart';
import '../../utils/theme/app_colors.dart';

class ApplicantVideoPlayer extends StatelessWidget {
  final String? videoUrl;
  final String? thumbnailUrl;

  const ApplicantVideoPlayer({super.key, this.videoUrl, this.thumbnailUrl});

  @override
  Widget build(BuildContext context) {
    if (videoUrl == null || videoUrl!.isEmpty) {
      return Container(
        height: 200,
        decoration: BoxDecoration(
          color: AppColors.surfaceVariant,
          borderRadius: BorderRadius.circular(12),
        ),
        child: const Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(Icons.videocam_off, size: 48, color: AppColors.textHint),
              SizedBox(height: 8),
              Text('No introduction video', style: TextStyle(color: AppColors.textHint)),
            ],
          ),
        ),
      );
    }

    return Container(
      height: 200,
      decoration: BoxDecoration(
        color: Colors.black,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Stack(
        alignment: Alignment.center,
        children: [
          if (thumbnailUrl != null)
            ClipRRect(
              borderRadius: BorderRadius.circular(12),
              child: Image.network(
                thumbnailUrl!,
                fit: BoxFit.cover,
                width: double.infinity,
                height: 200,
                errorBuilder: (_, __, ___) => const SizedBox(),
              ),
            ),
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.black.withValues(alpha: 0.3),
              shape: BoxShape.circle,
            ),
            child: const Icon(Icons.play_arrow, size: 48, color: Colors.white),
          ),
        ],
      ),
    );
  }
}
