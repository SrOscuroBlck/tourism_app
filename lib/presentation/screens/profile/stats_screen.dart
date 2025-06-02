// lib/presentation/screens/profile/stats_screen.dart

import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_text_styles.dart';
import '../../../domain/entities/visit.dart';
import '../../../domain/entities/tag.dart';
import '../../../domain/repositories/visit_repository.dart';
import '../../../domain/repositories/tag_repository.dart';
import '../../../injection_container.dart';
import '../../widgets/common/custom_app_bar.dart';
import '../../widgets/common/loading_widget.dart';
import '../../widgets/common/error_widget.dart' as AppError;

class StatsScreen extends StatefulWidget {
  const StatsScreen({super.key});

  @override
  State<StatsScreen> createState() => _StatsScreenState();
}

class _StatsScreenState extends State<StatsScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  final VisitRepository _visitRepository = sl<VisitRepository>();
  final TagRepository _tagRepository = sl<TagRepository>();

  bool _isLoading = true;
  String? _errorMessage;

  // Visit Stats
  List<Visit> _visits = [];
  int _totalVisits = 0;
  int _uniquePlaces = 0;
  String _mostActiveMonth = 'N/A';
  String _firstVisitDate = 'N/A';
  String _lastVisitDate = 'N/A';
  Map<String, int> _visitsByMonth = {};
  Map<String, int> _visitsByCity = {};

  // Tag Stats
  List<Tag> _tags = [];
  int _totalTags = 0;
  int _uniquePeople = 0;
  String _mostTaggedCategory = 'N/A';
  Map<String, int> _tagsByCategory = {};
  Map<String, int> _tagsByCity = {};

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    _loadStats();
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  Future<void> _loadStats() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      await Future.wait([
        _loadVisitStats(),
        _loadTagStats(),
      ]);

      setState(() {
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _errorMessage = 'Failed to load statistics: $e';
        _isLoading = false;
      });
    }
  }

  Future<void> _loadVisitStats() async {
    final result = await _visitRepository.getUserVisits();
    result.fold(
          (failure) {
        throw Exception(failure.message ?? 'Failed to load visits');
      },
          (visits) {
        _visits = visits;
        _calculateVisitStats();
      },
    );
  }

  Future<void> _loadTagStats() async {
    final result = await _tagRepository.getUserTags();
    result.fold(
          (failure) {
        throw Exception(failure.message ?? 'Failed to load tags');
      },
          (tags) {
        _tags = tags;
        _calculateTagStats();
      },
    );
  }

  void _calculateVisitStats() {
    _totalVisits = _visits.length;
    _uniquePlaces = _visits.map((v) => v.placeId).toSet().length;

    if (_visits.isNotEmpty) {
      // Sort visits by date
      final sortedVisits = [..._visits]
        ..sort((a, b) => a.visitedAt.compareTo(b.visitedAt));

      _firstVisitDate = DateFormat.yMMMd().format(sortedVisits.first.visitedAt);
      _lastVisitDate = DateFormat.yMMMd().format(sortedVisits.last.visitedAt);

      // Calculate visits by month
      _visitsByMonth.clear();
      final monthNames = [
        'Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun',
        'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'
      ];

      for (final visit in _visits) {
        final monthKey = monthNames[visit.visitedAt.month - 1];
        _visitsByMonth[monthKey] = (_visitsByMonth[monthKey] ?? 0) + 1;
      }

      // Find most active month
      if (_visitsByMonth.isNotEmpty) {
        final mostActive = _visitsByMonth.entries
            .reduce((a, b) => a.value > b.value ? a : b);
        _mostActiveMonth = mostActive.key;
      }

      // Calculate visits by city
      _visitsByCity.clear();
      for (final visit in _visits) {
        final cityName = visit.place?.city?.name ?? 'Unknown';
        _visitsByCity[cityName] = (_visitsByCity[cityName] ?? 0) + 1;
      }
    }
  }

  void _calculateTagStats() {
    _totalTags = _tags.length;
    _uniquePeople = _tags.map((t) => t.personId).toSet().length;

    if (_tags.isNotEmpty) {
      // Calculate tags by category
      _tagsByCategory.clear();
      for (final tag in _tags) {
        final category = tag.person?.category ?? 'Unknown';
        _tagsByCategory[category] = (_tagsByCategory[category] ?? 0) + 1;
      }

      // Find most tagged category
      if (_tagsByCategory.isNotEmpty) {
        final mostTagged = _tagsByCategory.entries
            .reduce((a, b) => a.value > b.value ? a : b);
        _mostTaggedCategory = mostTagged.key;
      }

      // Calculate tags by city
      _tagsByCity.clear();
      for (final tag in _tags) {
        final cityName = tag.person?.city?.name ?? 'Unknown';
        _tagsByCity[cityName] = (_tagsByCity[cityName] ?? 0) + 1;
      }
    }
  }

  Widget _buildStatCard({
    required String title,
    required String value,
    required IconData icon,
    required Color color,
    String? subtitle,
  }) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, color: color, size: 24),
              const SizedBox(width: 8),
              Text(
                title,
                style: AppTextStyles.titleSmall.copyWith(color: color),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            value,
            style: AppTextStyles.headlineMedium.copyWith(color: color),
          ),
          if (subtitle != null) ...[
            const SizedBox(height: 4),
            Text(
              subtitle,
              style: AppTextStyles.bodySmall.copyWith(
                color: AppColors.textSecondary,
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildChartSection({
    required String title,
    required Map<String, int> data,
    required Color color,
    int maxItems = 5,
  }) {
    final sortedEntries = data.entries.toList()
      ..sort((a, b) => b.value.compareTo(a.value));
    final topEntries = sortedEntries.take(maxItems).toList();

    if (topEntries.isEmpty) {
      return Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.circular(12),
        ),
        child: Center(
          child: Text(
            'No data available',
            style: AppTextStyles.bodyMedium.copyWith(
              color: AppColors.textSecondary,
            ),
          ),
        ),
      );
    }

    final maxValue = topEntries.first.value;

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: AppTextStyles.titleMedium.copyWith(color: color),
          ),
          const SizedBox(height: 16),
          ...topEntries.map((entry) {
            final percentage = entry.value / maxValue;
            return Padding(
              padding: const EdgeInsets.only(bottom: 12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Flexible(
                        child: Text(
                          entry.key,
                          style: AppTextStyles.bodyMedium,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      Text(
                        entry.value.toString(),
                        style: AppTextStyles.bodyMedium.copyWith(
                          fontWeight: FontWeight.w600,
                          color: color,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 4),
                  LinearProgressIndicator(
                    value: percentage,
                    backgroundColor: AppColors.inputBackground,
                    valueColor: AlwaysStoppedAnimation(color),
                  ),
                ],
              ),
            );
          }),
        ],
      ),
    );
  }

  Widget _buildVisitsTab() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Overview Stats
          GridView.count(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            crossAxisCount: 2,
            mainAxisSpacing: 12,
            crossAxisSpacing: 12,
            childAspectRatio: 1.5,
            children: [
              _buildStatCard(
                title: 'Total Visits',
                value: _totalVisits.toString(),
                icon: Icons.visibility,
                color: AppColors.primary,
              ),
              _buildStatCard(
                title: 'Unique Places',
                value: _uniquePlaces.toString(),
                icon: Icons.place,
                color: AppColors.secondary,
              ),
              _buildStatCard(
                title: 'Most Active',
                value: _mostActiveMonth,
                icon: Icons.calendar_month,
                color: AppColors.success,
                subtitle: 'Month',
              ),
              _buildStatCard(
                title: 'Visit Period',
                value: _totalVisits > 0 ? 'Active' : 'None',
                icon: Icons.date_range,
                color: AppColors.warning,
                subtitle: _firstVisitDate != 'N/A'
                    ? '$_firstVisitDate - $_lastVisitDate'
                    : 'No visits yet',
              ),
            ],
          ),

          const SizedBox(height: 24),

          // Monthly Activity
          _buildChartSection(
            title: 'Visits by Month',
            data: _visitsByMonth,
            color: AppColors.primary,
          ),

          const SizedBox(height: 16),

          // City Distribution
          _buildChartSection(
            title: 'Top Cities Visited',
            data: _visitsByCity,
            color: AppColors.secondary,
          ),
        ],
      ),
    );
  }

  Widget _buildTagsTab() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Overview Stats
          GridView.count(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            crossAxisCount: 2,
            mainAxisSpacing: 12,
            crossAxisSpacing: 12,
            childAspectRatio: 1.5,
            children: [
              _buildStatCard(
                title: 'Total Tags',
                value: _totalTags.toString(),
                icon: Icons.local_offer,
                color: AppColors.primary,
              ),
              _buildStatCard(
                title: 'Unique People',
                value: _uniquePeople.toString(),
                icon: Icons.person,
                color: AppColors.secondary,
              ),
              _buildStatCard(
                title: 'Top Category',
                value: _mostTaggedCategory,
                icon: Icons.category,
                color: AppColors.success,
                subtitle: 'Most tagged',
              ),
              _buildStatCard(
                title: 'Average',
                value: _uniquePeople > 0
                    ? (_totalTags / _uniquePeople).toStringAsFixed(1)
                    : '0',
                icon: Icons.analytics,
                color: AppColors.warning,
                subtitle: 'Tags per person',
              ),
            ],
          ),

          const SizedBox(height: 24),

          // Category Distribution
          _buildChartSection(
            title: 'Tags by Category',
            data: _tagsByCategory,
            color: AppColors.primary,
          ),

          const SizedBox(height: 16),

          // City Distribution
          _buildChartSection(
            title: 'Tags by City',
            data: _tagsByCity,
            color: AppColors.secondary,
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: CustomAppBar(
        title: 'Statistics',
        automaticallyImplyLeading: true,
        bottom: TabBar(
          controller: _tabController,
          tabs: const [
            Tab(text: 'Visits', icon: Icon(Icons.place)),
            Tab(text: 'Tags', icon: Icon(Icons.local_offer)),
          ],
          labelColor: AppColors.primary,
          unselectedLabelColor: AppColors.textSecondary,
          indicatorColor: AppColors.primary,
        ),
      ),
      body: _isLoading
          ? const Center(child: LoadingWidget(size: 48))
          : _errorMessage != null
          ? Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            AppError.ErrorWidget(message: _errorMessage!),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: _loadStats,
              child: const Text('Retry'),
            ),
          ],
        ),
      )
          : TabBarView(
        controller: _tabController,
        children: [
          _buildVisitsTab(),
          _buildTagsTab(),
        ],
      ),
    );
  }
}