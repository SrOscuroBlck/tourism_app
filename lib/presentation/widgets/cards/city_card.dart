// lib/presentation/widgets/cards/city_card.dart

import 'package:flutter/material.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_text_styles.dart';

class CityCard extends StatelessWidget {
  final int cityId;
  final String name;
  final int? population;
  final double? latitude;
  final double? longitude;
  final VoidCallback? onTap;

  const CityCard({
    Key? key,
    required this.cityId,
    required this.name,
    this.population,
    this.latitude,
    this.longitude,
    this.onTap,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.circular(12),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 4,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(name, style: AppTextStyles.titleMedium),
            const SizedBox(height: 4),
            if (population != null)
              Text('Population: $population', style: AppTextStyles.bodySmall),
            const SizedBox(height: 4),
            Row(
              children: [
                const Icon(Icons.location_on, size: 14, color: AppColors.textSecondary),
                const SizedBox(width: 4),
                Text(
                  '${latitude?.toStringAsFixed(3) ?? '—'}, ${longitude?.toStringAsFixed(3) ?? '—'}',
                  style: AppTextStyles.bodySmall.copyWith(color: AppColors.textSecondary),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
