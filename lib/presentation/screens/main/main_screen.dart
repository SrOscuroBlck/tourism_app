// lib/presentation/screens/main/main_screen.dart

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../blocs/home/home_bloc.dart';
import '../../blocs/places/places_bloc.dart';
import '../../blocs/favorites/favorites_bloc.dart';

import '../home/home_screen.dart';
import '../places/places_screen.dart';
import '../scanner/scanner_screen.dart';
import '../favorites/favorites_screen.dart';
import '../profile/profile_screen.dart';

import '../../../core/theme/app_colors.dart';
import '../../../injection_container.dart';

class MainScreen extends StatefulWidget {
  const MainScreen({Key? key}) : super(key: key);

  @override
  State<MainScreen> createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  int _currentIndex = 0;

  // Wrap each page that needs a Bloc in the corresponding BlocProvider.
  static final List<Widget> _pages = <Widget>[
    // 1⃣ Home tab needs HomeBloc:
    BlocProvider<HomeBloc>(
      create: (_) => sl<HomeBloc>(),
      child: const HomeScreen(),
    ),

    // 2⃣ Places tab needs PlacesBloc:
    BlocProvider<PlacesBloc>(
      create: (_) => sl<PlacesBloc>(),
      child: const PlacesScreen(),
    ),

    // 3⃣ Scanner tab does not need a Bloc at the moment:
    const ScannerScreen(),

    // 4⃣ Favorites tab needs FavoritesBloc:
    BlocProvider<FavoritesBloc>(
      create: (_) => sl<FavoritesBloc>(),
      child: const FavoritesScreen(),
    ),

    // 5⃣ Profile tab does not need a Bloc right now:
    const ProfileScreen(),
  ];

  void _onNavItemTapped(int index) {
    setState(() {
      _currentIndex = index;
    });
  }

  BottomNavigationBarItem _buildNavItem({
    required IconData icon,
    required String label,
  }) {
    return BottomNavigationBarItem(
      icon: Icon(icon),
      label: label,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _pages[_currentIndex],
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _currentIndex,
        onTap: _onNavItemTapped,
        type: BottomNavigationBarType.fixed,
        selectedItemColor: AppColors.primary,
        unselectedItemColor: AppColors.textHint,
        showUnselectedLabels: true,
        items: <BottomNavigationBarItem>[
          _buildNavItem(icon: Icons.explore,          label: 'Explore'),
          _buildNavItem(icon: Icons.place,            label: 'Places'),
          _buildNavItem(icon: Icons.qr_code_scanner,  label: 'Scan'),
          _buildNavItem(icon: Icons.favorite,         label: 'Favorites'),
          _buildNavItem(icon: Icons.person,           label: 'Profile'),
        ],
      ),
    );
  }
}
