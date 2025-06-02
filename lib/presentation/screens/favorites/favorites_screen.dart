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
import 'route_planner_screen.dart';
import '../../blocs/route_planner/route_planner_bloc.dart';
import '../../../injection_container.dart';

/// This screen shows the user’s favorite places in a list.
/// A FAB is added so that tapping it will open the RoutePlannerScreen,
/// wrapped in a MultiBlocProvider that passes down both the existing
/// FavoritesBloc and a newly created RoutePlannerBloc.
class FavoritesScreen extends StatefulWidget {
  const FavoritesScreen({Key? key}) : super(key: key);

  @override
  State<FavoritesScreen> createState() => _FavoritesScreenState();
}

class _FavoritesScreenState extends State<FavoritesScreen> {
  @override
  void initState() {
    super.initState();
    // When this screen first appears, load favorites from local storage:
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<FavoritesBloc>().add(LoadFavorites());
    });
  }

  @override
  Widget build(BuildContext context) {
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
                style:
                AppTextStyles.bodyMedium?.copyWith(color: AppColors.error),
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
            return RefreshIndicator(
              onRefresh: () async {
                context.read<FavoritesBloc>().add(LoadFavorites());
              },
              child: ListView.builder(
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
                        ).then((_) {
                          // When returning from detail, reload favorites:
                          context.read<FavoritesBloc>().add(LoadFavorites());
                        });
                      },
                    ),
                  );
                },
              ),
            );
          }
          return const SizedBox.shrink();
        },
      ),

      // ─── FloatingActionButton opens RoutePlannerScreen ───────────────
      floatingActionButton: FloatingActionButton(
        backgroundColor: AppColors.primary,
        child: const Icon(Icons.map, color: Colors.white),
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (_) => MultiBlocProvider(
                providers: [
                  // Re‐use the same FavoritesBloc so that route planner can read favorites:
                  BlocProvider.value(value: context.read<FavoritesBloc>()),
                  // Create a new RoutePlannerBloc:
                  BlocProvider(
                    create: (_) => sl<RoutePlannerBloc>(),
                  ),
                ],
                child: const RoutePlannerScreen(),
              ),
            ),
          );
        },
      ),
    );
  }
}
