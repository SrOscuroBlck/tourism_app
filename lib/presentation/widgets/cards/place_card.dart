import 'package:flutter/material.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_text_styles.dart';
import '../../widgets/common/loading_widget.dart';
import '../../../domain/entities/place.dart';

class PlaceCard extends StatelessWidget {
  final Place place;
  final VoidCallback? onTap;
  final bool isFavorite;
  final VoidCallback? onFavoriteToggle;

  const PlaceCard({
    Key? key,
    required this.place,
    this.onTap,
    this.isFavorite = false,
    this.onFavoriteToggle,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.symmetric(vertical: 8.0, horizontal: 16.0),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Top image section
            ClipRRect(
              borderRadius: const BorderRadius.vertical(top: Radius.circular(16)),
              child: place.imageUrl != null
                  ? Image.network(
                place.imageUrl!,
                height: 160,
                width: double.infinity,
                fit: BoxFit.cover,
                loadingBuilder: (_, child, progress) {
                  if (progress == null) return child;
                  return const LoadingWidget(size: 48);
                },
                errorBuilder: (_, __, ___) => Container(
                  color: AppColors.inputBackground,
                  height: 160,
                  child: const Center(
                    child: Icon(Icons.broken_image, size: 40, color: AppColors.textHint),
                  ),
                ),
              )
                  : Container(
                height: 160,
                width: double.infinity,
                color: AppColors.inputBackground,
                child: const Center(
                  child: Icon(Icons.image_not_supported, size: 40, color: AppColors.textHint),
                ),
              ),
            ),

            // Title & subtitle
            Padding(
              padding: const EdgeInsets.all(12.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    place.name,
                    style: AppTextStyles.titleLarge,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 4),
                  Text(
                    '${place.city?.name ?? ''}, ${place.country?.name ?? ''}',
                    style: AppTextStyles.bodyMedium,
                  ),
                ],
              ),
            ),

            // Favorite button (if provided)
            if (onFavoriteToggle != null)
              Align(
                alignment: Alignment.topRight,
                child: IconButton(
                  icon: Icon(
                    isFavorite ? Icons.favorite : Icons.favorite_border,
                    color: isFavorite ? AppColors.error : AppColors.textHint,
                  ),
                  onPressed: onFavoriteToggle,
                ),
              ),
          ],
        ),
      ),
    );
  }
}
