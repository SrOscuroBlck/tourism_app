// lib/presentation/widgets/analytics/analytics_section.dart
import 'package:flutter/material.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_text_styles.dart';
import '../../../domain/entities/place.dart';
import '../../blocs/home/home_bloc.dart';

class AnalyticsSection extends StatelessWidget {
  final AnalyticsData analytics;

  const AnalyticsSection({
    Key? key,
    required this.analytics,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.analytics, color: AppColors.primary, size: 24),
              const SizedBox(width: 8),
              Text(
                'Insights & Analytics',
                style: AppTextStyles.titleLarge.copyWith(
                  color: AppColors.primary,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),

          // Query 1: People by Category
          PeopleByCategoryWidget(data: analytics.peopleByCategory),
          const SizedBox(height: 16),

          // Query 2: Top Visited Places
          TopVisitedPlacesWidget(places: analytics.topVisitedPlaces),
          const SizedBox(height: 16),

          // Query 3: User Activity Stats
          UserActivityWidget(stats: analytics.userStats),
          const SizedBox(height: 16),

          // Query 4: Price Analysis
          PriceAnalysisWidget(analysis: analytics.priceAnalysis),
          const SizedBox(height: 16),

          // Query 5: Geographic Insights
          GeographicInsightsWidget(insights: analytics.geoInsights),
        ],
      ),
    );
  }
}

// Query 1: People by Category Widget
class PeopleByCategoryWidget extends StatelessWidget {
  final Map<String, int> data;

  const PeopleByCategoryWidget({Key? key, required this.data}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Famous People by Category', style: AppTextStyles.titleMedium),
        const SizedBox(height: 8),
        if (data.isEmpty)
          Text('No data available', style: AppTextStyles.bodySmall)
        else
          SizedBox(
            height: 80,
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              itemCount: data.entries.length,
              itemBuilder: (context, index) {
                final entry = data.entries.elementAt(index);
                return Container(
                  margin: const EdgeInsets.only(right: 12),
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: AppColors.chipBackground,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        entry.value.toString(),
                        style: AppTextStyles.headlineSmall.copyWith(
                          color: AppColors.primary,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        entry.key,
                        style: AppTextStyles.bodySmall,
                      ),
                    ],
                  ),
                );
              },
            ),
          ),
      ],
    );
  }
}

// Query 2: Top Visited Places Widget
class TopVisitedPlacesWidget extends StatelessWidget {
  final List<Place> places;

  const TopVisitedPlacesWidget({Key? key, required this.places}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text('Most Visited Places', style: AppTextStyles.titleMedium),
            if (places.isNotEmpty)
              TextButton(
                onPressed: () {
                  // Navigate to full list
                  Navigator.pushNamed(context, '/analytics/top-visited');
                },
                child: Text('See All'),
              ),
          ],
        ),
        const SizedBox(height: 8),
        if (places.isEmpty)
          Text('No visits yet', style: AppTextStyles.bodySmall)
        else
          SizedBox(
            height: 120,
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              itemCount: places.take(5).length,
              itemBuilder: (context, index) {
                final place = places[index];
                return Container(
                  width: 200,
                  margin: const EdgeInsets.only(right: 12),
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: AppColors.inputBackground,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          CircleAvatar(
                            radius: 12,
                            backgroundColor: AppColors.primary,
                            child: Text(
                              '${index + 1}',
                              style: AppTextStyles.bodySmall.copyWith(
                                color: Colors.white,
                              ),
                            ),
                          ),
                          const SizedBox(width: 8),
                          Expanded(
                            child: Text(
                              place.name,
                              style: AppTextStyles.titleSmall,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 4),
                      Text(
                        place.city?.name ?? 'Unknown City',
                        style: AppTextStyles.bodySmall.copyWith(
                          color: AppColors.textSecondary,
                        ),
                      ),
                      const Spacer(),
                      Row(
                        children: [
                          Icon(Icons.visibility, size: 16, color: AppColors.primary),
                          const SizedBox(width: 4),
                          Text(
                            '${place.visitCount ?? 0} visits',
                            style: AppTextStyles.bodySmall.copyWith(
                              color: AppColors.primary,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                );
              },
            ),
          ),
      ],
    );
  }
}

// Query 3: User Activity Widget
class UserActivityWidget extends StatelessWidget {
  final UserActivityStats stats;

