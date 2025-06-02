// lib/presentation/screens/explore/cities_list_screen.dart

import 'package:flutter/material.dart';

import '../../../core/theme/app_colors.dart';
import '../../../domain/entities/city.dart';
import '../../../domain/repositories/city_repository.dart';
import '../../../injection_container.dart';
import '../../widgets/cards/city_card.dart';
import '../../widgets/common/custom_app_bar.dart';
import '../../widgets/common/error_widget.dart' as AppError;
import '../../widgets/common/loading_widget.dart';
import 'detail/city_detail_screen.dart';

class CitiesListScreen extends StatefulWidget {
  const CitiesListScreen({Key? key}) : super(key: key);

  @override
  _CitiesListScreenState createState() => _CitiesListScreenState();
}

class _CitiesListScreenState extends State<CitiesListScreen> {
  final CityRepository _cityRepository = sl<CityRepository>();

  bool _isLoading = true;
  String? _errorMessage;
  List<City> _cities = [];

  @override
  void initState() {
    super.initState();
    _loadCities();
  }

  Future<void> _loadCities() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    final result = await _cityRepository.getAllCities();
    result.fold(
          (failure) {
        setState(() {
          _errorMessage = failure.message ?? 'Failed to load cities';
          _isLoading = false;
        });
      },
          (cities) {
        setState(() {
          _cities = cities;
          _isLoading = false;
        });
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: const CustomAppBar(
        title: 'All Cities',
        automaticallyImplyLeading: true,
      ),
      backgroundColor: AppColors.background,
      body: RefreshIndicator(
        onRefresh: _loadCities,
        child: Builder(
          builder: (_) {
            if (_isLoading) {
              return const Center(child: LoadingWidget(size: 48));
            }

            if (_errorMessage != null) {
              return Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    AppError.ErrorWidget(message: _errorMessage!),
                    const SizedBox(height: 16),
                    ElevatedButton(
                      onPressed: _loadCities,
                      child: const Text('Retry'),
                    ),
                  ],
                ),
              );
            }

            if (_cities.isEmpty) {
              return const Center(child: Text('No cities found'));
            }

            return ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: _cities.length,
              itemBuilder: (context, index) {
                final city = _cities[index];
                return Padding(
                  padding: const EdgeInsets.only(bottom: 12),
                  child: CityCard(
                    cityId: city.id,
                    name: city.name,
                    population: city.population,
                    latitude: city.latitude,
                    longitude: city.longitude,
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (ctx) => CityDetailScreen(city: city),
                        ),
                      );
                    },
                  ),
                );
              },
            );
          },
        ),
      ),
    );
  }
}
