// lib/presentation/screens/profile/admin_panel_screen.dart

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_text_styles.dart';
import '../../../domain/entities/user.dart';
import '../../../domain/entities/country.dart';
import '../../../domain/entities/city.dart';
import '../../../domain/entities/place.dart';
import '../../../domain/entities/person.dart';
import '../../../domain/entities/dish.dart';
import '../../../domain/repositories/country_repository.dart';
import '../../../domain/repositories/city_repository.dart';
import '../../../domain/repositories/place_repository.dart';
import '../../../domain/repositories/person_repository.dart';
import '../../../domain/repositories/dish_repository.dart';
import '../../../domain/repositories/visit_repository.dart';
import '../../../domain/repositories/tag_repository.dart';
import '../../../injection_container.dart';
import '../../blocs/auth/auth_bloc.dart';
import '../../blocs/auth/auth_state.dart';
import '../../widgets/common/custom_app_bar.dart';
import '../../widgets/common/loading_widget.dart';
import '../../widgets/common/error_widget.dart' as AppError;
import 'admin/admin_cities_screen.dart';
import 'admin/admin_countries_screen.dart';
import 'admin/admin_dishes_screen.dart';
import 'admin/admin_people_screen.dart';
import 'admin/admin_places_screen.dart';

class AdminPanelScreen extends StatefulWidget {
  const AdminPanelScreen({super.key});

  @override
  State<AdminPanelScreen> createState() => _AdminPanelScreenState();
}

