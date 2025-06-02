// lib/presentation/screens/profile/profile_screen.dart

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:tourismapp/presentation/screens/profile/settings_screen.dart';
import 'package:tourismapp/presentation/screens/profile/stats_screen.dart';

import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_text_styles.dart';
import '../../../domain/entities/user.dart';
import '../../../domain/entities/visit.dart';
import '../../../domain/entities/tag.dart';
import '../../../domain/repositories/visit_repository.dart';
import '../../../domain/repositories/tag_repository.dart';
import '../../../injection_container.dart';
import '../../blocs/auth/auth_bloc.dart';
import '../../blocs/auth/auth_event.dart';
import '../../blocs/auth/auth_state.dart';
import '../../widgets/common/custom_app_bar.dart';
import '../../widgets/common/loading_widget.dart';
import '../../widgets/common/error_widget.dart' as AppError;
import '../places/visited_places_screen.dart';
import '../tags/tags_list_screen.dart';
import 'admin_panel_screen.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  final VisitRepository _visitRepository = sl<VisitRepository>();
  final TagRepository _tagRepository = sl<TagRepository>();

  bool _isLoadingStats = true;
  String? _statsError;
  int _visitsCount = 0;
  int _tagsCount = 0;
  int _placesVisited = 0;

  @override
  void initState() {
    super.initState();
    _loadUserStats();
  }

  Future<void> _loadUserStats() async {
    setState(() {
      _isLoadingStats = true;
      _statsError = null;
    });

    try {
      // Load visits
      final visitsResult = await _visitRepository.getUserVisits();
      visitsResult.fold(
            (failure) {
          setState(() {
            _statsError = failure.message ?? 'Failed to load stats';
            _isLoadingStats = false;
          });
        },
            (visits) {
          final uniquePlaces = visits.map((v) => v.placeId).toSet();
          setState(() {
            _visitsCount = visits.length;
            _placesVisited = uniquePlaces.length;
          });
        },
      );

      // Load tags
      final tagsResult = await _tagRepository.getUserTags();
      tagsResult.fold(
            (failure) {
          // Don't overwrite stats error if visits failed
          if (_statsError == null) {
            setState(() {
              _statsError = failure.message ?? 'Failed to load stats';
            });
          }
        },
            (tags) {
          setState(() {
            _tagsCount = tags.length;
            _isLoadingStats = false;
          });
        },
      );
    } catch (e) {
      setState(() {
        _statsError = 'Failed to load stats: $e';
        _isLoadingStats = false;
      });
    }
  }

  void _showLogoutDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext dialogContext) {
        return AlertDialog(
          title: const Text('Logout'),
          content: const Text('Are you sure you want to logout?'),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(dialogContext).pop(),
              child: const Text('Cancel'),
            ),
            ElevatedButton(
              onPressed: () {
                Navigator.of(dialogContext).pop();
                // Use the original context (not dialogContext) to access AuthBloc
                context.read<AuthBloc>().add(LogoutRequested());
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.error,
              ),
              child: const Text('Logout'),
            ),
          ],
        );
      },
    );
  }

  Widget _buildStatsCard(String title, String value, IconData icon, Color color) {
    return Expanded(
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

  Widget _buildMenuOption({
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: const CustomAppBar(
        title: 'Profile',
        automaticallyImplyLeading: false,
      ),
      body: BlocBuilder<AuthBloc, AuthState>(
        builder: (context, state) {
          if (state is Authenticated) {
            final User user = state.user;

            return RefreshIndicator(
              onRefresh: _loadUserStats,
              child: SingleChildScrollView(
                physics: const AlwaysScrollableScrollPhysics(),
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // User Info Card
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(20),
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
                        children: [
                          CircleAvatar(
                            radius: 40,
                            backgroundColor: AppColors.primary,
                            child: Text(
                              user.name.isNotEmpty ? user.name[0].toUpperCase() : 'U',
                              style: AppTextStyles.headlineLarge.copyWith(
                                color: AppColors.textLight,
                              ),
                            ),
                          ),
                          const SizedBox(height: 16),
                          Text(
                            user.name,
                            style: AppTextStyles.headlineMedium,
                            textAlign: TextAlign.center,
                          ),
                          const SizedBox(height: 4),
                          Text(
                            user.email,
                            style: AppTextStyles.bodyMedium.copyWith(
                              color: AppColors.textSecondary,
                            ),
                            textAlign: TextAlign.center,
                          ),
                          const SizedBox(height: 8),
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 12,
                              vertical: 6,
                            ),
                            decoration: BoxDecoration(
                              color: user.isAdmin
                                  ? AppColors.error
                                  : AppColors.primary,
                              borderRadius: BorderRadius.circular(20),
                            ),
                            child: Text(
                              user.role.toUpperCase(),
                              style: AppTextStyles.bodySmall.copyWith(
                                color: AppColors.textLight,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),

                    const SizedBox(height: 24),

                    // Stats Section
                    Text(
                      'Your Activity',
                      style: AppTextStyles.titleLarge,
                    ),
                    const SizedBox(height: 12),

                    if (_isLoadingStats)
                      const Center(
                        child: Padding(
                          padding: EdgeInsets.all(32),
                          child: LoadingWidget(size: 32),
                        ),
                      )
                    else if (_statsError != null)
                      Center(
                        child: Padding(
                          padding: const EdgeInsets.all(16),
                          child: Column(
                            children: [
                              AppError.ErrorWidget(message: _statsError!),
                              const SizedBox(height: 8),
                              ElevatedButton(
                                onPressed: _loadUserStats,
                                child: const Text('Retry'),
                              ),
                            ],
                          ),
                        ),
                      )
                    else
                      Row(
                        children: [
                          _buildStatsCard(
                            'Places\nVisited',
                            _placesVisited.toString(),
                            Icons.place,
                            AppColors.primary,
                          ),
                          const SizedBox(width: 12),
                          _buildStatsCard(
                            'Total\nVisits',
                            _visitsCount.toString(),
                            Icons.visibility,
                            AppColors.secondary,
                          ),
                          const SizedBox(width: 12),
                          _buildStatsCard(
                            'People\nTagged',
                            _tagsCount.toString(),
                            Icons.local_offer,
                            AppColors.success,
                          ),
                        ],
                      ),

                    const SizedBox(height: 32),

                    // Menu Section
                    Text(
                      'Menu',
                      style: AppTextStyles.titleLarge,
                    ),
                    const SizedBox(height: 12),

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
                          _buildMenuOption(
                            title: 'My Visits',
                            subtitle: 'Places you\'ve visited',
                            icon: Icons.place,
                            onTap: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (_) => const VisitedPlacesScreen(),
                                ),
                              );
                            },
                          ),
                          const Divider(height: 1),
                          _buildMenuOption(
                            title: 'My Tags',
                            subtitle: 'Famous people you\'ve tagged',
                            icon: Icons.local_offer,
                            onTap: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (_) => const UserTagsScreen(),
                                ),
                              );
                            },
                          ),
                          const Divider(height: 1),
                          _buildMenuOption(
                            title: 'Statistics',
                            subtitle: 'Detailed analytics',
                            icon: Icons.analytics,
                            onTap: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (_) => const StatsScreen(),
                                ),
                              );
                            },
                          ),
                          const Divider(height: 1),
                          _buildMenuOption(
                            title: 'Settings',
                            subtitle: 'App preferences',
                            icon: Icons.settings,
                            onTap: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (_) => const SettingsScreen(),
                                ),
                              );
                            },
                          ),
                          if (user.isAdmin) ...[
                            const Divider(height: 1),
                            _buildMenuOption(
                              title: 'Admin Panel',
                              subtitle: 'Manage app content',
                              icon: Icons.admin_panel_settings,
                              iconColor: AppColors.error,
                              onTap: () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (_) => const AdminPanelScreen(),
                                  ),
                                );
                              },
                            ),
                          ],
                          const Divider(height: 1),
                          _buildMenuOption(
                            title: 'Logout',
                            subtitle: 'Sign out of your account',
                            icon: Icons.logout,
                            iconColor: AppColors.error,
                            textColor: AppColors.error,
                            onTap: () => _showLogoutDialog(context),
                          ),
                        ],
                      ),
                    ),

                    const SizedBox(height: 32),
                  ],
                ),
              ),
            );
          }

          return const Center(child: LoadingWidget(size: 48));
        },
      ),
    );
  }
}