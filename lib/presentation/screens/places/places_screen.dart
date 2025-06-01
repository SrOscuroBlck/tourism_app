// lib/presentation/screens/places/places_screen.dart

import 'package:flutter/material.dart';
import '../../../core/theme/app_text_styles.dart';
import '../../../core/theme/app_colors.dart';

class PlacesScreen extends StatelessWidget {
  const PlacesScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('Places'),
      ),
      body: Center(
        child: Text(
          'Places List Content Goes Here',
          style: AppTextStyles.bodyLarge,
        ),
      ),
    );
  }
}
