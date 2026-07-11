import 'package:flutter/material.dart';
import '../../theme/app_colors.dart';
import '../../theme/app_typography.dart';

class AppButton extends StatelessWidget {
  final String text;
  final VoidCallback? onPressed;
  final bool isLoading;
  final bool isSecondary;

  const AppButton({
    required this.text,
    required this.onPressed,
    this.isLoading = false,
    this.isSecondary = false,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    if (isLoading) {
      return Center(
        child: CircularProgressIndicator(
          color: isSecondary ? AppColors.successText : AppColors.primary,
        ),
      );
    }

    final buttonStyle = ElevatedButton.styleFrom(
      backgroundColor: isSecondary ? AppColors.bgSurface : AppColors.primary,
      foregroundColor: AppColors.textPrimary,
      side: isSecondary ? const BorderSide(color: AppColors.borderDefault) : null,
    );

    return SizedBox(
      width: double.infinity,
      child: ElevatedButton(
        style: buttonStyle,
        onPressed: onPressed,
        child: Text(
          text,
          style: AppTypography.bodyLarge.copyWith(fontWeight: FontWeight.bold),
        ),
      ),
    );
  }
}
