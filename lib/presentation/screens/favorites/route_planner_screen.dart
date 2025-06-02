// lib/presentation/screens/favorites/route_planner_screen.dart

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';

import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_text_styles.dart';
import '../../../domain/entities/place.dart';
import '../../blocs/favorites/favorites_bloc.dart';
import '../../blocs/route_planner/route_planner_bloc.dart';
import '../../blocs/route_planner/route_planner_event.dart';
import '../../blocs/route_planner/route_planner_state.dart';
import '../../widgets/cards/place_card.dart';
import '../../widgets/common/custom_app_bar.dart';

/// Route Planner Screen:
///   1) “Your Favorites” – tap the “+” overlay to add that place to the working route
///   2) “Working Route” – reorderable list of place IDs in the current route
///   3) “Save Route” – enter a name and tap Save
///   4) “Saved Routes” – horizontal list of saved routes; tap to load or tap trash to delete
///   5) “Map Preview” – OSM map showing markers + polyline connecting the working route
class RoutePlannerScreen extends StatefulWidget {
  const RoutePlannerScreen({Key? key}) : super(key: key);

  @override
  State<RoutePlannerScreen> createState() => _RoutePlannerScreenState();
}

class _RoutePlannerScreenState extends State<RoutePlannerScreen> {
  final MapController _mapController = MapController();
  final TextEditingController _routeNameController = TextEditingController();

  @override
  void initState() {
    super.initState();
    // Both blocs (FavoritesBloc, RoutePlannerBloc) are already provided above.
    WidgetsBinding.instance.addPostFrameCallback((_) {
      // Load all previously‐saved routes:
      context.read<RoutePlannerBloc>().add(LoadSavedRoutes());
      // Also reload the favorites list:
      context.read<FavoritesBloc>().add(LoadFavorites());
    });
  }

  @override
  void dispose() {
    _routeNameController.dispose();
    super.dispose();
  }