  const UserActivityWidget({Key? key, required this.stats}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Your Activity', style: AppTextStyles.titleMedium),
        const SizedBox(height: 8),
        Row(
          children: [
            Expanded(
              child: _StatCard(
                icon: Icons.place,
                value: stats.placesVisited.toString(),
                label: 'Places Visited',
              ),
            ),
            const SizedBox(width: 8),
            Expanded(
              child: _StatCard(
                icon: Icons.local_offer,
                value: stats.totalTags.toString(),
                label: 'People Tagged',
              ),
            ),
            const SizedBox(width: 8),
            Expanded(
              child: _StatCard(
                icon: Icons.calendar_month,
                value: stats.mostActiveMonth,
                label: 'Most Active',
              ),
            ),
          ],
        ),
      ],
    );
  }
}

// Query 4: Price Analysis Widget
class PriceAnalysisWidget extends StatelessWidget {
  final PriceAnalysis analysis;

  const PriceAnalysisWidget({Key? key, required this.analysis}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Food Price Insights', style: AppTextStyles.titleMedium),
        const SizedBox(height: 8),
        Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: AppColors.inputBackground,
            borderRadius: BorderRadius.circular(12),
          ),
          child: Column(
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text('Average Price:', style: AppTextStyles.bodyMedium),
                  Text(
                    '\$${analysis.averagePrice.toStringAsFixed(2)}',
                    style: AppTextStyles.titleSmall.copyWith(
                      color: AppColors.primary,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('Most Expensive:', style: AppTextStyles.bodySmall),
                        Text(
                          analysis.mostExpensiveDish,
                          style: AppTextStyles.bodySmall.copyWith(
                            fontWeight: FontWeight.w600,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                        Text(
                          '\$${analysis.mostExpensivePrice.toStringAsFixed(2)}',
                          style: AppTextStyles.bodySmall.copyWith(
                            color: AppColors.error,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('Cheapest:', style: AppTextStyles.bodySmall),
                        Text(
                          analysis.cheapestDish,
                          style: AppTextStyles.bodySmall.copyWith(
                            fontWeight: FontWeight.w600,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                        Text(
                          '\$${analysis.cheapestPrice.toStringAsFixed(2)}',
                          style: AppTextStyles.bodySmall.copyWith(
                            color: AppColors.success,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ],
    );
  }
}

// Query 5: Geographic Insights Widget
class GeographicInsightsWidget extends StatelessWidget {
  final GeographicInsights insights;

  const GeographicInsightsWidget({Key? key, required this.insights}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Geographic Insights', style: AppTextStyles.titleMedium),
        const SizedBox(height: 8),
        Row(
          children: [
            Expanded(
              child: _GeographicCard(
                icon: Icons.local_offer,
                title: 'Most Tagged City',
                cityName: insights.mostTaggedCity,
                count: insights.mostTaggedCount,
                color: AppColors.secondary,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _GeographicCard(
                icon: Icons.visibility,
                title: 'Most Visited City',
                cityName: insights.mostVisitedCity,
                count: insights.mostVisitedCount,
                color: AppColors.primary,
              ),
            ),
          ],
        ),
      ],
    );
  }
}

// Helper Widgets
class _StatCard extends StatelessWidget {
  final IconData icon;
  final String value;
  final String label;

  const _StatCard({
    required this.icon,
    required this.value,
    required this.label,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: AppColors.inputBackground,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        children: [
          Icon(icon, color: AppColors.primary, size: 20),
          const SizedBox(height: 4),
          Text(
            value,
            style: AppTextStyles.titleSmall.copyWith(
              color: AppColors.primary,
            ),
          ),
          Text(
            label,
            style: AppTextStyles.bodySmall,
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
}

class _GeographicCard extends StatelessWidget {
  final IconData icon;
  final String title;
  final String cityName;
  final int count;
  final Color color;

  const _GeographicCard({
    required this.icon,
    required this.title,
    required this.cityName,
    required this.count,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: AppColors.inputBackground,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, color: color, size: 16),
              const SizedBox(width: 4),
              Expanded(
                child: Text(
                  title,
                  style: AppTextStyles.bodySmall,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            cityName,
            style: AppTextStyles.titleSmall.copyWith(color: color),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
          Text(
            '$count ${icon == Icons.local_offer ? "tags" : "visits"}',
            style: AppTextStyles.bodySmall.copyWith(
              color: AppColors.textSecondary,
            ),
          ),
        ],
      ),
    );
  }
}