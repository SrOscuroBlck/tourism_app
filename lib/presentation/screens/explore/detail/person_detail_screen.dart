// lib/presentation/screens/explore/detail/person_detail_screen.dart

import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:intl/intl.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../../domain/entities/person.dart';
import '../../../../domain/entities/tag.dart';
import '../../../../domain/repositories/tag_repository.dart';
import '../../../widgets/common/custom_app_bar.dart';
import '../../../widgets/common/loading_widget.dart';
import '../../../widgets/common/error_widget.dart' as AppError;
import '../../../../injection_container.dart';
import '../../tags/tag_detail_screen.dart';

class PersonDetailScreen extends StatefulWidget {
  final Person person;

  const PersonDetailScreen({
    Key? key,
    required this.person,
  }) : super(key: key);

  @override
  State<PersonDetailScreen> createState() => _PersonDetailScreenState();
}

class _PersonDetailScreenState extends State<PersonDetailScreen> {
  final TagRepository _tagRepo = sl<TagRepository>();
  final ImagePicker _picker = ImagePicker();
  final supabase = Supabase.instance.client;

  List<Tag> _tags = [];
  bool _isLoadingTags = false;
  String? _tagsError;

  bool _isAddingTag = false;
  String? _addTagError;

  @override
  void initState() {
    super.initState();
    _fetchTagsForPerson();
  }

  Future<void> _fetchTagsForPerson() async {
    setState(() {
      _isLoadingTags = true;
      _tagsError = null;
    });

    final result = await _tagRepo.getTagsByPerson(widget.person.id);
    result.fold(
          (failure) {
        setState(() {
          _tagsError = failure.message ?? 'Failed to load tags';
          _isLoadingTags = false;
        });
      },
          (tags) {
        setState(() {
          _tags = tags;
          _isLoadingTags = false;
        });
      },
    );
  }

  Future<void> _addTagFlow() async {
    if (_isAddingTag) return;

    // 1) Ask user for a comment
    final String? comment = await showDialog<String>(
      context: context,
      builder: (ctx) {
        String tempComment = '';
        return AlertDialog(
          title: const Text('Add a comment'),
          content: TextField(
            autofocus: true,
            decoration: const InputDecoration(
              hintText: 'Enter your comment…',
            ),
            onChanged: (value) => tempComment = value,
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(ctx).pop(null),
              child: const Text('Cancel'),
            ),
            ElevatedButton(
              onPressed: () => Navigator.of(ctx).pop(tempComment.trim()),
              child: const Text('OK'),
            ),
          ],
        );
      },
    );

    if (comment == null || comment.isEmpty) return;

    setState(() {
      _isAddingTag = true;
      _addTagError = null;
    });

