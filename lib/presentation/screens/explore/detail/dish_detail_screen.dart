// lib/presentation/screens/explore/dish_detail_screen.dart

import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../../domain/entities/dish.dart';
import '../../../widgets/common/custom_app_bar.dart';

class DishDetailScreen extends StatelessWidget {
  final Dish dish;

  const DishDetailScreen({
    super.key,
    required this.dish,
  });

  @override
  Widget build(BuildContext context) {
    // Format price as currency (e.g., "$12.50")
    final formattedPrice = NumberFormat.simpleCurrency().format(dish.price);

    return Scaffold(
      appBar: CustomAppBar(
        title: dish.name,
        automaticallyImplyLeading: true,
      ),
      backgroundColor: AppColors.background,
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // ─── Dish Image ─────────────────────────────────────────
            Card(
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              elevation: 4,
              clipBehavior: Clip.antiAlias,
              child: dish.imageUrl != null && dish.imageUrl!.isNotEmpty
                  ? Image.network(
                dish.imageUrl!,
                height: 220,
                width: double.infinity,
                fit: BoxFit.cover,
                errorBuilder: (context, error, stackTrace) {
                  return Container(
                    height: 220,
                    color: AppColors.surface,
                    child: const Center(
                      child: Icon(
                        Icons.fastfood,
                        size: 80,
                        color: AppColors.textSecondary,
                      ),
                    ),
                  );
                },
              )
                  : Container(
                height: 220,
                color: AppColors.surface,
                child: const Center(
                  child: Icon(
                    Icons.fastfood,
                    size: 80,
                    color: AppColors.textSecondary,
                  ),
                ),
              ),
            ),
            const SizedBox(height: 24),

            // ─── Name & Price ────────────────────────────────────────
            Center(
              child: Column(
                children: [
                  Text(
                    dish.name,
                    style: AppTextStyles.headlineLarge,
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 8),
                  Text(
                    formattedPrice,
                    style: AppTextStyles.titleMedium
                        ?.copyWith(color: AppColors.primary),
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),
            const Divider(color: AppColors.surface, height: 1),
            const SizedBox(height: 24),

            // ─── Description ─────────────────────────────────────────
            if (dish.description != null && dish.description!.isNotEmpty)
              _DetailCard(
                icon: Icons.description,
                title: 'Description',
                content: dish.description!,
              ),

            // ─── Place │ Country Info ─────────────────────────────────
            if (dish.place != null || dish.country != null)
              _DetailCard(
                icon: Icons.location_on,
                title: 'Available At',
                content: [
                  if (dish.place != null) 'Place: ${dish.place!.name}',
                  if (dish.country != null) 'Country: ${dish.country!.name}',
                ].join('\n'),
                isMultiline: true,
              ),

            const SizedBox(height: 24),
          ],
        ),
      ),
    );
  }
}

/// A reusable card widget for showing icon + title + content text.
class _DetailCard extends StatelessWidget {
  final IconData icon;
  final String title;
  final String content;
  final bool isMultiline;

  const _DetailCard({
    required this.icon,
    required this.title,
    required this.content,
    this.isMultiline = false,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      color: AppColors.surface,
      elevation: 2,
      margin: const EdgeInsets.only(bottom: 16),
      child: Padding(
        padding: const EdgeInsets.symmetric(
          vertical: 16,
          horizontal: 12,
        ),
        child: Row(
          crossAxisAlignment:
          isMultiline ? CrossAxisAlignment.start : CrossAxisAlignment.center,
          children: [
            Icon(icon, size: 24, color: AppColors.primary),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: AppTextStyles.titleSmall,
                  ),
                  const SizedBox(height: 6),
                  Text(
                    content,
                    style: AppTextStyles.bodyMedium,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
