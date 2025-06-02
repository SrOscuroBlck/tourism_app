// lib/presentation/screens/tags/tags_list_screen.dart

import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_text_styles.dart';
import '../../../domain/entities/tag.dart';
import '../../../domain/repositories/tag_repository.dart';
import '../../../injection_container.dart';
import '../../widgets/common/custom_app_bar.dart';
import '../../widgets/common/loading_widget.dart';
import '../../widgets/common/error_widget.dart' as AppError;
import '../explore/detail/person_detail_screen.dart';

class UserTagsScreen extends StatefulWidget {
  const UserTagsScreen({Key? key}) : super(key: key);

  @override
  State<UserTagsScreen> createState() => _UserTagsScreenState();
}

class _UserTagsScreenState extends State<UserTagsScreen> {
  final TagRepository _tagRepo = sl<TagRepository>();

  bool _isLoading = true;
  String? _errorMessage;
  List<Tag> _tags = [];

  @override
  void initState() {
    super.initState();
    _loadUserTags();
  }

  Future<void> _loadUserTags() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    final result = await _tagRepo.getUserTags();
    result.fold(
          (failure) {
        setState(() {
          _errorMessage = failure.message ?? 'Failed to load your tags';
          _isLoading = false;
        });
      },
          (tags) {
        setState(() {
          _tags = tags;
          _isLoading = false;
        });
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: const CustomAppBar(
        title: 'My Tags',
        automaticallyImplyLeading: true,
      ),
      backgroundColor: AppColors.background,
      body: Builder(builder: (context) {
        if (_isLoading) {
          return const Center(child: LoadingWidget(size: 48));
        }

        if (_errorMessage != null) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                AppError.ErrorWidget(message: _errorMessage!),
                const SizedBox(height: 16),
                ElevatedButton(
                  onPressed: _loadUserTags,
                  child: const Text('Retry'),
                ),
              ],
            ),
          );
        }

        if (_tags.isEmpty) {
          return const Center(
            child: Text('You haven’t tagged anyone yet'),
          );
        }

        return ListView.builder(
          padding: const EdgeInsets.symmetric(vertical: 16),
          itemCount: _tags.length,
          itemBuilder: (context, index) {
            final tag = _tags[index];
            final person = tag.person;
            final personName = person?.name ?? 'Unknown Person';
            final comment = tag.comment;
            final photoUrl = tag.photoUrl ?? '';

            // Since Tag entity does not have a `createdAt`, we simply omit the date.
            // If you do have a timestamp field, replace the next line accordingly:
            final String taggedOnText = ''; // e.g. 'Tagged on ...'

            return Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              child: Card(
                elevation: 2,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
                child: ListTile(
                  contentPadding:
                  const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                  leading: photoUrl.isNotEmpty
                      ? ClipRRect(
                    borderRadius: BorderRadius.circular(6),
                    child: Image.network(
                      photoUrl,
                      width: 56,
                      height: 56,
                      fit: BoxFit.cover,
                      errorBuilder: (_, __, ___) => Container(
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
                      : Container(
                    width: 56,
                    height: 56,
                    color: AppColors.surface,
                    child: const Icon(
                      Icons.photo_camera_outlined,
                      size: 32,
                      color: AppColors.textSecondary,
                    ),
                  ),
                  title: Text(
                    personName,
                    style: AppTextStyles.bodyLarge,
                  ),
                  subtitle: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const SizedBox(height: 4),
                      Text(
                        comment,
                        style: AppTextStyles.bodySmall
                            ?.copyWith(color: AppColors.textSecondary),
                      ),
                      if (taggedOnText.isNotEmpty) ...[
                        const SizedBox(height: 4),
                        Text(
                          taggedOnText,
                          style: AppTextStyles.bodySmall
                              ?.copyWith(color: AppColors.textSecondary),
                        ),
                      ],
                    ],
                  ),
                  trailing: const Icon(Icons.chevron_right),
                  onTap: () {
                    if (person != null) {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) =>
                              PersonDetailScreen(person: person),
                        ),
                      );
                    }
                  },
                ),
              ),
            );
          },
        );
      }),
    );
  }
}
