// lib/presentation/screens/profile/admin/admin_places_screen.dart

import 'package:flutter/material.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../../domain/entities/place.dart';
import '../../../../domain/entities/city.dart';
import '../../../../domain/entities/country.dart';
import '../../../../domain/repositories/place_repository.dart';
import '../../../../domain/repositories/city_repository.dart';
import '../../../../domain/repositories/country_repository.dart';
import '../../../../injection_container.dart';
import '../../../widgets/common/custom_app_bar.dart';
import '../../../widgets/common/loading_widget.dart';
import '../../../widgets/common/error_widget.dart' as AppError;
import '../../../widgets/forms/custom_text_field.dart';
import '../../../widgets/forms/custom_button.dart';

class AdminPlacesScreen extends StatefulWidget {
  const AdminPlacesScreen({super.key});

  @override
  State<AdminPlacesScreen> createState() => _AdminPlacesScreenState();
}

class _AdminPlacesScreenState extends State<AdminPlacesScreen> {
  final PlaceRepository _placeRepository = sl<PlaceRepository>();
  final CityRepository _cityRepository = sl<CityRepository>();
  final CountryRepository _countryRepository = sl<CountryRepository>();

  List<Place> _places = [];
  List<City> _cities = [];
  List<Country> _countries = [];
  bool _isLoading = true;
  String? _errorMessage;

  // Place types available
  final List<String> _placeTypes = [
    'church',
    'stadium',
    'museum',
    'restaurant',
    'hotel',
    'park',
    'monument',
    'theater',
    'square',
    'other'
  ];

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      final results = await Future.wait([
        _placeRepository.getAllPlaces(),
        _cityRepository.getAllCities(),
        _countryRepository.getAllCountries(),
      ]);

      results[0].fold(
            (failure) => throw Exception(failure.message ?? 'Failed to load places'),
            (places) => _places = places as List<Place>,
      );

      results[1].fold(
            (failure) => throw Exception(failure.message ?? 'Failed to load cities'),
            (cities) => _cities = cities as List<City>,
      );

      results[2].fold(
            (failure) => throw Exception(failure.message ?? 'Failed to load countries'),
            (countries) => _countries = countries as List<Country>,
      );

