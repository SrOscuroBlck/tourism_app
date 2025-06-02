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
      // We keep a small vertical margin so it doesn’t push too far outside a tight container:
      margin: const EdgeInsets.symmetric(vertical: 8.0, horizontal: 16.0),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          // ← Make the Column only take as much height as it strictly needs:
          mainAxisSize: MainAxisSize.min,
          children: [
            // ─── Top image section ───────────────────────────────────────────────
            ClipRRect(
              borderRadius: const BorderRadius.vertical(top: Radius.circular(16)),
              child: place.imageUrl != null
                  ? Image.network(
                place.imageUrl!,
                // ↓ Shrink from 160 → 100 so the entire card will now fit in ~180px total:
                height: 100,
                width: double.infinity,
                fit: BoxFit.cover,
                loadingBuilder: (_, child, progress) {
                  if (progress == null) return child;
                  return const LoadingWidget(size: 48);
                },
                errorBuilder: (_, __, ___) => Container(
                  color: AppColors.inputBackground,
                  height: 100,
                  child: const Center(
                    child: Icon(
                      Icons.broken_image,
                      size: 40,
                      color: AppColors.textHint,
                    ),
                  ),
                ),
              )
                  : Container(
                height: 100,
                width: double.infinity,
                color: AppColors.inputBackground,
                child: const Center(
                  child: Icon(
                    Icons.image_not_supported,
                    size: 40,
                    color: AppColors.textHint,
                  ),
                ),
              ),
            ),

            // ─── Title & subtitle ────────────────────────────────────────────────
            Padding(
              // ↓ reduce padding from 12 → 8 so less vertical space is used:
              padding: const EdgeInsets.all(8.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    place.name,
                    style: AppTextStyles.titleLarge,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 2),
                  Text(
                    '${place.city?.name ?? ''}, ${place.country?.name ?? ''}',
                    style: AppTextStyles.bodyMedium,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            ),

            // ─── Optional favorite button ────────────────────────────────────────
            if (onFavoriteToggle != null)
              Padding(
                // We wrap IconButton in some padding so it doesn’t push outside:
                padding: const EdgeInsets.only(right: 8.0, bottom: 8.0),
                child: Align(
                  alignment: Alignment.topRight,
                  child: IconButton(
                    icon: Icon(
                      isFavorite ? Icons.favorite : Icons.favorite_border,
                      color: isFavorite ? AppColors.error : AppColors.textHint,
                    ),
                    onPressed: onFavoriteToggle,
                    splashRadius: 20,
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}
