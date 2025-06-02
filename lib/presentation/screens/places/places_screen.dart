// lib/presentation/screens/places/places_screen.dart

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:tourismapp/presentation/screens/places/visited_places_screen.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../../domain/entities/place.dart';
import '../../blocs/places/places_bloc.dart';
import '../../widgets/common/custom_app_bar.dart';
import '../../widgets/common/error_widget.dart' as AppError;
import '../../widgets/common/loading_widget.dart';
import 'place_detail_screen.dart';

/// A screen that displays all places on an OpenStreetMap‐based map.
/// Tapping a marker opens PlaceDetailScreen. A “View Visited Places”
/// button is pinned at the bottom.
class PlacesScreen extends StatefulWidget {
  const PlacesScreen({Key? key}) : super(key: key);

  @override
  State<PlacesScreen> createState() => _PlacesScreenState();
}

class _PlacesScreenState extends State<PlacesScreen> {
  final MapController _mapController = MapController();

  @override
  void initState() {
    super.initState();
    // Fetch all places when this screen is first shown:
    context.read<PlacesBloc>().add(const FetchPlaces());
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: const CustomAppBar(
        title: 'Places',
        automaticallyImplyLeading: true,
      ),
      backgroundColor: AppColors.background,
      body: BlocBuilder<PlacesBloc, PlacesState>(
        builder: (context, state) {
          // 1) Loading state
          if (state is PlacesLoading) {
            return const Center(child: LoadingWidget(size: 48));
          }

          // 2) Error state
          if (state is PlacesError) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  AppError.ErrorWidget(message: state.message),
                  const SizedBox(height: 16),
                  ElevatedButton(
                    onPressed: () {
                      context.read<PlacesBloc>().add(const FetchPlaces());
                    },
                    child: const Text('Retry'),
                  ),
                ],
              ),
            );
          }

          // 3) Loaded state
          if (state is PlacesLoaded) {
            final places = state.places;
            if (places.isEmpty) {
              return const Center(child: Text('No places found'));
            }

            // Determine an initial center: use the first place’s coordinates (or fallback to 0,0).
            final initialLatLng = LatLng(
              places.first.latitude ?? 0.0,
              places.first.longitude ?? 0.0,
            );

            return Stack(
              children: [
                // ─── The map ───────────────────────────────────────────────
                FlutterMap(
                  mapController: _mapController,
                  options: MapOptions(
                    center: initialLatLng,
                    zoom: 5.0,
                    interactiveFlags: InteractiveFlag.all,
                  ),
                  children: [
                    TileLayer(
                      urlTemplate:
                      "https://{s}.tile.openstreetmap.org/{z}/{x}/{y}.png",
                      subdomains: const ['a', 'b', 'c'],
                      userAgentPackageName: 'com.example.tourismapp',
                    ),
                    MarkerLayer(
                      markers: places
                          .where((p) => p.latitude != null && p.longitude != null)
                          .map((place) {
                        return Marker(
                          width: 48,
                          height: 48,
                          point: LatLng(place.latitude!, place.longitude!),
                          builder: (ctx) => GestureDetector(
                            onTap: () {
                              // Navigate to place detail:
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (_) =>
                                      PlaceDetailScreen(placeId: place.id),
                                ),
                              );
                            },
                            child: const Icon(
                              Icons.location_on,
                              size: 36,
                              color: AppColors.primary,
                            ),
                          ),
                        );
                      }).toList(),
                    ),
                  ],
                ),

                // ─── Top‐right floating buttons (Layers & Compass) ─────────────────
                Positioned(
                  top: 16,
                  right: 16,
                  child: Column(
                    children: [
                      // Layer toggle (placeholder)
                      FloatingActionButton(
                        heroTag: 'layersBtn',
                        mini: true,
                        backgroundColor: AppColors.surface,
                        onPressed: () {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(content: Text('Layer toggle pressed')),
                          );
                        },
                        child: const Icon(Icons.layers, color: AppColors.primary),
                      ),
                      const SizedBox(height: 12),
                      // Compass (reset rotation)
                      FloatingActionButton(
                        heroTag: 'compassBtn',
                        mini: true,
                        backgroundColor: AppColors.surface,
                        onPressed: () {
                          _mapController.rotate(0.0);
                        },
                        child: const Icon(Icons.explore, color: AppColors.primary),
                      ),
                    ],
                  ),
                ),

                // ─── Bottom‐right "My Location" button ─────────────────────────────
                Positioned(
                  bottom: 100,
                  right: 16,
                  child: FloatingActionButton(
                    heroTag: 'myLocationBtn',
                    backgroundColor: AppColors.surface,
                    onPressed: () async {
                      // For now, just recenter on the first place:
                      if (places.isNotEmpty &&
                          places.first.latitude != null &&
                          places.first.longitude != null) {
                        _mapController.move(
                          LatLng(places.first.latitude!, places.first.longitude!),
                          12.0,
                        );
                      }
                    },
                    child: const Icon(Icons.my_location, color: AppColors.primary),
                  ),
                ),

                // ─── Bottom “View Visited Places” button ────────────────────────────
                Positioned(
                  bottom: 0,
                  left: 0,
                  right: 0,
                  child: SafeArea(
                    child: Padding(
                      padding:
                      const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                      child: SizedBox(
                        width: double.infinity,
                        height: 48,
                        child: ElevatedButton(
                          style: ElevatedButton.styleFrom(
                            backgroundColor: AppColors.primary,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(24),
                            ),
                          ),
                          onPressed: () {
                            // Push to your VisitedPlacesScreen (wire up this route separately)
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (_) => const VisitedPlacesScreen(),
                              ),
                            );
                          },
                          child: Text(
                            'View Visited Places',
                            style: AppTextStyles.button
                                ?.copyWith(color: Colors.white, fontSize: 16),
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            );
          }

          // 4) If still initial/fallback
          return const Center(child: LoadingWidget(size: 48));
        },
      ),
    );
  }
}
