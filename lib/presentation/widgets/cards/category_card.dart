// lib/presentation/widgets/cards/category_card.dart

import 'package:flutter/material.dart';
import '../../../core/theme/app_colors.dart';
import '../../widgets/common/loading_widget.dart';

class CategoryCard extends StatelessWidget {
  final String label;
  final String imageUrl;
  final VoidCallback? onTap;

  const CategoryCard({
    Key? key,
    required this.label,
    required this.imageUrl,
    this.onTap,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Circular container for category icon/image
          Container(
            width: 64,
            height: 64,
            decoration: BoxDecoration(
              color: AppColors.chipBackground,
              borderRadius: BorderRadius.circular(32),
            ),
            clipBehavior: Clip.antiAlias,
            child: imageUrl.isNotEmpty
                ? Image.network(
              imageUrl,
              fit: BoxFit.cover,
              errorBuilder: (_, __, ___) =>
              const Center(child: Icon(Icons.error_outline)),
              loadingBuilder: (_, child, progress) {
                if (progress == null) return child;
                return const Center(child: SizedBox(
                  width: 24,
                  height: 24,
                  child: CircularProgressIndicator(strokeWidth: 2),
                ));
              },
            )
                : const Icon(
              Icons.category,
              color: AppColors.textHint,
              size: 32,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            label,
            style: const TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }
}
