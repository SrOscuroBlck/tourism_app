import 'package:flutter/material.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_text_styles.dart';
import '../../../domain/entities/visit.dart';
import '../../../domain/repositories/visit_repository.dart';
import '../../../injection_container.dart';
import '../../widgets/common/loading_widget.dart';
import '../../widgets/common/error_widget.dart' as AppError;
import '../../widgets/common/custom_app_bar.dart';
import 'visit_detail_screen.dart';

class VisitedPlacesScreen extends StatefulWidget {
  const VisitedPlacesScreen({Key? key}) : super(key: key);

  @override
  State<VisitedPlacesScreen> createState() => _VisitedPlacesScreenState();
}

class _VisitedPlacesScreenState extends State<VisitedPlacesScreen> {
  final VisitRepository _visitRepository = sl<VisitRepository>();

  bool _isLoading = true;
  String? _errorMessage;
  List<Visit> _visits = [];

  @override
  void initState() {
    super.initState();
    _loadVisits();
  }

  Future<void> _loadVisits() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    final result = await _visitRepository.getUserVisits();
    result.fold(
          (failure) {
        setState(() {
          _errorMessage = failure.message ?? 'Failed to load visited places';
          _isLoading = false;
        });
      },
          (visits) {
        setState(() {
          _visits = visits;
          _isLoading = false;
        });
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: const CustomAppBar(
        title: 'Visited Places',
        automaticallyImplyLeading: true,
      ),
      backgroundColor: AppColors.background,
      body: Builder(builder: (_) {
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
                  onPressed: _loadVisits,
                  child: const Text('Retry'),
                ),
              ],
            ),
          );
        }

        if (_visits.isEmpty) {
          return const Center(
            child: Text('You haven’t visited any places yet'),
          );
        }

        return ListView.builder(
          padding: const EdgeInsets.symmetric(vertical: 16),
          itemCount: _visits.length,
          itemBuilder: (context, index) {
            final visit = _visits[index];
            final place = visit.place;
            final placeName = place?.name ?? 'Place #${visit.placeId}';
            final subtitle = (place != null && place.city != null)
                ? place.city!.name
                : null;

            // Format visitedAt
            final visitedDate =
                '${visit.visitedAt.day.toString().padLeft(2, '0')}/'
                '${visit.visitedAt.month.toString().padLeft(2, '0')}/'
                '${visit.visitedAt.year}';

            return Padding(
              padding: const EdgeInsets.symmetric(
                horizontal: 16,
                vertical: 8,
              ),
              child: Card(
                elevation: 2,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
                child: ListTile(
                  contentPadding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 12,
                  ),
                  // If there is a photoUrl, show a small circular thumbnail
                  leading: visit.photoUrl != null
                      ? ClipRRect(
                    borderRadius: BorderRadius.circular(4),
                    child: Image.network(
                      visit.photoUrl!,
                      width: 48,
                      height: 48,
                      fit: BoxFit.cover,
                      errorBuilder: (_, __, ___) => Container(
                        color: AppColors.surface,
                        width: 48,
                        height: 48,
                        child: const Icon(
                          Icons.broken_image,
                          color: AppColors.textHint,
                        ),
                      ),
                    ),
                  )
                      : Container(
                    width: 48,
                    height: 48,
                    decoration: BoxDecoration(
                      color: AppColors.surface,
                      borderRadius: BorderRadius.circular(4),
                    ),
                    child: const Icon(
                      Icons.photo_camera_outlined,
                      color: AppColors.textSecondary,
                    ),
                  ),
                  title: Text(placeName, style: AppTextStyles.bodyLarge),
                  subtitle: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      if (subtitle != null)
                        Text(subtitle, style: AppTextStyles.bodySmall),
                      const SizedBox(height: 4),
                      Text(visitedDate, style: AppTextStyles.bodySmall),
                    ],
                  ),
                  trailing: const Icon(Icons.chevron_right),
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => VisitDetailScreen(visit: visit),
                      ),
                    );
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
