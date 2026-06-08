import 'package:flutter/material.dart';
import '../../utils/theme/app_colors.dart';

enum ButtonVariant { primary, secondary, outline, text, danger }

class CustomButton extends StatelessWidget {
  final String label;
  final VoidCallback? onPressed;
  final ButtonVariant variant;
  final bool isLoading;
  final IconData? icon;
  final double? width;
  final double height;

  const CustomButton({
    super.key,
    required this.label,
    this.onPressed,
    this.variant = ButtonVariant.primary,
    this.isLoading = false,
    this.icon,
    this.width,
    this.height = 48,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: width ?? double.infinity,
      height: height,
      child: switch (variant) {
        ButtonVariant.primary => _buildElevatedButton(
            backgroundColor: AppColors.primary,
            foregroundColor: Colors.white,
          ),
        ButtonVariant.secondary => _buildElevatedButton(
            backgroundColor: AppColors.secondary,
            foregroundColor: Colors.white,
          ),
        ButtonVariant.outline => _buildOutlinedButton(),
        ButtonVariant.text => _buildTextButton(),
        ButtonVariant.danger => _buildElevatedButton(
            backgroundColor: AppColors.error,
            foregroundColor: Colors.white,
          ),
      },
    );
  }

  Widget _buildElevatedButton({
    required Color backgroundColor,
    required Color foregroundColor,
  }) {
    return ElevatedButton(
      onPressed: isLoading ? null : onPressed,
      style: ElevatedButton.styleFrom(
        backgroundColor: backgroundColor,
        foregroundColor: foregroundColor,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        elevation: 0,
      ),
      child: _buildChild(foregroundColor),
    );
  }

  Widget _buildOutlinedButton() {
    return OutlinedButton(
      onPressed: isLoading ? null : onPressed,
      style: OutlinedButton.styleFrom(
        side: const BorderSide(color: AppColors.primary),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      ),
      child: _buildChild(AppColors.primary),
    );
  }

  Widget _buildTextButton() {
    return TextButton(
      onPressed: isLoading ? null : onPressed,
      child: _buildChild(AppColors.primary),
    );
  }

  Widget _buildChild(Color color) {
    if (isLoading) {
      return SizedBox(
        width: 20,
        height: 20,
        child: CircularProgressIndicator(strokeWidth: 2, color: color),
      );
    }
    if (icon != null) {
      return Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 20),
          const SizedBox(width: 8),
          Text(label, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600)),
        ],
      );
    }
    return Text(label, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600));
  }
}
