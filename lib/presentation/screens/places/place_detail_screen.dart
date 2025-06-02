import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:image_picker/image_picker.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_text_styles.dart';
import '../../../data/datasources/local/favorites_local_datasource.dart';
import '../../../domain/entities/place.dart';
import '../../../domain/entities/dish.dart';
import '../../../domain/entities/visit.dart';
import '../../../domain/repositories/dish_repository.dart';
import '../../../domain/repositories/visit_repository.dart';
import '../../../injection_container.dart';
import '../../blocs/favorites/favorites_bloc.dart';
import '../../blocs/place_detail/place_detail_bloc.dart';
import '../../widgets/cards/dish_card.dart';
import '../../widgets/common/custom_app_bar.dart';
import '../../widgets/common/loading_widget.dart';
import '../../widgets/common/error_widget.dart' as AppError;
import '../explore/detail/dish_detail_screen.dart';

class PlaceDetailScreen extends StatefulWidget {
  final int placeId;
  const PlaceDetailScreen({Key? key, required this.placeId}) : super(key: key);

  @override
  State<PlaceDetailScreen> createState() => _PlaceDetailScreenState();
}

class _PlaceDetailScreenState extends State<PlaceDetailScreen> {
  final DishRepository _dishRepository = sl<DishRepository>();
  final VisitRepository _visitRepository = sl<VisitRepository>();
  final ImagePicker _picker = ImagePicker();
  final supabase = Supabase.instance.client;

  final FavoritesLocalDataSource _localFavDs = sl<FavoritesLocalDataSource>();

  List<Dish> _dishes = [];
  bool _isLoadingDishes = false;
  String? _dishesError;
  bool _hasRequestedDishes = false;

  List<Visit> _userVisits = [];
  Visit? _existingVisit;

  bool _isManagingVisit = false;
  String? _visitError;

  int _currentVisitCount = 0;
  bool _didInitializeVisitCount = false;

  bool _isRouteFavorited = false;

  @override
  void initState() {
    super.initState();
    _checkIfRouteFavorited();
  }

  Future<void> _checkIfRouteFavorited() async {
    final favorites = await _localFavDs.getFavoriteRoutes();
    setState(() {
      _isRouteFavorited = favorites.contains(widget.placeId);
    });
  }

