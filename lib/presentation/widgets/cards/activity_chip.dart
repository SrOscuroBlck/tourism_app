import 'package:flutter/material.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_text_styles.dart';

class ActivityChip extends StatelessWidget {
  final String label;
  final IconData icon;
  final bool selected;
  final VoidCallback? onTap;

  const ActivityChip({
    Key? key,
    required this.label,
    required this.icon,
    this.selected = false,
    this.onTap,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return ChoiceChip(
      label: Text(
        label,
        style: AppTextStyles.bodyMedium.copyWith(
          color: selected ? AppColors.textLight : AppColors.textPrimary,
        ),
      ),
      avatar: Icon(
        icon,
        size: 18,
        color: selected ? AppColors.textLight : AppColors.textPrimary,
      ),
      selected: selected,
      onSelected: (_) => onTap?.call(),
      backgroundColor: AppColors.chipBackground,
      selectedColor: AppColors.primary,
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      labelPadding: const EdgeInsets.symmetric(horizontal: 8),
    );
  }
}