    try {
      // 2) Launch camera
      final XFile? photo = await _picker.pickImage(source: ImageSource.camera);
      if (photo == null) {
        setState(() => _isAddingTag = false);
        return;
      }

      // 3) Read bytes
      final Uint8List bytes = await photo.readAsBytes();

      // 4) Choose a unique path
      final String filePath =
          'visit-photos/person_${widget.person.id}_${DateTime.now().millisecondsSinceEpoch}.jpg';

      // 5) Upload to Supabase
      await supabase.storage
          .from('visit-photos')
          .uploadBinary(filePath, bytes);

      // 6) Get public URL
      final String publicUrl =
      supabase.storage.from('visit-photos').getPublicUrl(filePath);

      // 7) Create Tag via repository
      final createResult = await _tagRepo.createTag(
        personId: widget.person.id,
        comment: comment,
        photoUrl: publicUrl,
        latitude: null,
        longitude: null,
      );

      createResult.fold(
            (failure) {
          setState(() {
            _addTagError =
            'Could not create tag: ${failure.message ?? 'Unknown error'}';
            _isAddingTag = false;
          });
        },
            (newTag) {
          setState(() {
            _tags.insert(0, newTag);
            _isAddingTag = false;
          });
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: const Text('Tag added successfully!'),
              backgroundColor: AppColors.success,
            ),
          );
        },
      );
    } catch (e) {
      setState(() {
        _addTagError = 'Failed to upload photo: ${e.toString()}';
        _isAddingTag = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    // Format birthDate (if non-null)
    String formattedBirthDate = '';
    if (widget.person.birthDate != null) {
      try {
        formattedBirthDate =
            DateFormat.yMMMMd().format(widget.person.birthDate!);
      } catch (_) {
        formattedBirthDate = widget.person.birthDate!.toIso8601String();
      }
    }

    return Scaffold(
      appBar: CustomAppBar(
        title: widget.person.name,
        automaticallyImplyLeading: true,
      ),
      backgroundColor: AppColors.background,
      body: Stack(
        children: [
          SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // ─── Person’s Image ─────────────────────────
                Card(
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  elevation: 4,
                  clipBehavior: Clip.antiAlias,
                  child: widget.person.imageUrl != null &&
                      widget.person.imageUrl!.isNotEmpty
                      ? Image.network(
                    widget.person.imageUrl!,
                    height: 220,
                    width: double.infinity,
                    fit: BoxFit.cover,
                    errorBuilder: (ctx, error, stackTrace) {
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

                // ─── Name & Category ────────────────────────
                Center(
                  child: Column(
                    children: [
                      Text(
                        widget.person.name,
                        style: AppTextStyles.headlineLarge,
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 8),
                      if (widget.person.category.isNotEmpty)
                        Text(
                          widget.person.category,
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

                // ─── Birth Date & Biography ─────────────────
                const SizedBox(height: 24),
                if (formattedBirthDate.isNotEmpty)
                  _DetailCard(
                    icon: Icons.cake,
                    title: 'Born On',
                    content: formattedBirthDate,
                  ),
                if (widget.person.biography != null &&
                    widget.person.biography!.isNotEmpty)
                  _DetailCard(
                    icon: Icons.read_more,
                    title: 'Biography',
                    content: widget.person.biography!,
                  ),

                // ─── Tags ───────────────────────────────────
                const SizedBox(height: 24),
                Text(
                  'Tags',
                  style: AppTextStyles.titleMedium,
                ),
                const SizedBox(height: 8),

                if (_isLoadingTags)
                  const Center(child: LoadingWidget(size: 32))
                else if (_tagsError != null)
                  Center(
                    child: Column(
                      children: [
                        AppError.ErrorWidget(message: _tagsError!),
                        const SizedBox(height: 8),
                        ElevatedButton(
                          onPressed: _fetchTagsForPerson,
                          child: const Text('Retry'),
                        ),
                      ],
                    ),
                  )
                else if (_tags.isEmpty)
                    const Center(child: Text('No tags yet'))
                  else
                    Column(
                      children: _tags.map((tag) {
                        return Padding(
                          padding: const EdgeInsets.only(bottom: 12.0),
                          child: GestureDetector(
                            onTap: () {
                              // Navigate to TagDetailScreen
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (_) => TagDetailScreen(tag: tag),
                                ),
                              );
                            },
                            child: Card(
                              color: AppColors.surface,
                              elevation: 2,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: Padding(
                                padding: const EdgeInsets.all(12.0),
                                child: Row(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    // Thumbnail of tag photo (if exists)
                                    if (tag.photoUrl != null &&
                                        tag.photoUrl!.isNotEmpty)
                                      ClipRRect(
                                        borderRadius: BorderRadius.circular(6),
                                        child: Image.network(
                                          tag.photoUrl!,
                                          width: 56,
                                          height: 56,
                                          fit: BoxFit.cover,
                                          errorBuilder: (_, __, ___) =>
                                              Container(
                                                width: 56,
                                                height: 56,
                                                color: AppColors.surface,
                                                child: const Icon(
                                                  Icons.broken_image,
                                                  size: 24,
                                                  color: AppColors.textHint,
                                                ),
                                              ),
                                        ),
                                      )
                                    else
                                      Container(
                                        width: 56,
                                        height: 56,
                                        decoration: BoxDecoration(
                                          color: AppColors.surface,
                                          borderRadius: BorderRadius.circular(6),
                                        ),
                                        child: const Icon(
                                          Icons.photo_camera_outlined,
                                          size: 32,
                                          color: AppColors.textSecondary,
                                        ),
                                      ),

                                    const SizedBox(width: 12),

                                    // Tag info (comment & meta)
                                    Expanded(
                                      child: Column(
                                        crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                        children: [
                                          // who created the tag
                                          Text(
                                            'By: ${tag.user?.name ?? 'Unknown User'}',
                                            style: AppTextStyles.bodySmall
                                                ?.copyWith(
                                              color: AppColors.textSecondary,
                                            ),
                                          ),

                                          const SizedBox(height: 4),

                                          // comment text
                                          Text(
                                            tag.comment,
                                            style: AppTextStyles.bodyMedium,
                                          ),

                                          // We removed any attempt to show "createdAt"—
                                          // because our Tag entity does NOT have that field.
                                          // Simply omit the “Tagged on …” line here.
                                        ],
                                      ),
                                    ),

                                    const Icon(
                                      Icons.chevron_right,
                                      color: AppColors.textSecondary,
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ),
                        );
                      }).toList(),
                    ),

                // ─── Location ───────────────────────────────
                const SizedBox(height: 24),
                if (widget.person.city != null || widget.person.country != null)
                  Card(
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    color: AppColors.surface,
                    elevation: 2,
                    child: Padding(
                      padding: const EdgeInsets.symmetric(
                          vertical: 16, horizontal: 12),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          if (widget.person.city != null) ...[
                            Row(
                              children: [
                                const Icon(
                                  Icons.location_city,
                                  color: AppColors.primary,
                                ),
                                const SizedBox(width: 12),
                                Flexible(
                                  child: Text(
                                    widget.person.city!.name,
                                    style: AppTextStyles.bodyMedium,
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 12),
                          ],
                          if (widget.person.country != null) ...[
                            Row(
                              children: [
                                const Icon(
                                  Icons.public,
                                  color: AppColors.primary,
                                ),
                                const SizedBox(width: 12),
                                Flexible(
                                  child: Text(
                                    widget.person.country!.name,
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

                const SizedBox(height: 80), // space for FAB
              ],
            ),
          ),

          // ─── “Add Tag” Floating Button ───────────────────
          Positioned(
            right: 16,
            bottom: 16,
            child: FloatingActionButton.extended(
              label: Text(
                _isAddingTag ? 'Adding…' : 'Add Tag',
                style: AppTextStyles.button?.copyWith(color: Colors.white),
              ),
              icon: const Icon(Icons.add, color: Colors.white),
              backgroundColor: AppColors.primary,
              onPressed: _isAddingTag ? null : _addTagFlow,
            ),
          ),

          // ─── Inline error if tagging failed ───────
          if (_addTagError != null)
            Positioned(
              left: 16,
              right: 16,
              bottom: 80,
              child: Container(
                padding:
                const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                decoration: BoxDecoration(
                  color: AppColors.error.withOpacity(0.1),
                  border: Border.all(color: AppColors.error),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  _addTagError!,
                  style: AppTextStyles.bodySmall
                      ?.copyWith(color: AppColors.error),
                  textAlign: TextAlign.center,
                ),
              ),
            ),
        ],
      ),
    );
  }
}

/// A small helper card for “icon + title + content”:
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
        padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 12),
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
