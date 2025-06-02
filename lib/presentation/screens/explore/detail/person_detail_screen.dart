// lib/presentation/screens/explore/person_detail_screen.dart

import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../../domain/entities/person.dart';
import '../../../widgets/common/custom_app_bar.dart';

class PersonDetailScreen extends StatelessWidget {
  final Person person;

  const PersonDetailScreen({
    super.key,
    required this.person,
  });

  @override
  Widget build(BuildContext context) {
    // Format birthDate (if non-null) using DateFormat
    String formattedBirthDate = '';
    if (person.birthDate != null) {
      try {
        formattedBirthDate = DateFormat.yMMMMd().format(person.birthDate!);
      } catch (_) {
        formattedBirthDate = person.birthDate!.toIso8601String();
      }
    }

    return Scaffold(
      appBar: CustomAppBar(
        title: person.name,
        automaticallyImplyLeading: true,
      ),
      backgroundColor: AppColors.background,
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // ─── Person’s Image ────────────────────────────────────
            Card(
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              elevation: 4,
              clipBehavior: Clip.antiAlias,
              child: person.imageUrl != null && person.imageUrl!.isNotEmpty
                  ? Image.network(
                person.imageUrl!,
                height: 220,
                width: double.infinity,
                fit: BoxFit.cover,
                errorBuilder: (context, error, stackTrace) {
                  return Container(
                    height: 220,
                    color: AppColors.surface,
                    child: const Center(
                      child: Icon(
                        Icons.person,
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
                    Icons.person,
                    size: 80,
                    color: AppColors.textSecondary,
                  ),
                ),
              ),
            ),
            const SizedBox(height: 24),

            // ─── Name & Category ──────────────────────────────────
            Center(
              child: Column(
                children: [
                  Text(
                    person.name,
                    style: AppTextStyles.headlineLarge,
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 8),
                  if (person.category.isNotEmpty)
                    Text(
                      person.category,
                      style: AppTextStyles.bodyMedium?.copyWith(
                        color: AppColors.primary,
                        fontWeight: FontWeight.w500,
                      ),
                      textAlign: TextAlign.center,
                    ),
                ],
              ),
            ),
            const SizedBox(height: 24),
            const Divider(height: 1, color: AppColors.surface),

            // ─── Birth Date │ Biography ─────────────────────────────
            const SizedBox(height: 24),
            if (formattedBirthDate.isNotEmpty)
              _DetailCard(
                icon: Icons.cake,
                title: 'Born On',
                content: formattedBirthDate,
              ),
            if (person.biography != null && person.biography!.isNotEmpty)
              _DetailCard(
                icon: Icons.read_more,
                title: 'Biography',
                content: person.biography!,
              ),

            // ─── Tags ───────────────────────────────────────────────
            if (person.tags != null && person.tags!.isNotEmpty) ...[
              const SizedBox(height: 16),
              Text(
                'Tags',
                style: AppTextStyles.titleMedium,
              ),
              const SizedBox(height: 8),
              Wrap(
                spacing: 8,
                runSpacing: 6,
                children: person.tags!
                    .map(
                      (tag) => Chip(
                    backgroundColor: AppColors.surface,
                    label: Text(
                      tag.toString(),
                      style: AppTextStyles.bodySmall,
                    ),
                  ),
                )
                    .toList(),
              ),
            ],

            // ─── Location ───────────────────────────────────────────
            const SizedBox(height: 24),
            if (person.city != null || person.country != null)
              Card(
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                color: AppColors.surface,
                elevation: 2,
                child: Padding(
                  padding: const EdgeInsets.symmetric(
                    vertical: 16,
                    horizontal: 12,
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      if (person.city != null) ...[
                        Row(
                          children: [
                            const Icon(
                              Icons.location_city,
                              color: AppColors.primary,
                            ),
                            const SizedBox(width: 12),
                            Flexible(
                              child: Text(
                                person.city!.name,
                                style: AppTextStyles.bodyMedium,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 12),
                      ],
                      if (person.country != null) ...[
                        Row(
                          children: [
                            const Icon(
                              Icons.public,
                              color: AppColors.primary,
                            ),
                            const SizedBox(width: 12),
                            Flexible(
                              child: Text(
                                person.country!.name,
                                style: AppTextStyles.bodyMedium,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ],
                  ),
                ),
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

  const _DetailCard({
    required this.icon,
    required this.title,
    required this.content,
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
          crossAxisAlignment: CrossAxisAlignment.start,
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
