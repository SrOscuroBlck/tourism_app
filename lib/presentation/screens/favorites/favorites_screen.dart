// lib/presentation/screens/favorites/favorites_screen.dart

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_text_styles.dart';
import '../../../domain/entities/place.dart';
import '../../blocs/favorites/favorites_bloc.dart';
import '../places/place_detail_screen.dart';
import '../../widgets/cards/place_card.dart';
import '../../widgets/common/custom_app_bar.dart';

class FavoritesScreen extends StatelessWidget {
  const FavoritesScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    // Trigger loading of locally‐saved favorites as soon as this screen appears
    context.read<FavoritesBloc>().add(LoadFavorites());

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: const CustomAppBar(title: 'My Favorites'),
      body: BlocBuilder<FavoritesBloc, FavoritesState>(
        builder: (context, state) {
          if (state is FavoritesLoading) {
            return const Center(child: CircularProgressIndicator());
          }

          if (state is FavoritesError) {
            return Center(
              child: Text(
                state.message,
                style: AppTextStyles.bodyMedium
                    ?.copyWith(color: AppColors.error),
              ),
            );
          }

          if (state is FavoritesLoaded) {
            final List<Place> favorites = state.places;
            if (favorites.isEmpty) {
              return Center(
                child: Text(
                  'You have no favorite places yet.',
                  style: AppTextStyles.bodyMedium,
                ),
              );
            }

            return ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: favorites.length,
              itemBuilder: (context, index) {
                final place = favorites[index];
                return Padding(
                  padding: const EdgeInsets.only(bottom: 12),
                  child: PlaceCard(
                    place: place,
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) =>
                              PlaceDetailScreen(placeId: place.id),
                        ),
                      );
                    },
                  ),
                );
              },
            );
          }

          // Default fallback
          return const SizedBox.shrink();
        },
      ),
    );
  }
}
