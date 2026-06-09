import 'package:flutter/material.dart';
import '../../utils/theme/app_colors.dart';

enum ButtonVariant { primary, secondary, outline, text, danger }

class CustomButton extends StatefulWidget {
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
    this.height = 52,
  });

  @override
  State<CustomButton> createState() => _CustomButtonState();
}

class _CustomButtonState extends State<CustomButton>
    with SingleTickerProviderStateMixin {
  late final AnimationController _scaleController;
  late final Animation<double> _scaleAnimation;

  @override
  void initState() {
    super.initState();
    _scaleController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 100),
    );
    _scaleAnimation = Tween<double>(begin: 1.0, end: 0.96).animate(
      CurvedAnimation(parent: _scaleController, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _scaleController.dispose();
    super.dispose();
  }

  bool get _isEnabled =>
      !widget.isLoading && widget.onPressed != null;

  void _onTapDown(TapDownDetails details) {
    if (_isEnabled) _scaleController.forward();
  }

  void _onTapUp(TapUpDetails details) {
    _scaleController.reverse();
  }

  void _onTapCancel() {
    _scaleController.reverse();
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTapDown: _onTapDown,
      onTapUp: _onTapUp,
      onTapCancel: _onTapCancel,
      child: ScaleTransition(
        scale: _scaleAnimation,
        child: SizedBox(
          width: widget.width ?? double.infinity,
          height: widget.height,
          child: switch (widget.variant) {
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
        ),
      ),
    );
  }

  Widget _buildElevatedButton({
    required Color backgroundColor,
    required Color foregroundColor,
  }) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 200),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(14),
        boxShadow: _isEnabled
            ? [
                BoxShadow(
                  color: backgroundColor.withValues(alpha: 0.35),
                  blurRadius: 12,
                  offset: const Offset(0, 5),
                ),
                BoxShadow(
                  color: backgroundColor.withValues(alpha: 0.15),
                  blurRadius: 4,
                  offset: const Offset(0, 2),
                ),
              ]
            : null,
      ),
      child: ElevatedButton(
        onPressed: widget.isLoading ? null : widget.onPressed,
        style: ElevatedButton.styleFrom(
          backgroundColor: backgroundColor,
          foregroundColor: foregroundColor,
          disabledBackgroundColor: backgroundColor.withValues(alpha: 0.45),
          disabledForegroundColor: foregroundColor.withValues(alpha: 0.7),
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
          elevation: 0,
          padding: const EdgeInsets.symmetric(horizontal: 24),
        ),
        child: _buildChild(foregroundColor),
      ),
    );
  }

  Widget _buildOutlinedButton() {
    return OutlinedButton(
      onPressed: widget.isLoading ? null : widget.onPressed,
      style: OutlinedButton.styleFrom(
        side: BorderSide(
          color: _isEnabled
              ? AppColors.primary
              : AppColors.primary.withValues(alpha: 0.4),
          width: 1.5,
        ),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
        padding: const EdgeInsets.symmetric(horizontal: 24),
      ),
      child: _buildChild(AppColors.primary),
    );
  }

  Widget _buildTextButton() {
    return TextButton(
      onPressed: widget.isLoading ? null : widget.onPressed,
      style: TextButton.styleFrom(
        padding: const EdgeInsets.symmetric(horizontal: 24),
      ),
      child: _buildChild(AppColors.primary),
    );
  }

  Widget _buildChild(Color color) {
    if (widget.isLoading) {
      return SizedBox(
        width: 22,
        height: 22,
        child: CircularProgressIndicator(
          strokeWidth: 2.5,
          color: color,
          strokeCap: StrokeCap.round,
        ),
      );
    }
    if (widget.icon != null) {
      return Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(widget.icon, size: 20),
          const SizedBox(width: 10),
          Text(widget.label,
              style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  letterSpacing: 0.3)),
        ],
      );
    }
    return Text(widget.label,
        style: const TextStyle(
            fontSize: 16, fontWeight: FontWeight.w600, letterSpacing: 0.3));
  }
}
