import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import '../../utils/theme/app_colors.dart';

class ProfilePhotoWidget extends StatelessWidget {
  final String? photoUrl;
  final String? initials;
  final double size;
  final VoidCallback? onTap;
  final bool showEditIcon;

  const ProfilePhotoWidget({
    super.key,
    this.photoUrl,
    this.initials,
    this.size = 80,
    this.onTap,
    this.showEditIcon = false,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Stack(
        children: [
          Container(
            width: size,
            height: size,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: AppColors.primaryLight.withValues(alpha: 0.2),
              border: Border.all(color: AppColors.divider, width: 2),
            ),
            child: ClipOval(
              child: photoUrl != null && photoUrl!.isNotEmpty
                  ? CachedNetworkImage(
                      imageUrl: photoUrl!,
                      fit: BoxFit.cover,
                      placeholder: (context, url) => _buildPlaceholder(),
                      errorWidget: (context, url, error) => _buildPlaceholder(),
                    )
                  : _buildPlaceholder(),
            ),
          ),
          if (showEditIcon)
            Positioned(
              bottom: 0,
              right: 0,
              child: Container(
                padding: const EdgeInsets.all(4),
                decoration: const BoxDecoration(
                  color: AppColors.primary,
                  shape: BoxShape.circle,
                ),
                child: const Icon(Icons.camera_alt, size: 16, color: Colors.white),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildPlaceholder() {
    return Center(
      child: initials != null
          ? Text(
              initials!,
              style: TextStyle(
                fontSize: size * 0.35,
                fontWeight: FontWeight.bold,
                color: AppColors.primary,
              ),
            )
          : Icon(Icons.person, size: size * 0.5, color: AppColors.primary),
    );
  }
}
