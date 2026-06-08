import 'package:flutter/material.dart';
import '../../utils/theme/app_colors.dart';

class ShortlistToggle extends StatelessWidget {
  final bool isShortlisted;
  final VoidCallback? onToggle;

  const ShortlistToggle({
    super.key,
    required this.isShortlisted,
    this.onToggle,
  });

  @override
  Widget build(BuildContext context) {
    return IconButton(
      onPressed: onToggle,
      icon: Icon(
        isShortlisted ? Icons.star : Icons.star_outline,
        color: isShortlisted ? AppColors.accent : AppColors.textHint,
        size: 28,
      ),
      tooltip: isShortlisted ? 'Remove from shortlist' : 'Add to shortlist',
    );
  }
}
