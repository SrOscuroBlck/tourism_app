// lib/presentation/screens/favorites/favorites_screen.dart

import 'package:flutter/material.dart';
import '../../../core/theme/app_text_styles.dart';
import '../../../core/theme/app_colors.dart';

class FavoritesScreen extends StatelessWidget {
  const FavoritesScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('Favorites'),
      ),
      body: Center(
        child: Text(
          'Favorites Content Goes Here',
          style: AppTextStyles.bodyLarge,
        ),
      ),
    );
  }
}
