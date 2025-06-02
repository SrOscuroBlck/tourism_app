// lib/presentation/screens/places/place_detail_screen.dart

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_text_styles.dart';
import '../../../domain/entities/place.dart';
import '../../../domain/entities/dish.dart';
import '../../../domain/repositories/dish_repository.dart';
import '../../../injection_container.dart';
import '../../blocs/place_detail/place_detail_bloc.dart';
import '../../widgets/cards/dish_card.dart';
import '../../widgets/common/custom_app_bar.dart';
import '../../widgets/common/loading_widget.dart';
import '../../widgets/common/error_widget.dart' as AppError;

class PlaceDetailScreen extends StatefulWidget {
  final int placeId;

  const PlaceDetailScreen({
    Key? key,
    required this.placeId,
  }) : super(key: key);

  @override
  State<PlaceDetailScreen> createState() => _PlaceDetailScreenState();
}

class _PlaceDetailScreenState extends State<PlaceDetailScreen> {
  final DishRepository _dishRepository = sl<DishRepository>();

  List<Dish> _dishes = [];
  bool _isLoadingDishes = false;
  String? _dishesError;
  bool _hasRequestedDishes = false; // to ensure we only call _loadDishes() once

  @override
  void initState() {
    super.initState();
    // Dispatch the BLoC event to fetch place details immediately.
    context.read<PlaceDetailBloc>().add(FetchPlaceDetail(widget.placeId));
  }

  Future<void> _loadDishes(int placeId) async {
    setState(() {
      _isLoadingDishes = true;
      _dishesError = null;
    });

    final result = await _dishRepository.getAllDishes(placeId: placeId);
    result.fold(
          (failure) {
        setState(() {
          _dishesError = failure.message ?? 'Failed to load dishes';
          _isLoadingDishes = false;
        });
      },
          (dishes) {
        setState(() {
          _dishes = dishes;
          _isLoadingDishes = false;
        });
      },
    );
  }

  void _toggleFavorite(int placeId) {
    context.read<PlaceDetailBloc>().add(ToggleFavoriteStatus(placeId));
  }

  void _markAsVisited(Place place) {
    // Placeholder: implement actual visit logic later
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Visit to ${place.name} recorded!'),
        backgroundColor: AppColors.success,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      // Provide a fresh PlaceDetailBloc instance for this screen
      create: (context) => sl<PlaceDetailBloc>(),
      child: Scaffold(
        backgroundColor: AppColors.background,
        body: BlocBuilder<PlaceDetailBloc, PlaceDetailState>(
          builder: (context, state) {
            if (state is PlaceDetailLoading) {
              return const Scaffold(
                appBar: CustomAppBar(title: 'Loading...'),
                body: Center(child: LoadingWidget(size: 48)),
              );
            }

            if (state is PlaceDetailError) {
              return Scaffold(
                appBar: const CustomAppBar(title: 'Error'),
                body: Center(
                  child: AppError.ErrorWidget(message: state.message),
                ),
              );
            }

            if (state is PlaceDetailLoaded) {
              final place = state.place;

              // Only load dishes ONCE, after the place has arrived.
              if (!_hasRequestedDishes) {
                _hasRequestedDishes = true;
                WidgetsBinding.instance.addPostFrameCallback((_) {
                  _loadDishes(place.id);
                });
              }

              return _buildPlaceDetailContent(place);
            }

            // Fallback for any unexpected state
            return const Scaffold(
              appBar: CustomAppBar(title: 'Place Detail'),
              body: Center(child: Text('Unknown state')),
            );
          },
        ),
      ),
    );
  }

  Widget _buildPlaceDetailContent(Place place) {
    return CustomScrollView(
      slivers: [
        // ─── SliverAppBar with image header ───
        SliverAppBar(
          expandedHeight: 300,
          pinned: true,
          backgroundColor: AppColors.primary,
          iconTheme: const IconThemeData(color: AppColors.textLight),
          actions: [
            IconButton(
              icon: Icon(
                place.isFavorite == true ? Icons.favorite : Icons.favorite_border,
                color: place.isFavorite == true ? AppColors.error : AppColors.textLight,
              ),
              onPressed: () => _toggleFavorite(place.id),
            ),
            IconButton(
              icon: const Icon(Icons.map, color: AppColors.textLight),
              onPressed: () {
                // TODO: Open external map or in‐app map view
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Opening map…')),
                );
              },
            ),
          ],
          flexibleSpace: FlexibleSpaceBar(
            background: place.imageUrl != null
                ? Image.network(
              place.imageUrl!,
              fit: BoxFit.cover,
              errorBuilder: (_, __, ___) => Container(
                color: AppColors.inputBackground,
                child: const Center(
                  child: Icon(
                    Icons.broken_image,
                    size: 64,
                    color: AppColors.textHint,
                  ),
                ),
              ),
            )
                : Container(
              color: AppColors.inputBackground,
              child: const Center(
                child: Icon(
                  Icons.place,
                  size: 64,
                  color: AppColors.textHint,
                ),
              ),
            ),
          ),
        ),

        // ─── Place Info Section ───
        SliverToBoxAdapter(
          child: Container(
            color: AppColors.surface,
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(place.name, style: AppTextStyles.headlineMedium),
                const SizedBox(height: 8),
                Row(
                  children: [
                    const Icon(
                      Icons.location_on,
                      size: 16,
                      color: AppColors.textSecondary,
                    ),
                    const SizedBox(width: 8),
                    Text(
                      '${place.latitude?.toStringAsFixed(3) ?? '—'}, '
                          '${place.longitude?.toStringAsFixed(3) ?? '—'}',
                      style: AppTextStyles.bodySmall
                          .copyWith(color: AppColors.textSecondary),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                Text(
                  place.description ?? 'No description available',
                  style: AppTextStyles.bodyMedium
                      .copyWith(color: AppColors.textSecondary),
                ),
                const SizedBox(height: 16),
                ElevatedButton(
                  onPressed: () => _markAsVisited(place),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.success,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                  child: const Text('Mark as Visited'),
                ),
              ],
            ),
          ),
        ),

        // ─── Dishes Section ───
        SliverToBoxAdapter(
          child: Container(
            color: AppColors.surface,
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Dishes', style: AppTextStyles.titleLarge),
                const SizedBox(height: 8),

                if (_isLoadingDishes)
                  const Center(child: LoadingWidget(size: 32))
                else if (_dishesError != null)
                  AppError.ErrorWidget(message: _dishesError!)
                else if (_dishes.isEmpty)
                    const Center(child: Text('No dishes available'))
                  else
                  // Build one DishCard per Dish
                    ..._dishes.map((dish) {
                      return Padding(
                        padding: const EdgeInsets.only(bottom: 12),
                        child: DishCard(
                          id: dish.id,
                          name: dish.name,
                          price: dish.price,
                          imageUrl: dish.imageUrl ?? '',
                          onTap: () {
                            // Optionally navigate to a DishDetailScreen
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(content: Text('Tapped ${dish.name}')),
                            );
                          },
                        ),
                      );
                    }).toList(),
              ],
            ),
          ),
        ),

        // (If you want to add more slivers—e.g. user reviews or similar—add them here)
      ],
    );
  }
}
