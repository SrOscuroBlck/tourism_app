// lib/presentation/widgets/cards/place_card.dart

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
    // We know our card is being laid out in a parent
    // that has a tight height of about ~140 px (for example,
    // a horizontal ListView with itemExtent: 140).
    // In order to prevent vertical overflow, we split the
    // Column into fixed-height image + Expanded “text + button” section.

    return Card(
      margin: const EdgeInsets.symmetric(vertical: 8.0, horizontal: 16.0),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16),
        child: SizedBox(
          // Force a fixed height that matches the parent’s expected height (≈140).
          // You can adjust this if your ListView or parent expects a different height.
          height: 140,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // ─── Top image section (fixed height) ────────────────────────────
              ClipRRect(
                borderRadius:
                const BorderRadius.vertical(top: Radius.circular(16)),
                child: place.imageUrl != null
                    ? Image.network(
                  place.imageUrl!,
                  height: 80, // shrink from 100 → 80 so we have space below
                  width: double.infinity,
                  fit: BoxFit.cover,
                  loadingBuilder: (_, child, progress) {
                    if (progress == null) return child;
                    return const LoadingWidget(size: 48);
                  },
                  errorBuilder: (_, __, ___) => Container(
                    color: AppColors.inputBackground,
                    height: 80,
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
                  height: 80,
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

              // ─── Bottom section: title/subtitle + (optional) favorite button ───
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.symmetric(
                      horizontal: 8.0, vertical: 4.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Title & subtitle (1 line each; will ellipsize if too long)
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
                      const Spacer(),

                      // Optional favorite button, aligned right at the bottom
                      if (onFavoriteToggle != null)
                        Align(
                          alignment: Alignment.centerRight,
                          child: IconButton(
                            icon: Icon(
                              isFavorite
                                  ? Icons.favorite
                                  : Icons.favorite_border,
                              color:
                              isFavorite ? AppColors.error : AppColors.textHint,
                            ),
                            onPressed: onFavoriteToggle,
                            splashRadius: 20,
                          ),
                        ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
