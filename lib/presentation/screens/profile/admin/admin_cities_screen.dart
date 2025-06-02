// lib/presentation/screens/profile/admin/admin_cities_screen.dart

import 'package:flutter/material.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../../domain/entities/city.dart';
import '../../../../domain/entities/country.dart';
import '../../../../domain/repositories/city_repository.dart';
import '../../../../domain/repositories/country_repository.dart';
import '../../../../injection_container.dart';
import '../../../widgets/common/custom_app_bar.dart';
import '../../../widgets/common/loading_widget.dart';
import '../../../widgets/common/error_widget.dart' as AppError;
import '../../../widgets/forms/custom_text_field.dart';
import '../../../widgets/forms/custom_button.dart';

class AdminCitiesScreen extends StatefulWidget {
  const AdminCitiesScreen({super.key});

  @override
  State<AdminCitiesScreen> createState() => _AdminCitiesScreenState();
}

class _AdminCitiesScreenState extends State<AdminCitiesScreen> {
  final CityRepository _cityRepository = sl<CityRepository>();
  final CountryRepository _countryRepository = sl<CountryRepository>();

  List<City> _cities = [];
  List<Country> _countries = [];
  bool _isLoading = true;
  String? _errorMessage;

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
        _cityRepository.getAllCities(),
        _countryRepository.getAllCountries(),
      ]);

      results[0].fold(
            (failure) => throw Exception(failure.message ?? 'Failed to load cities'),
            (cities) => _cities = cities as List<City>,
      );

      results[1].fold(
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

  void _showAddCityDialog() {
    _showCityDialog();
  }

  void _showEditCityDialog(City city) {
    _showCityDialog(city: city);
  }

  void _showCityDialog({City? city}) {
    if (_countries.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please add countries first before creating cities'),
          backgroundColor: AppColors.warning,
        ),
      );
      return;
    }

    final isEditing = city != null;
    final nameController = TextEditingController(text: city?.name ?? '');
    final populationController = TextEditingController(
      text: city?.population?.toString() ?? '',
    );
    final latitudeController = TextEditingController(
      text: city?.latitude?.toString() ?? '',
    );
    final longitudeController = TextEditingController(
      text: city?.longitude?.toString() ?? '',
    );

    Country? selectedCountry = isEditing
        ? _countries.firstWhere((c) => c.id == city!.countryId)
        : _countries.first;

    final formKey = GlobalKey<FormState>();
    bool isSubmitting = false;

    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setDialogState) => AlertDialog(
          title: Text(isEditing ? 'Edit City' : 'Add City'),
          content: Form(
            key: formKey,
            child: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  CustomTextField(
                    controller: nameController,
                    hintText: 'City Name',
                    validator: (value) {
                      if (value == null || value.trim().isEmpty) {
                        return 'Please enter city name';
                      }
                      return null;
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
                  CustomTextField(
                    controller: populationController,
                    hintText: 'Population (optional)',
                    keyboardType: TextInputType.number,
                    validator: (value) {
                      if (value != null && value.isNotEmpty) {
                        if (int.tryParse(value) == null) {
                          return 'Please enter a valid number';
                        }
                      }
                      return null;
                    },
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
                  final countryId = selectedCountry!.id;
                  final population = populationController.text.trim().isNotEmpty
                      ? int.tryParse(populationController.text.trim())
                      : null;
                  final latitude = latitudeController.text.trim().isNotEmpty
                      ? double.tryParse(latitudeController.text.trim())
                      : null;
                  final longitude = longitudeController.text.trim().isNotEmpty
                      ? double.tryParse(longitudeController.text.trim())
                      : null;

                  final result = isEditing
                      ? await _cityRepository.updateCity(
                    id: city!.id,
                    name: name,
                    countryId: countryId,
                    population: population,
                    latitude: latitude,
                    longitude: longitude,
                  )
                      : await _cityRepository.createCity(
                    name: name,
                    countryId: countryId,
                    population: population,
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
                                ? 'City updated successfully'
                                : 'City created successfully',
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

  void _showDeleteDialog(City city) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete City'),
        content: Text(
          'Are you sure you want to delete "${city.name}"? '
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
              await _deleteCity(city.id);
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

  Future<void> _deleteCity(int id) async {
    final result = await _cityRepository.deleteCity(id);
    result.fold(
          (failure) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(failure.message ?? 'Failed to delete city'),
            backgroundColor: AppColors.error,
          ),
        );
      },
          (_) {
        _loadData();
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('City deleted successfully'),
            backgroundColor: AppColors.success,
          ),
        );
      },
    );
  }

  String _getCountryName(int countryId) {
    try {
      return _countries.firstWhere((c) => c.id == countryId).name;
    } catch (e) {
      return 'Unknown Country';
    }
  }

  Widget _buildCityCard(City city) {
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: ListTile(
        leading: const CircleAvatar(
          backgroundColor: AppColors.secondary,
          child: Icon(Icons.location_city, color: Colors.white),
        ),
        title: Text(
          city.name,
          style: AppTextStyles.titleMedium,
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Country: ${_getCountryName(city.countryId)}',
              style: AppTextStyles.bodySmall,
            ),
            if (city.population != null)
              Text(
                'Population: ${city.population}',
                style: AppTextStyles.bodySmall,
              ),
            if (city.latitude != null && city.longitude != null)
              Text(
                'Location: ${city.latitude!.toStringAsFixed(3)}, ${city.longitude!.toStringAsFixed(3)}',
                style: AppTextStyles.bodySmall,
              ),
          ],
        ),
        trailing: PopupMenuButton<String>(
          onSelected: (value) {
            switch (value) {
              case 'edit':
                _showEditCityDialog(city);
                break;
              case 'delete':
                _showDeleteDialog(city);
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
        title: 'Manage Cities',
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
        child: _cities.isEmpty
            ? const Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                Icons.location_city,
                size: 64,
                color: AppColors.textHint,
              ),
              SizedBox(height: 16),
              Text(
                'No cities found',
                style: TextStyle(
                  fontSize: 18,
                  color: AppColors.textSecondary,
                ),
              ),
              SizedBox(height: 8),
              Text(
                'Tap the + button to add the first city',
                style: TextStyle(
                  color: AppColors.textHint,
                ),
              ),
            ],
          ),
        )
            : ListView.builder(
          itemCount: _cities.length,
          itemBuilder: (context, index) {
            return _buildCityCard(_cities[index]);
          },
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _showAddCityDialog,
        backgroundColor: AppColors.primary,
        child: const Icon(Icons.add, color: Colors.white),
      ),
    );
  }
}