      setState(() {
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _errorMessage = e.toString();
        _isLoading = false;
      });
    }
  }

  void _showAddPlaceDialog() {
    _showPlaceDialog();
  }

  void _showEditPlaceDialog(Place place) {
    _showPlaceDialog(place: place);
  }

  void _showPlaceDialog({Place? place}) {
    if (_cities.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please add cities first before creating places'),
          backgroundColor: AppColors.warning,
        ),
      );
      return;
    }

    final isEditing = place != null;
    final nameController = TextEditingController(text: place?.name ?? '');
    final addressController = TextEditingController(text: place?.address ?? '');
    final descriptionController = TextEditingController(text: place?.description ?? '');
    final imageUrlController = TextEditingController(text: place?.imageUrl ?? '');
    final latitudeController = TextEditingController(
      text: place?.latitude?.toString() ?? '',
    );
    final longitudeController = TextEditingController(
      text: place?.longitude?.toString() ?? '',
    );

    City? selectedCity;
    Country? selectedCountry;
    String selectedType = isEditing ? place!.type : _placeTypes.first;

    if (isEditing) {
      selectedCity = _cities.firstWhere((c) => c.id == place!.cityId);
      selectedCountry = _countries.firstWhere((c) => c.id == place.countryId);
    } else {
      selectedCountry = _countries.first;
      final citiesInCountry = _cities.where((c) => c.countryId == selectedCountry!.id).toList();
      selectedCity = citiesInCountry.isNotEmpty ? citiesInCountry.first : null;
    }

    final formKey = GlobalKey<FormState>();
    bool isSubmitting = false;

    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setDialogState) => AlertDialog(
          title: Text(isEditing ? 'Edit Place' : 'Add Place'),
          content: Form(
            key: formKey,
            child: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  CustomTextField(
                    controller: nameController,
                    hintText: 'Place Name',
                    validator: (value) {
                      if (value == null || value.trim().isEmpty) {
                        return 'Please enter place name';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 16),
                  DropdownButtonFormField<String>(
                    value: selectedType,
                    decoration: const InputDecoration(
                      labelText: 'Type',
                      border: OutlineInputBorder(),
                    ),
                    items: _placeTypes.map((type) {
                      return DropdownMenuItem(
                        value: type,
                        child: Text(type),
                      );
                    }).toList(),
                    onChanged: (type) {
                      setDialogState(() {
                        selectedType = type!;
                      });
                    },
                  ),
                  const SizedBox(height: 16),
                  DropdownButtonFormField<Country>(
                    value: selectedCountry,
                    decoration: const InputDecoration(
                      labelText: 'Country',
                      border: OutlineInputBorder(),
                    ),
                    items: _countries.map((country) {
                      return DropdownMenuItem(
                        value: country,
                        child: Text(country.name),
                      );
                    }).toList(),
                    onChanged: (country) {
                      setDialogState(() {
                        selectedCountry = country;
                        // Reset city selection when country changes
                        final citiesInCountry = _cities.where((c) => c.countryId == country!.id).toList();
                        selectedCity = citiesInCountry.isNotEmpty ? citiesInCountry.first : null;
                      });
                    },
                    validator: (value) {
                      if (value == null) {
                        return 'Please select a country';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 16),
                  DropdownButtonFormField<City>(
                    value: selectedCity,
                    decoration: const InputDecoration(
                      labelText: 'City',
                      border: OutlineInputBorder(),
                    ),
                    items: selectedCountry != null
                        ? _cities.where((c) => c.countryId == selectedCountry!.id).map((city) {
                      return DropdownMenuItem(
                        value: city,
                        child: Text(city.name),
                      );
                    }).toList()
                        : [],
                    onChanged: (city) {
                      setDialogState(() {
                        selectedCity = city;
                      });
                    },
                    validator: (value) {
                      if (value == null) {
                        return 'Please select a city';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 16),
                  CustomTextField(
                    controller: addressController,
                    hintText: 'Address (optional)',
                  ),
                  const SizedBox(height: 16),
                  CustomTextField(
                    controller: descriptionController,
                    hintText: 'Description (optional)',
                    keyboardType: TextInputType.multiline,
                  ),
                  const SizedBox(height: 16),
                  CustomTextField(
                    controller: imageUrlController,
                    hintText: 'Image URL (optional)',
                  ),
                  const SizedBox(height: 16),
                  Row(
                    children: [
                      Expanded(
                        child: CustomTextField(
                          controller: latitudeController,
                          hintText: 'Latitude (optional)',
                          keyboardType: const TextInputType.numberWithOptions(decimal: true),
                          validator: (value) {
                            if (value != null && value.isNotEmpty) {
                              if (double.tryParse(value) == null) {
                                return 'Invalid latitude';
                              }
                            }
                            return null;
                          },
                        ),
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: CustomTextField(
                          controller: longitudeController,
                          hintText: 'Longitude (optional)',
                          keyboardType: const TextInputType.numberWithOptions(decimal: true),
                          validator: (value) {
                            if (value != null && value.isNotEmpty) {
                              if (double.tryParse(value) == null) {
                                return 'Invalid longitude';
                              }
                            }
                            return null;
                          },
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
          actions: [
            TextButton(
              onPressed: isSubmitting ? null : () => Navigator.pop(context),
              child: const Text('Cancel'),
            ),
            ElevatedButton(
              onPressed: isSubmitting
                  ? null
                  : () async {
                if (formKey.currentState!.validate()) {
                  setDialogState(() => isSubmitting = true);

                  final name = nameController.text.trim();
                  final type = selectedType;
                  final cityId = selectedCity!.id;
                  final countryId = selectedCountry!.id;
                  final address = addressController.text.trim().isNotEmpty
                      ? addressController.text.trim()
                      : null;
                  final description = descriptionController.text.trim().isNotEmpty
                      ? descriptionController.text.trim()
                      : null;
                  final imageUrl = imageUrlController.text.trim().isNotEmpty
                      ? imageUrlController.text.trim()
                      : null;
                  final latitude = latitudeController.text.trim().isNotEmpty
                      ? double.tryParse(latitudeController.text.trim())
                      : null;
                  final longitude = longitudeController.text.trim().isNotEmpty
                      ? double.tryParse(longitudeController.text.trim())
                      : null;

                  final result = isEditing
                      ? await _placeRepository.updatePlace(
                    id: place!.id,
                    name: name,
                    type: type,
                    cityId: cityId,
                    countryId: countryId,
                    address: address,
                    description: description,
                    imageUrl: imageUrl,
                    latitude: latitude,
                    longitude: longitude,
                  )
                      : await _placeRepository.createPlace(
                    name: name,
                    type: type,
                    cityId: cityId,
                    countryId: countryId,
                    address: address,
                    description: description,
                    imageUrl: imageUrl,
                    latitude: latitude,
                    longitude: longitude,
                  );

                  result.fold(
                        (failure) {
                      setDialogState(() => isSubmitting = false);
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text(failure.message ?? 'Operation failed'),
                          backgroundColor: AppColors.error,
                        ),
                      );
                    },
                        (success) {
                      Navigator.pop(context);
                      _loadData();
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text(
                            isEditing
                                ? 'Place updated successfully'
                                : 'Place created successfully',
                          ),
                          backgroundColor: AppColors.success,
                        ),
                      );
                    },
                  );
                }
              },
              child: isSubmitting
                  ? const SizedBox(
                width: 16,
                height: 16,
                child: CircularProgressIndicator(strokeWidth: 2),
              )
                  : Text(isEditing ? 'Update' : 'Create'),
            ),
          ],
        ),
      ),
    );
  }

  void _showDeleteDialog(Place place) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Place'),
        content: Text(
          'Are you sure you want to delete "${place.name}"? '
              'This action cannot be undone and may affect related data.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () async {
              Navigator.pop(context);
              await _deletePlace(place.id);
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.error,
            ),
            child: const Text('Delete'),
          ),
        ],
      ),
    );
  }

  Future<void> _deletePlace(int id) async {
    final result = await _placeRepository.deletePlace(id);
    result.fold(
          (failure) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(failure.message ?? 'Failed to delete place'),
            backgroundColor: AppColors.error,
          ),
        );
      },
          (_) {
        _loadData();
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Place deleted successfully'),
            backgroundColor: AppColors.success,
          ),
        );
      },
    );
  }

  String _getCityName(int cityId) {
    try {
      return _cities.firstWhere((c) => c.id == cityId).name;
    } catch (e) {
      return 'Unknown City';
    }
  }

  String _getCountryName(int countryId) {
    try {
      return _countries.firstWhere((c) => c.id == countryId).name;
    } catch (e) {
      return 'Unknown Country';
    }
  }

  Widget _buildPlaceCard(Place place) {
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: ListTile(
        leading: const CircleAvatar(
          backgroundColor: AppColors.success,
          child: Icon(Icons.place, color: Colors.white),
        ),
        title: Text(
          place.name,
          style: AppTextStyles.titleMedium,
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Type: ${place.typeDisplayName}',
              style: AppTextStyles.bodySmall,
            ),
            Text(
              'City: ${_getCityName(place.cityId)}',
              style: AppTextStyles.bodySmall,
            ),
            Text(
              'Country: ${_getCountryName(place.countryId)}',
              style: AppTextStyles.bodySmall,
            ),
            if (place.visitCount != null)
              Text(
                'Visits: ${place.visitCount}',
                style: AppTextStyles.bodySmall,
              ),
          ],
        ),
        trailing: PopupMenuButton<String>(
          onSelected: (value) {
            switch (value) {
              case 'edit':
                _showEditPlaceDialog(place);
                break;
              case 'delete':
                _showDeleteDialog(place);
                break;
            }
          },
          itemBuilder: (context) => [
            const PopupMenuItem(
              value: 'edit',
              child: Row(
                children: [
                  Icon(Icons.edit, size: 20),
                  SizedBox(width: 8),
                  Text('Edit'),
                ],
              ),
            ),
            const PopupMenuItem(
              value: 'delete',
              child: Row(
                children: [
                  Icon(Icons.delete, color: AppColors.error, size: 20),
                  SizedBox(width: 8),
                  Text('Delete', style: TextStyle(color: AppColors.error)),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: const CustomAppBar(
        title: 'Manage Places',
        automaticallyImplyLeading: true,
      ),
      body: _isLoading
          ? const Center(child: LoadingWidget(size: 48))
          : _errorMessage != null
          ? Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            AppError.ErrorWidget(message: _errorMessage!),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: _loadData,
              child: const Text('Retry'),
            ),
          ],
        ),
      )
          : RefreshIndicator(
        onRefresh: _loadData,
        child: _places.isEmpty
            ? const Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                Icons.place,
                size: 64,
                color: AppColors.textHint,
              ),
              SizedBox(height: 16),
              Text(
                'No places found',
                style: TextStyle(
                  fontSize: 18,
                  color: AppColors.textSecondary,
                ),
              ),
              SizedBox(height: 8),
              Text(
                'Tap the + button to add the first place',
                style: TextStyle(
                  color: AppColors.textHint,
                ),
              ),
            ],
          ),
        )
            : ListView.builder(
          itemCount: _places.length,
          itemBuilder: (context, index) {
            return _buildPlaceCard(_places[index]);
          },
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _showAddPlaceDialog,
        backgroundColor: AppColors.primary,
        child: const Icon(Icons.add, color: Colors.white),
      ),
    );
  }
}