  /// Given a list of favorite Place objects, find the Place matching `id`.
  Place? _findPlaceById(List<Place> favorites, int id) {
    try {
      return favorites.firstWhere((p) => p.id == id);
    } catch (_) {
      return null;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: const CustomAppBar(title: 'Route Planner'),
      backgroundColor: AppColors.background,
      body: Column(
        children: [
          // ─── “Your Favorites” ───────────────────────────────────────────
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Text(
              'Your Favorites (tap “+” to add to route)',
              style: AppTextStyles.titleMedium,
            ),
          ),
          SizedBox(
            height: 140,
            child: BlocBuilder<FavoritesBloc, FavoritesState>(
              builder: (context, favState) {
                if (favState is FavoritesLoaded) {
                  final List<Place> favs = favState.places;
                  if (favs.isEmpty) {
                    return Center(
                      child: Text(
                        'No favorites yet',
                        style: AppTextStyles.bodySmall,
                      ),
                    );
                  }
                  return ListView.separated(
                    scrollDirection: Axis.horizontal,
                    padding: const EdgeInsets.symmetric(horizontal: 12),
                    itemCount: favs.length,
                    itemBuilder: (ctx, idx) {
                      final place = favs[idx];
                      return SizedBox(
                        width: 100,
                        child: Stack(
                          children: [
                            // The place card:
                            PlaceCard(
                              place: place,
                              onTap: () {
                                // Tapping the entire card also adds it to the route
                                context
                                    .read<RoutePlannerBloc>()
                                    .add(AddPlaceToRoute(place.id));
                              },
                            ),
                            // A little “+” overlay in the top‐right:
                            Positioned(
                              top: 4,
                              right: 4,
                              child: GestureDetector(
                                onTap: () {
                                  context
                                      .read<RoutePlannerBloc>()
                                      .add(AddPlaceToRoute(place.id));
                                },
                                child: Container(
                                  decoration: BoxDecoration(
                                    color: Colors.white.withOpacity(0.8),
                                    shape: BoxShape.circle,
                                  ),
                                  child: const Icon(
                                    Icons.add_circle,
                                    color: AppColors.primary,
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                      );
                    },
                    separatorBuilder: (_, __) => const SizedBox(width: 12),
                  );
                }
                // While favorites are loading:
                return const Center(child: CircularProgressIndicator());
              },
            ),
          ),

          const Divider(height: 1),

          // ─── “Working Route” ─────────────────────────────────────────────
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Text(
              'Working Route (drag to reorder)',
              style: AppTextStyles.titleMedium,
            ),
          ),
          Expanded(
            flex: 2,
            child: BlocBuilder<RoutePlannerBloc, RoutePlannerState>(
              builder: (context, rpState) {
                if (rpState is RoutePlannerLoading) {
                  return const Center(child: CircularProgressIndicator());
                } else if (rpState is RoutePlannerLoaded) {
                  final working = rpState.workingPlaceIds;
                  if (working.isEmpty) {
                    return Center(
                      child: Text(
                        'No places in the route',
                        style: AppTextStyles.bodySmall,
                      ),
                    );
                  }

                  // We need the favorites list to translate IDs → Place objects
                  final favState = context.read<FavoritesBloc>().state;
                  final List<Place> favs =
                  favState is FavoritesLoaded ? favState.places : [];

                  return ReorderableListView.builder(
                    onReorder: (oldIndex, newIndex) {
                      context
                          .read<RoutePlannerBloc>()
                          .add(ReorderRoutePlaces(oldIndex, newIndex));
                    },
                    itemCount: working.length,
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    itemBuilder: (ctx, idx) {
                      final pid = working[idx];
                      final place = _findPlaceById(favs, pid);
                      return ListTile(
                        key: ValueKey(pid),
                        title: Text(place?.name ?? 'Place #$pid'),
                        trailing: IconButton(
                          icon: const Icon(Icons.delete, color: Colors.red),
                          onPressed: () => context
                              .read<RoutePlannerBloc>()
                              .add(RemovePlaceFromRoute(idx)),
                        ),
                      );
                    },
                  );
                }
                return Center(child: Text('Unexpected state'));
              },
            ),
          ),

          const Divider(height: 1),

          // ─── “Save Route” row ────────────────────────────────────────────
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _routeNameController,
                    decoration: InputDecoration(
                      hintText: 'Route name...',
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                      isDense: true,
                      filled: true,
                      fillColor: AppColors.inputBackground,
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                ElevatedButton(
                  onPressed: () {
                    final name = _routeNameController.text.trim();
                    if (name.isEmpty) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text('Please enter a route name'),
                          backgroundColor: AppColors.error,
                        ),
                      );
                      return;
                    }
                    context.read<RoutePlannerBloc>().add(SaveCurrentRoute(name));
                    _routeNameController.clear();
                  },
                  child: const Text('Save'),
                ),
              ],
            ),
          ),

          const Divider(height: 1),

          // ─── “Saved Routes” ─────────────────────────────────────────────
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Text(
              'Saved Routes',
              style: AppTextStyles.titleMedium,
            ),
          ),
          SizedBox(
            height: 140,
            child: BlocBuilder<RoutePlannerBloc, RoutePlannerState>(
              builder: (context, rpState) {
                if (rpState is RoutePlannerLoaded) {
                  final saved = rpState.savedRoutes;
                  if (saved.isEmpty) {
                    return Center(
                      child: Text(
                        'No saved routes',
                        style: AppTextStyles.bodySmall,
                      ),
                    );
                  }
                  return ListView.separated(
                    scrollDirection: Axis.horizontal,
                    padding: const EdgeInsets.symmetric(horizontal: 12),
                    itemCount: saved.length,
                    itemBuilder: (ctx, idx) {
                      final sr = saved[idx];
                      return Column(
                        children: [
                          GestureDetector(
                            onTap: () {
                              // Load that saved route into the “working” list for preview
                              context
                                  .read<RoutePlannerBloc>()
                                  .add(SelectSavedRoute(sr.name));
                            },
                            child: Container(
                              width: 120,
                              padding: const EdgeInsets.all(8),
                              decoration: BoxDecoration(
                                color: AppColors.surface,
                                borderRadius: BorderRadius.circular(12),
                                boxShadow: [
                                  BoxShadow(
                                    color: Colors.black.withOpacity(0.05),
                                    blurRadius: 4,
                                  ),
                                ],
                              ),
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Text(
                                    sr.name,
                                    style: AppTextStyles.bodyMedium,
                                    textAlign: TextAlign.center,
                                    maxLines: 2,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                  const Spacer(),
                                  IconButton(
                                    icon: const Icon(
                                      Icons.delete_forever,
                                      color: Colors.red,
                                    ),
                                    onPressed: () {
                                      context
                                          .read<RoutePlannerBloc>()
                                          .add(DeleteSavedRoute(sr.name));
                                    },
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ],
                      );
                    },
                    separatorBuilder: (_, __) => const SizedBox(width: 12),
                  );
                }
                return const Center(child: CircularProgressIndicator());
              },
            ),
          ),

          const Divider(height: 1),

          // ─── “Map Preview” ───────────────────────────────────────────────
          Expanded(
            flex: 3,
            child: BlocBuilder<RoutePlannerBloc, RoutePlannerState>(
              builder: (context, rpState) {
                if (rpState is RoutePlannerLoaded) {
                  final working = rpState.workingPlaceIds;
                  final favState = context.read<FavoritesBloc>().state;
                  final List<Place> favs =
                  favState is FavoritesLoaded ? favState.places : [];

                  // Build a list of LatLng points, in the same order
                  final List<LatLng> latlngs = working
                      .map((id) {
                    final place = favs.firstWhere(
                          (p) => p.id == id,
                      orElse: () => Place(
                        id: id,
                        name: '',
                        cityId: 0,
                        countryId: 0,
                        type: '',
                        latitude: 0.0,
                        longitude: 0.0,
                      ),
                    );
                    if (place.latitude != null && place.longitude != null) {
                      return LatLng(place.latitude!, place.longitude!);
                    }
                    return null;
                  })
                      .whereType<LatLng>()
                      .toList();

                  if (latlngs.isEmpty) {
                    return Center(
                      child: Text(
                        'No coordinates to preview',
                        style: AppTextStyles.bodySmall,
                      ),
                    );
                  }

                  // Center on the first point, zoom = 10
                  WidgetsBinding.instance.addPostFrameCallback((_) {
                    _mapController.move(latlngs.first, 10.0);
                  });

                  return FlutterMap(
                    mapController: _mapController,
                    options: MapOptions(
                      center: latlngs.first,
                      zoom: 10.0,
                    ),
                    children: [
                      TileLayer(
                        urlTemplate:
                        "https://{s}.tile.openstreetmap.org/{z}/{x}/{y}.png",
                        subdomains: const ['a', 'b', 'c'],
                        userAgentPackageName: 'com.example.tourismapp',
                      ),
                      MarkerLayer(
                        markers: latlngs
                            .map(
                              (pt) => Marker(
                            width: 32,
                            height: 32,
                            point: pt,
                            builder: (ctx) => const Icon(
                              Icons.location_on,
                              size: 32,
                              color: AppColors.primary,
                            ),
                          ),
                        )
                            .toList(),
                      ),
                      PolylineLayer(
                        polylines: [
                          Polyline(
                            points: latlngs,
                            strokeWidth: 4,
                            color: AppColors.primary,
                          ),
                        ],
                      ),
                    ],
                  );
                }

                return const Center(child: CircularProgressIndicator());
              },
            ),
          ),
        ],
      ),
    );
  }
}
