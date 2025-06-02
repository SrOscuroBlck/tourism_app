// lib/presentation/screens/profile/admin/admin_dishes_screen.dart

import 'package:flutter/material.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../../domain/entities/dish.dart';
import '../../../../domain/entities/place.dart';
import '../../../../domain/entities/country.dart';
import '../../../../domain/repositories/dish_repository.dart';
import '../../../../domain/repositories/place_repository.dart';
import '../../../../domain/repositories/country_repository.dart';
import '../../../../injection_container.dart';
import '../../../widgets/common/custom_app_bar.dart';
import '../../../widgets/common/loading_widget.dart';
import '../../../widgets/common/error_widget.dart' as AppError;
import '../../../widgets/forms/custom_text_field.dart';
import '../../../widgets/forms/custom_button.dart';

class AdminDishesScreen extends StatefulWidget {
  const AdminDishesScreen({super.key});

  @override
  State<AdminDishesScreen> createState() => _AdminDishesScreenState();
}

class _AdminDishesScreenState extends State<AdminDishesScreen> {
  final DishRepository _dishRepository = sl<DishRepository>();
  final PlaceRepository _placeRepository = sl<PlaceRepository>();
  final CountryRepository _countryRepository = sl<CountryRepository>();

  List<Dish> _dishes = [];
  List<Place> _places = [];
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
        _dishRepository.getAllDishes(),
        _placeRepository.getAllPlaces(),
        _countryRepository.getAllCountries(),
      ]);

      results[0].fold(
            (failure) => throw Exception(failure.message ?? 'Failed to load dishes'),
            (dishes) => _dishes = dishes as List<Dish>,
      );

      results[1].fold(
            (failure) => throw Exception(failure.message ?? 'Failed to load places'),
            (places) => _places = places as List<Place>,
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

  void _showAddDishDialog() {
    _showDishDialog();
  }

  void _showEditDishDialog(Dish dish) {
    _showDishDialog(dish: dish);
  }

  void _showDishDialog({Dish? dish}) {
    if (_places.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please add places first before creating dishes'),
          backgroundColor: AppColors.warning,
        ),
      );
      return;
    }

    final isEditing = dish != null;
    final nameController = TextEditingController(text: dish?.name ?? '');
    final descriptionController = TextEditingController(text: dish?.description ?? '');
    final priceController = TextEditingController(text: dish?.price.toString() ?? '');
    final imageUrlController = TextEditingController(text: dish?.imageUrl ?? '');

    Place? selectedPlace;
    Country? selectedCountry;

    if (isEditing) {
      selectedPlace = _places.firstWhere((p) => p.id == dish!.placeId);
      selectedCountry = _countries.firstWhere((c) => c.id == dish.countryId);
    } else {
      selectedCountry = _countries.first;
      final placesInCountry = _places.where((p) => p.countryId == selectedCountry!.id).toList();
      selectedPlace = placesInCountry.isNotEmpty ? placesInCountry.first : null;
    }

    final formKey = GlobalKey<FormState>();
    bool isSubmitting = false;

    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setDialogState) => AlertDialog(
          title: Text(isEditing ? 'Edit Dish' : 'Add Dish'),
          content: Form(
            key: formKey,
            child: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  CustomTextField(
                    controller: nameController,
                    hintText: 'Dish Name',
                    validator: (value) {
                      if (value == null || value.trim().isEmpty) {
                        return 'Please enter dish name';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 16),
                  CustomTextField(
                    controller: priceController,
                    hintText: 'Price',
                    keyboardType: const TextInputType.numberWithOptions(decimal: true),
                    validator: (value) {
                      if (value == null || value.trim().isEmpty) {
                        return 'Please enter price';
                      }
                      if (double.tryParse(value.trim()) == null) {
                        return 'Please enter a valid price';
                      }
                      final price = double.parse(value.trim());
                      if (price < 0) {
                        return 'Price cannot be negative';
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
                        // Reset place selection when country changes
                        final placesInCountry = _places.where((p) => p.countryId == country!.id).toList();
                        selectedPlace = placesInCountry.isNotEmpty ? placesInCountry.first : null;
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
                  DropdownButtonFormField<Place>(
                    value: selectedPlace,
                    decoration: const InputDecoration(
                      labelText: 'Available at Place',
                      border: OutlineInputBorder(),
                    ),
                    items: selectedCountry != null
                        ? _places.where((p) => p.countryId == selectedCountry!.id).map((place) {
                      return DropdownMenuItem(
                        value: place,
                        child: Text(place.name),
                      );
                    }).toList()
                        : [],
                    onChanged: (place) {
                      setDialogState(() {
                        selectedPlace = place;
                      });
                    },
                    validator: (value) {
                      if (value == null) {
                        return 'Please select a place';
                      }
                      return null;
                    },
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
                  final price = double.parse(priceController.text.trim());
                  final placeId = selectedPlace!.id;
                  final countryId = selectedCountry!.id;
                  final description = descriptionController.text.trim().isNotEmpty
                      ? descriptionController.text.trim()
                      : null;
                  final imageUrl = imageUrlController.text.trim().isNotEmpty
                      ? imageUrlController.text.trim()
                      : null;

                  final result = isEditing
                      ? await _dishRepository.updateDish(
                    id: dish!.id,
                    name: name,
                    price: price,
                    placeId: placeId,
                    countryId: countryId,
                    description: description,
                    imageUrl: imageUrl,
                  )
                      : await _dishRepository.createDish(
                    name: name,
                    price: price,
                    placeId: placeId,
                    countryId: countryId,
                    description: description,
                    imageUrl: imageUrl,
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
                                ? 'Dish updated successfully'
                                : 'Dish created successfully',
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

  void _showDeleteDialog(Dish dish) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Dish'),
        content: Text(
          'Are you sure you want to delete "${dish.name}"? '
              'This action cannot be undone.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () async {
              Navigator.pop(context);
              await _deleteDish(dish.id);
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

  Future<void> _deleteDish(int id) async {
    final result = await _dishRepository.deleteDish(id);
    result.fold(
          (failure) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(failure.message ?? 'Failed to delete dish'),
            backgroundColor: AppColors.error,
          ),
        );
      },
          (_) {
        _loadData();
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Dish deleted successfully'),
            backgroundColor: AppColors.success,
          ),
        );
      },
    );
  }

  String _getPlaceName(int placeId) {
    try {
      return _places.firstWhere((p) => p.id == placeId).name;
    } catch (e) {
      return 'Unknown Place';
    }
  }

  String _getCountryName(int countryId) {
    try {
      return _countries.firstWhere((c) => c.id == countryId).name;
    } catch (e) {
      return 'Unknown Country';
    }
  }

  Widget _buildDishCard(Dish dish) {
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: ListTile(
        leading: CircleAvatar(
          backgroundColor: AppColors.error,
          backgroundImage: dish.imageUrl != null && dish.imageUrl!.isNotEmpty
              ? NetworkImage(dish.imageUrl!)
              : null,
          child: dish.imageUrl == null || dish.imageUrl!.isEmpty
              ? const Icon(Icons.restaurant, color: Colors.white)
              : null,
        ),
        title: Text(
          dish.name,
          style: AppTextStyles.titleMedium,
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Price: \$${dish.price.toStringAsFixed(2)}',
              style: AppTextStyles.bodySmall.copyWith(
                color: AppColors.primary,
                fontWeight: FontWeight.w600,
              ),
            ),
            Text(
              'Place: ${_getPlaceName(dish.placeId)}',
              style: AppTextStyles.bodySmall,
            ),
            Text(
              'Country: ${_getCountryName(dish.countryId)}',
              style: AppTextStyles.bodySmall,
            ),
            if (dish.description != null)
              Text(
                dish.description!,
                style: AppTextStyles.bodySmall.copyWith(
                  color: AppColors.textSecondary,
                ),
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
          ],
        ),
        trailing: PopupMenuButton<String>(
          onSelected: (value) {
            switch (value) {
              case 'edit':
                _showEditDishDialog(dish);
                break;
              case 'delete':
                _showDeleteDialog(dish);
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
        title: 'Manage Dishes',
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
        child: _dishes.isEmpty
            ? const Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                Icons.restaurant,
                size: 64,
                color: AppColors.textHint,
              ),
              SizedBox(height: 16),
              Text(
                'No dishes found',
                style: TextStyle(
                  fontSize: 18,
                  color: AppColors.textSecondary,
                ),
              ),
              SizedBox(height: 8),
              Text(
                'Tap the + button to add the first dish',
                style: TextStyle(
                  color: AppColors.textHint,
                ),
              ),
            ],
          ),
        )
            : ListView.builder(
          itemCount: _dishes.length,
          itemBuilder: (context, index) {
            return _buildDishCard(_dishes[index]);
          },
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _showAddDishDialog,
        backgroundColor: AppColors.primary,
        child: const Icon(Icons.add, color: Colors.white),
      ),
    );
  }
}