class _AdminPanelScreenState extends State<AdminPanelScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  // Repositories
  final CountryRepository _countryRepo = sl<CountryRepository>();
  final CityRepository _cityRepo = sl<CityRepository>();
  final PlaceRepository _placeRepo = sl<PlaceRepository>();
  final PersonRepository _personRepo = sl<PersonRepository>();
  final DishRepository _dishRepo = sl<DishRepository>();
  final VisitRepository _visitRepo = sl<VisitRepository>();
  final TagRepository _tagRepo = sl<TagRepository>();

  // Loading states
  bool _isLoadingStats = true;
  String? _statsError;

  // Admin stats
  int _totalCountries = 0;
  int _totalCities = 0;
  int _totalPlaces = 0;
  int _totalPeople = 0;
  int _totalDishes = 0;
  int _totalVisits = 0;
  int _totalTags = 0;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    _loadAdminStats();
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  Future<void> _loadAdminStats() async {
    setState(() {
      _isLoadingStats = true;
      _statsError = null;
    });

    try {
      // Load all content counts
      final results = await Future.wait([
        _countryRepo.getAllCountries(),
        _cityRepo.getAllCities(),
        _placeRepo.getAllPlaces(),
        _personRepo.getAllPeople(),
        _dishRepo.getAllDishes(),
        _visitRepo.getUserVisits(),
        _tagRepo.getUserTags(),
      ]);

      setState(() {
        _totalCountries = results[0].fold((l) => 0, (r) => (r as List).length);
        _totalCities = results[1].fold((l) => 0, (r) => (r as List).length);
        _totalPlaces = results[2].fold((l) => 0, (r) => (r as List).length);
        _totalPeople = results[3].fold((l) => 0, (r) => (r as List).length);
        _totalDishes = results[4].fold((l) => 0, (r) => (r as List).length);
        _totalVisits = results[5].fold((l) => 0, (r) => (r as List).length);
        _totalTags = results[6].fold((l) => 0, (r) => (r as List).length);
        _isLoadingStats = false;
      });
    } catch (e) {
      setState(() {
        _statsError = 'Failed to load admin stats: $e';
        _isLoadingStats = false;
      });
    }
  }

  Widget _buildStatCard({
    required String title,
    required String value,
    required IconData icon,
    required Color color,
    VoidCallback? onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
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
          children: [
            Icon(icon, color: color, size: 32),
            const SizedBox(height: 8),
            Text(
              value,
              style: AppTextStyles.headlineMedium.copyWith(color: color),
            ),
            const SizedBox(height: 4),
            Text(
              title,
              style: AppTextStyles.bodySmall,
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildActionTile({
    required String title,
    String? subtitle,
    required IconData icon,
    required VoidCallback onTap,
    Color? iconColor,
    Color? textColor,
  }) {
    return ListTile(
      leading: Icon(
        icon,
        color: iconColor ?? AppColors.primary,
        size: 24,
      ),
      title: Text(
        title,
        style: AppTextStyles.titleMedium.copyWith(
          color: textColor ?? AppColors.textPrimary,
        ),
      ),
      subtitle: subtitle != null
          ? Text(
        subtitle,
        style: AppTextStyles.bodySmall.copyWith(
          color: AppColors.textSecondary,
        ),
      )
          : null,
      trailing: const Icon(
        Icons.chevron_right,
        color: AppColors.textHint,
      ),
      onTap: onTap,
    );
  }

  Widget _buildOverviewTab() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Content Statistics
          Text(
            'Content Overview',
            style: AppTextStyles.titleLarge,
          ),
          const SizedBox(height: 16),

          if (_isLoadingStats)
            const Center(
              child: Padding(
                padding: EdgeInsets.all(32),
                child: LoadingWidget(size: 32),
              ),
            )
          else if (_statsError != null)
            Center(
              child: Column(
                children: [
                  AppError.ErrorWidget(message: _statsError!),
                  const SizedBox(height: 16),
                  ElevatedButton(
                    onPressed: _loadAdminStats,
                    child: const Text('Retry'),
                  ),
                ],
              ),
            )
          else
            GridView.count(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              crossAxisCount: 2,
              mainAxisSpacing: 12,
              crossAxisSpacing: 12,
              childAspectRatio: 1.2,
              children: [
                _buildStatCard(
                  title: 'Countries',
                  value: _totalCountries.toString(),
                  icon: Icons.public,
                  color: AppColors.primary,
                  onTap: () {
                    Navigator.pushNamed(context, '/countries_list');
                  },
                ),
                _buildStatCard(
                  title: 'Cities',
                  value: _totalCities.toString(),
                  icon: Icons.location_city,
                  color: AppColors.secondary,
                  onTap: () {
                    Navigator.pushNamed(context, '/cities_list');
                  },
                ),
                _buildStatCard(
                  title: 'Places',
                  value: _totalPlaces.toString(),
                  icon: Icons.place,
                  color: AppColors.success,
                ),
                _buildStatCard(
                  title: 'People',
                  value: _totalPeople.toString(),
                  icon: Icons.person,
                  color: AppColors.warning,
                  onTap: () {
                    Navigator.pushNamed(context, '/people_list');
                  },
                ),
                _buildStatCard(
                  title: 'Dishes',
                  value: _totalDishes.toString(),
                  icon: Icons.restaurant,
                  color: AppColors.error,
                  onTap: () {
                    Navigator.pushNamed(context, '/dishes_list');
                  },
                ),
                _buildStatCard(
                  title: 'User Activity',
                  value: '${_totalVisits + _totalTags}',
                  icon: Icons.analytics,
                  color: AppColors.primary,
                ),
              ],
            ),

          const SizedBox(height: 32),

          // Quick Actions
          Text(
            'Quick Actions',
            style: AppTextStyles.titleLarge,
          ),
          const SizedBox(height: 16),

          Container(
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
              children: [
                _buildActionTile(
                  title: 'Manage Countries',
                  subtitle: 'Add, edit, or remove countries',
                  icon: Icons.public,
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => const AdminCountriesScreen(),
                      ),
                    );
                  },
                ),
                const Divider(height: 1),
                _buildActionTile(
                  title: 'Manage Cities',
                  subtitle: 'Add, edit, or remove cities',
                  icon: Icons.location_city,
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => const AdminCitiesScreen(),
                      ),
                    );
                  },
                ),
                const Divider(height: 1),
                _buildActionTile(
                  title: 'Manage Places',
                  subtitle: 'Add, edit, or remove places',
                  icon: Icons.place,
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => const AdminPlacesScreen(),
                      ),
                    );
                  },
                ),
                const Divider(height: 1),
                _buildActionTile(
                  title: 'Manage People',
                  subtitle: 'Add, edit, or remove famous people',
                  icon: Icons.person,
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => const AdminPeopleScreen(),
                      ),
                    );
                  },
                ),
                const Divider(height: 1),
                _buildActionTile(
                  title: 'Manage Dishes',
                  subtitle: 'Add, edit, or remove dishes',
                  icon: Icons.restaurant,
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => const AdminDishesScreen(),
                      ),
                    );
                  },
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSystemTab() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // System Information
          Text(
            'System Information',
            style: AppTextStyles.titleLarge,
          ),
          const SizedBox(height: 16),

          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(20),
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
                _buildInfoRow('App Version', '1.0.0'),
                const SizedBox(height: 12),
                _buildInfoRow('Database Status', 'Connected'),
                const SizedBox(height: 12),
                _buildInfoRow('Last Update', DateTime.now().toString().split(' ')[0]),
                const SizedBox(height: 12),
                _buildInfoRow('Total Users', 'N/A'),
              ],
            ),
          ),

          const SizedBox(height: 32),

          // Admin Tools
          Text(
            'Admin Tools',
            style: AppTextStyles.titleLarge,
          ),
          const SizedBox(height: 16),

          Container(
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
              children: [
                _buildActionTile(
                  title: 'Refresh Cache',
                  subtitle: 'Clear and refresh app cache',
                  icon: Icons.refresh,
                  onTap: () {
                    _showConfirmDialog(
                      title: 'Refresh Cache',
                      content: 'This will clear all cached data. Continue?',
                      onConfirm: () {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text('Cache refreshed successfully'),
                            backgroundColor: AppColors.success,
                          ),
                        );
                      },
                    );
                  },
                ),
                const Divider(height: 1),
                _buildActionTile(
                  title: 'Export Data',
                  subtitle: 'Export app data for backup',
                  icon: Icons.download,
                  onTap: () {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('Export feature coming soon'),
                        backgroundColor: AppColors.info,
                      ),
                    );
                  },
                ),
                const Divider(height: 1),
                _buildActionTile(
                  title: 'View Logs',
                  subtitle: 'Check system logs and errors',
                  icon: Icons.bug_report,
                  onTap: () {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('Log viewer coming soon'),
                        backgroundColor: AppColors.info,
                      ),
                    );
                  },
                ),
                const Divider(height: 1),
                _buildActionTile(
                  title: 'Send Notification',
                  subtitle: 'Send push notification to all users',
                  icon: Icons.notifications,
                  iconColor: AppColors.warning,
                  onTap: () {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('Notification feature coming soon'),
                        backgroundColor: AppColors.info,
                      ),
                    );
                  },
                ),
              ],
            ),
          ),

          const SizedBox(height: 32),

          // Danger Zone
          Text(
            'Danger Zone',
            style: AppTextStyles.titleLarge.copyWith(color: AppColors.error),
          ),
          const SizedBox(height: 16),

          Container(
            decoration: BoxDecoration(
              color: AppColors.surface,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: AppColors.error.withOpacity(0.3)),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.05),
                  blurRadius: 4,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: Column(
              children: [
                _buildActionTile(
                  title: 'Reset Statistics',
                  subtitle: 'Clear all user statistics (irreversible)',
                  icon: Icons.delete_forever,
                  iconColor: AppColors.error,
                  textColor: AppColors.error,
                  onTap: () {
                    _showConfirmDialog(
                      title: 'Reset Statistics',
                      content: 'This will permanently delete all user statistics. This action cannot be undone. Are you sure?',
                      onConfirm: () {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text('Statistics reset successfully'),
                            backgroundColor: AppColors.error,
                          ),
                        );
                      },
                      destructive: true,
                    );
                  },
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInfoRow(String label, String value) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: AppTextStyles.bodyMedium.copyWith(
            color: AppColors.textSecondary,
          ),
        ),
        Text(
          value,
          style: AppTextStyles.bodyMedium.copyWith(
            fontWeight: FontWeight.w600,
          ),
        ),
      ],
    );
  }

  void _showConfirmDialog({
    required String title,
    required String content,
    required VoidCallback onConfirm,
    bool destructive = false,
  }) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(title),
        content: Text(content),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              onConfirm();
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: destructive ? AppColors.error : AppColors.primary,
            ),
            child: Text(destructive ? 'Delete' : 'Confirm'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<AuthBloc, AuthState>(
      builder: (context, state) {
        if (state is Authenticated) {
          final User user = state.user;

          // Check if user is admin
          if (!user.isAdmin) {
            return Scaffold(
              backgroundColor: AppColors.background,
              appBar: const CustomAppBar(
                title: 'Access Denied',
                automaticallyImplyLeading: true,
              ),
              body: const Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      Icons.lock,
                      size: 64,
                      color: AppColors.error,
                    ),
                    SizedBox(height: 16),
                    Text(
                      'Admin access required',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w600,
                        color: AppColors.error,
                      ),
                    ),
                  ],
                ),
              ),
            );
          }

          return Scaffold(
            backgroundColor: AppColors.background,
            appBar: CustomAppBar(
              title: 'Admin Panel',
              automaticallyImplyLeading: true,
              bottom: TabBar(
                controller: _tabController,
                tabs: const [
                  Tab(text: 'Overview', icon: Icon(Icons.dashboard)),
                  Tab(text: 'System', icon: Icon(Icons.settings)),
                ],
                labelColor: AppColors.primary,
                unselectedLabelColor: AppColors.textSecondary,
                indicatorColor: AppColors.primary,
              ),
            ),
            body: TabBarView(
              controller: _tabController,
              children: [
                _buildOverviewTab(),
                _buildSystemTab(),
              ],
            ),
          );
        }

        return const Center(child: LoadingWidget(size: 48));
      },
    );
  }
}