import 'package:flutter/material.dart';
import '../../../core/theme/app_colors.dart';

/// Represents each of the five “pages” in our app.
enum AppPage { explore, places, scanner, favorites, profile }

typedef OnTabSelected = void Function(AppPage page);

/// A BottomAppBar + FAB combination:
///   • 4 icons (Explore, Places, Favorites, Profile) as BottomAppBar items.
///   • 1 center “Scanner” action as a FloatingActionButton notch.
class CustomBottomNavigation extends StatelessWidget {
  final AppPage currentPage;
  final OnTabSelected onTabSelected;

  const CustomBottomNavigation({
    Key? key,
    required this.currentPage,
    required this.onTabSelected,
  }) : super(key: key);

  /// Returns the appropriate icon based on AppPage.
  IconData _iconForPage(AppPage page) {
    switch (page) {
      case AppPage.explore:
        return Icons.explore;
      case AppPage.places:
        return Icons.location_on;
      case AppPage.scanner:
        return Icons.qr_code_scanner;
      case AppPage.favorites:
        return Icons.favorite;
      case AppPage.profile:
        return Icons.person;
    }
  }

  /// Returns the label text for each page.
  String _labelForPage(AppPage page) {
    switch (page) {
      case AppPage.explore:
        return 'Explore';
      case AppPage.places:
        return 'Places';
      case AppPage.scanner:
        return 'Scan';
      case AppPage.favorites:
        return 'Favorites';
      case AppPage.profile:
        return 'Profile';
    }
  }

  /// Builds one tappable icon‐with‐label for the BottomAppBar.
  Widget _buildTabItem({
    required AppPage page,
    required bool isSelected,
    required VoidCallback onTap,
  }) {
    final color = isSelected ? AppColors.primary : AppColors.textHint;

    return Expanded(
      child: InkWell(
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 8.0),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(_iconForPage(page), color: color),
              const SizedBox(height: 4),
              Text(
                _labelForPage(page),
                style: TextStyle(
                  color: color,
                  fontSize: 12,
                  fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    // We reserve slots: [Explore][Places]   [Favorites][Profile]
    // The center is taken by the FAB (“Scanner”).
    return BottomAppBar(
      color: AppColors.surface,
      shape: const CircularNotchedRectangle(),
      notchMargin: 6.0,
      elevation: 8.0,
      child: SizedBox(
        height: 60,
        child: Row(
          children: [
            // Left two tabs: Explore + Places
            _buildTabItem(
              page: AppPage.explore,
              isSelected: currentPage == AppPage.explore,
              onTap: () => onTabSelected(AppPage.explore),
            ),
            _buildTabItem(
              page: AppPage.places,
              isSelected: currentPage == AppPage.places,
              onTap: () => onTabSelected(AppPage.places),
            ),

            // Spacer for FAB notch
            const SizedBox(width: 60),

            // Right two tabs: Favorites + Profile
            _buildTabItem(
              page: AppPage.favorites,
              isSelected: currentPage == AppPage.favorites,
              onTap: () => onTabSelected(AppPage.favorites),
            ),
            _buildTabItem(
              page: AppPage.profile,
              isSelected: currentPage == AppPage.profile,
              onTap: () => onTabSelected(AppPage.profile),
            ),
          ],
        ),
      ),
    );
  }
}