  Future<void> _toggleRouteFavorite() async {
    if (_isRouteFavorited) {
      await _localFavDs.removeFavoriteRoute(widget.placeId);
    } else {
      await _localFavDs.addFavoriteRoute(widget.placeId);
    }
    setState(() {
      _isRouteFavorited = !_isRouteFavorited;
    });
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          _isRouteFavorited
              ? 'Added to local favorites'
              : 'Removed from local favorites',
        ),
      ),
    );
    // Notify the FavoritesBloc so that the list screen updates
    context.read<FavoritesBloc>().add(LoadFavorites());
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

  Future<void> _fetchUserVisits(int placeId) async {
    final result = await _visitRepository.getUserVisits();
    result.fold(
          (_) {},
          (visits) {
        Visit? found;
        for (final v in visits) {
          if (v.placeId == placeId) {
            found = v;
            break;
          }
        }
        setState(() {
          _userVisits = visits;
          _existingVisit = found;
        });
      },
    );
  }

  Future<void> _toggleVisited(Place place) async {
    if (_isManagingVisit) return;

    setState(() {
      _isManagingVisit = true;
      _visitError = null;
    });

    final alreadyVisited = _existingVisit != null;

    if (!alreadyVisited) {
      final XFile? photo = await _picker.pickImage(source: ImageSource.camera);
      if (photo == null) {
        // user canceled camera
        setState(() {
          _isManagingVisit = false;
        });
        return;
      }
      try {
        final Uint8List bytes = await photo.readAsBytes();
        final String filePath =
            'visit-photos/place_${place.id}_${DateTime.now().millisecondsSinceEpoch}.jpg';
        await supabase.storage.from('visit-photos').uploadBinary(filePath, bytes);
        final String publicUrl =
        supabase.storage.from('visit-photos').getPublicUrl(filePath);
        final result = await _visitRepository.createVisit(
          placeId: place.id,
          photoUrl: publicUrl,
        );
        result.fold(
              (failure) {
            setState(() {
              _visitError =
              'Could not mark “${place.name}” as visited: ${failure.message}';
              _isManagingVisit = false;
            });
          },
              (visit) {
            setState(() {
              _existingVisit = visit;
              _userVisits.add(visit);
              _currentVisitCount += 1;
              _isManagingVisit = false;
            });
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text('Marked “${place.name}” as visited!'),
                backgroundColor: AppColors.success,
              ),
            );
          },
        );
      } catch (e) {
        setState(() {
          _visitError = 'Failed to upload photo: ${e.toString()}';
          _isManagingVisit = false;
        });
      }
    } else {
      final visitId = _existingVisit!.id;
      final result = await _visitRepository.deleteVisit(visitId);
      result.fold(
            (failure) {
          setState(() {
            _visitError =
            'Could not unmark “${place.name}”: ${failure.message}';
            _isManagingVisit = false;
          });
        },
            (_) {
          setState(() {
            _userVisits.removeWhere((v) => v.id == visitId);
            _existingVisit = null;
            _currentVisitCount =
            (_currentVisitCount > 0) ? _currentVisitCount - 1 : 0;
            _isManagingVisit = false;
          });
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Unmarked “${place.name}” as visited.'),
              backgroundColor: AppColors.textHint,
            ),
          );
        },
      );
    }
  }

  void _toggleBackendFavorite(int placeId) {
    // This assumes PlaceDetailBloc is provided above in the widget tree
    context.read<PlaceDetailBloc>().add(ToggleFavoriteStatus(placeId));
  }

  @override
  Widget build(BuildContext context) {
    return BlocProvider<PlaceDetailBloc>(
      create: (_) {
        final bloc = sl<PlaceDetailBloc>();
        bloc.add(FetchPlaceDetail(widget.placeId));
        return bloc;
      },
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

              if (!_didInitializeVisitCount) {
                _didInitializeVisitCount = true;
                _currentVisitCount = place.visitCount ?? 0;
              }

              if (!_hasRequestedDishes) {
                _hasRequestedDishes = true;
                WidgetsBinding.instance.addPostFrameCallback((_) {
                  _loadDishes(place.id);
                  _fetchUserVisits(place.id);
                });
              }

              return _buildPlaceDetailContent(place, context);
            }

            // fallback
            return const Scaffold(
              appBar: CustomAppBar(title: 'Place Detail'),
              body: Center(child: Text('Unknown state')),
            );
          },
        ),
      ),
    );
  }

  Widget _buildPlaceDetailContent(Place place, BuildContext parentContext) {
    final bool isVisited = _existingVisit != null;

    return CustomScrollView(
      slivers: [
        SliverAppBar(
          expandedHeight: 300,
          pinned: true,
          backgroundColor: AppColors.primary,
          iconTheme: const IconThemeData(color: AppColors.textLight),
          actions: [
            // Backend toggle (heart icon)
            IconButton(
              icon: Icon(
                place.isFavorite == true
                    ? Icons.favorite
                    : Icons.favorite_border,
                color: place.isFavorite == true
                    ? AppColors.error
                    : AppColors.textLight,
              ),
              onPressed: () => _toggleBackendFavorite(place.id),
            ),

            // Local bookmark toggle
            IconButton(
              icon: Icon(
                _isRouteFavorited ? Icons.bookmark : Icons.bookmark_border,
                color: _isRouteFavorited
                    ? Colors.yellow[700]
                    : AppColors.textLight,
              ),
              onPressed: _toggleRouteFavorite,
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
                    const Icon(Icons.category,
                        size: 16, color: AppColors.textSecondary),
                    const SizedBox(width: 8),
                    Text(
                      place.typeDisplayName,
                      style: AppTextStyles.bodySmall
                          ?.copyWith(color: AppColors.textSecondary),
                    ),
                  ],
                ),
                const SizedBox(height: 8),

                if (place.address != null && place.address!.isNotEmpty) ...[
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Icon(Icons.location_on,
                          size: 16, color: AppColors.textSecondary),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          place.address!,
                          style: AppTextStyles.bodyMedium
                              ?.copyWith(color: AppColors.textSecondary),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                ],

                if (place.city != null) ...[
                  Row(
                    children: [
                      const Icon(Icons.location_city,
                          size: 16, color: AppColors.textSecondary),
                      const SizedBox(width: 8),
                      Text(
                        'City: ${place.city!.name}',
                        style: AppTextStyles.bodyMedium
                            ?.copyWith(color: AppColors.textSecondary),
                      ),
                    ],
                  ),
                  const SizedBox(height: 4),
                ],
                if (place.country != null) ...[
                  Row(
                    children: [
                      const Icon(Icons.public,
                          size: 16, color: AppColors.textSecondary),
                      const SizedBox(width: 8),
                      Text(
                        'Country: ${place.country!.name}',
                        style: AppTextStyles.bodyMedium
                            ?.copyWith(color: AppColors.textSecondary),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                ],

                Row(
                  children: [
                    const Icon(Icons.map,
                        size: 16, color: AppColors.textSecondary),
                    const SizedBox(width: 8),
                    Text(
                      'Coordinates: ${place.latitude?.toStringAsFixed(4) ?? '—'}, '
                          '${place.longitude?.toStringAsFixed(4) ?? '—'}',
                      style: AppTextStyles.bodySmall
                          ?.copyWith(color: AppColors.textSecondary),
                    ),
                  ],
                ),
                const SizedBox(height: 8),

                Row(
                  children: [
                    Chip(
                      backgroundColor: AppColors.surfaceVariant,
                      label: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const Icon(Icons.visibility,
                              size: 16, color: AppColors.textSecondary),
                          const SizedBox(width: 4),
                          Text(
                            '$_currentVisitCount visits',
                            style: AppTextStyles.bodySmall
                                ?.copyWith(color: AppColors.textSecondary),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(width: 8),
                    Chip(
                      backgroundColor: AppColors.surfaceVariant,
                      label: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const Icon(Icons.favorite,
                              size: 16, color: AppColors.textSecondary),
                          const SizedBox(width: 4),
                          Text(
                            '${place.favoriteCount ?? 0} favorites',
                            style: AppTextStyles.bodySmall
                                ?.copyWith(color: AppColors.textSecondary),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),

                Text(
                  place.description ?? 'No description available',
                  style: AppTextStyles.bodyMedium
                      ?.copyWith(color: AppColors.textSecondary),
                ),
                const SizedBox(height: 16),

                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton.icon(
                    onPressed:
                    _isManagingVisit ? null : () => _toggleVisited(place),
                    icon: Icon(
                      isVisited ? Icons.check_box : Icons.check_box_outline_blank,
                      color: Colors.white,
                    ),
                    label: Text(isVisited
                        ? 'Unmark as Visited'
                        : 'Mark as Visited'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: isVisited ? AppColors.error : AppColors.success,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                  ),
                ),
                if (_visitError != null) ...[
                  const SizedBox(height: 8),
                  Text(
                    _visitError!,
                    style: AppTextStyles.bodySmall
                        ?.copyWith(color: AppColors.error),
                  ),
                ],
              ],
            ),
          ),
        ),

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
                    ..._dishes.map((dish) {
                      return Padding(
                        padding: const EdgeInsets.only(bottom: 12),
                        child: DishCard(
                          id: dish.id,
                          name: dish.name,
                          price: dish.price,
                          imageUrl: dish.imageUrl ?? '',
                          onTap: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (ctx) => DishDetailScreen(dish: dish),
                              ),
                            );
                          },
                        ),
                      );
                    }).toList(),
              ],
            ),
          ),
        ),
      ],
    );
  }
}
