// lib/presentation/screens/tags/tag_detail_screen.dart

import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_text_styles.dart';
import '../../../domain/entities/tag.dart';
import '../../widgets/common/custom_app_bar.dart';

class TagDetailScreen extends StatelessWidget {
  final Tag tag;

  const TagDetailScreen({
    Key? key,
    required this.tag,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    // log the tag details for debugging
    print('Tag Details: $tag');
    final bool hasPhoto = tag.photoUrl != null && tag.photoUrl!.isNotEmpty;
    final String personName = tag.person?.name ?? 'Unknown Person';
    final String userName = tag.user?.name ?? 'Unknown User';

    return Scaffold(
      appBar: const CustomAppBar(
        title: 'Tag Details',
        automaticallyImplyLeading: true,
      ),
      backgroundColor: AppColors.background,
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // ─── Tag Photo / Placeholder ─────────────────────────────
            if (hasPhoto)
              AspectRatio(
                aspectRatio: 16 / 9,
                child: Image.network(
                  tag.photoUrl!,
                  fit: BoxFit.cover,
                  errorBuilder: (_, __, ___) => Container(
                    color: AppColors.surface,
                    child: const Center(
                      child: Icon(
                        Icons.broken_image,
                        size: 64,
                        color: AppColors.textHint,
                      ),
                    ),
                  ),
                ),
              )
            else
              Container(
                height: 200,
                color: AppColors.surface,
                child: const Center(
                  child: Icon(
                    Icons.photo_camera_outlined,
                    size: 64,
                    color: AppColors.textSecondary,
                  ),
                ),
              ),

            const SizedBox(height: 16),

            // ─── Padding Around Details ───────────────────────────────
            Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Tagged Person
                  Text(
                    'Person: $personName',
                    style: AppTextStyles.headlineMedium,
                  ),
                  const SizedBox(height: 8),

                  // Tagging User
                  Text(
                    'Tagged by: $userName',
                    style: AppTextStyles.bodyMedium
                        .copyWith(color: AppColors.textSecondary),
                  ),
                  const SizedBox(height: 16),

                  // Comment
                  Text(
                    'Comment:',
                    style: AppTextStyles.titleSmall,
                  ),
                  const SizedBox(height: 4),
                  Text(
                    tag.comment,
                    style: AppTextStyles.bodyMedium,
                  ),
                  const SizedBox(height: 16),

                  // ─── “Tagged At” removed because Tag has no createdAt ───

                  // Coordinates (if any)
                  if (tag.latitude != null && tag.longitude != null) ...[
                    Row(
                      children: [
                        const Icon(
                          Icons.map,
                          size: 20,
                          color: AppColors.textSecondary,
                        ),
                        const SizedBox(width: 8),
                        Text(
                          'Location: '
                              '${tag.latitude!.toStringAsFixed(4)}, '
                              '${tag.longitude!.toStringAsFixed(4)}',
                          style: AppTextStyles.bodyMedium
                              .copyWith(color: AppColors.textSecondary),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                  ],

                  // Photo URL (if you wish to display)
                  if (tag.photoUrl != null && tag.photoUrl!.isNotEmpty) ...[
                    Text(
                      'Photo URL:',
                      style: AppTextStyles.bodySmall
                          .copyWith(color: AppColors.textSecondary),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      tag.photoUrl!,
                      style: AppTextStyles.bodyMedium
                          .copyWith(color: AppColors.primary),
                    ),
                    const SizedBox(height: 16),
                  ],
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
