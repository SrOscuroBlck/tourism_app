import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_text_styles.dart';
import '../../../domain/entities/visit.dart';
import '../../widgets/common/custom_app_bar.dart';

class VisitDetailScreen extends StatefulWidget {
  final Visit visit;

  const VisitDetailScreen({
    Key? key,
    required this.visit,
  }) : super(key: key);

  @override
  State<VisitDetailScreen> createState() => _VisitDetailScreenState();
}

class _VisitDetailScreenState extends State<VisitDetailScreen> {
  late String _formattedDate;

  @override
  void initState() {
    super.initState();
    // Format the visit date/time however you like. Example: “July 21, 2024 – 14:30”
    _formattedDate = DateFormat.yMMMMd().add_Hm().format(widget.visit.visitedAt);
  }

  @override
  Widget build(BuildContext context) {
    final visit = widget.visit;
    final place = visit.place;

    return Scaffold(
      appBar: const CustomAppBar(
        title: 'Visit Details',
        automaticallyImplyLeading: true,
      ),
      backgroundColor: AppColors.background,
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // ─── Visit Photo / Placeholder ───────────────────────
            if (visit.photoUrl != null && visit.photoUrl!.isNotEmpty) ...[
              AspectRatio(
                aspectRatio: 16 / 9,
                child: Image.network(
                  visit.photoUrl!,
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
              ),
            ] else ...[
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
            ],

            // ─── Padding Around Details ─────────────────────────
            Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Place name (if loaded)
                  if (place != null)
                    Text(place.name, style: AppTextStyles.headlineMedium),
                  if (place != null) const SizedBox(height: 8),

                  // City & Country
                  if (place?.city != null)
                    Row(
                      children: [
                        const Icon(Icons.location_city,
                            size: 20, color: AppColors.textSecondary),
                        const SizedBox(width: 8),
                        Text(
                          place!.city!.name,
                          style: AppTextStyles.bodyMedium
                              .copyWith(color: AppColors.textSecondary),
                        ),
                      ],
                    ),
                  if (place?.country != null) const SizedBox(height: 4),
                  if (place?.country != null)
                    Row(
                      children: [
                        const Icon(Icons.public,
                            size: 20, color: AppColors.textSecondary),
                        const SizedBox(width: 8),
                        Text(
                          place!.country!.name,
                          style: AppTextStyles.bodyMedium
                              .copyWith(color: AppColors.textSecondary),
                        ),
                      ],
                    ),
                  const SizedBox(height: 16),

                  // Visited At
                  Row(
                    children: [
                      const Icon(Icons.calendar_today,
                          size: 20, color: AppColors.textSecondary),
                      const SizedBox(width: 8),
                      Text(
                        _formattedDate,
                        style: AppTextStyles.bodyMedium
                            .copyWith(color: AppColors.textSecondary),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),

                  // Coordinates of the visit (if any)
                  if (visit.latitude != null && visit.longitude != null) ...[
                    Row(
                      children: [
                        const Icon(Icons.map, size: 20, color: AppColors.textSecondary),
                        const SizedBox(width: 8),
                        Text(
                          'Coordinates: '
                              '${visit.latitude!.toStringAsFixed(4)}, '
                              '${visit.longitude!.toStringAsFixed(4)}',
                          style: AppTextStyles.bodyMedium
                              .copyWith(color: AppColors.textSecondary),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                  ],

                  // Photo URL (if you want to display as plain text)
                  if (visit.photoUrl != null) ...[
                    Text(
                      'Photo URL:',
                      style: AppTextStyles.bodySmall
                          .copyWith(color: AppColors.textSecondary),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      visit.photoUrl!,
                      style: AppTextStyles.bodyMedium
                          .copyWith(color: AppColors.primary),
                    ),
                    const SizedBox(height: 16),
                  ],

                  // ─── “Edit Photo” Button (placeholder) ─────────────────
                  // You can hook this up to image picker later.
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton.icon(
                      icon: const Icon(Icons.edit, color: Colors.white),
                      label: const Text('Edit Photo'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.primary,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                      onPressed: () {
                        // TODO: wire up a image picker or camera to update visit.photoUrl
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(content: Text('Edit Photo tapped')),
                        );
                      },
                    ),
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
