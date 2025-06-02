// lib/presentation/screens/profile/admin/admin_countries_screen.dart

import 'package:flutter/material.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../../domain/entities/country.dart';
import '../../../../domain/repositories/country_repository.dart';
import '../../../../injection_container.dart';
import '../../../widgets/common/custom_app_bar.dart';
import '../../../widgets/common/loading_widget.dart';
import '../../../widgets/common/error_widget.dart' as AppError;
import '../../../widgets/forms/custom_text_field.dart';
import '../../../widgets/forms/custom_button.dart';

class AdminCountriesScreen extends StatefulWidget {
  const AdminCountriesScreen({super.key});

  @override
  State<AdminCountriesScreen> createState() => _AdminCountriesScreenState();
}

class _AdminCountriesScreenState extends State<AdminCountriesScreen> {
  final CountryRepository _countryRepository = sl<CountryRepository>();

  List<Country> _countries = [];
  bool _isLoading = true;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    _loadCountries();
  }

  Future<void> _loadCountries() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    final result = await _countryRepository.getAllCountries();
    result.fold(
          (failure) {
        setState(() {
          _errorMessage = failure.message ?? 'Failed to load countries';
          _isLoading = false;
        });
      },
          (countries) {
        setState(() {
          _countries = countries;
          _isLoading = false;
        });
      },
    );
  }

  void _showAddCountryDialog() {
    _showCountryDialog();
  }

  void _showEditCountryDialog(Country country) {
    _showCountryDialog(country: country);
  }

  void _showCountryDialog({Country? country}) {
    final isEditing = country != null;
    final nameController = TextEditingController(text: country?.name ?? '');
    final populationController = TextEditingController(
      text: country?.population?.toString() ?? '',
    );
    final continentController = TextEditingController(text: country?.continent ?? '');
    final formKey = GlobalKey<FormState>();
    bool isSubmitting = false;

    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setDialogState) => AlertDialog(
          title: Text(isEditing ? 'Edit Country' : 'Add Country'),
          content: Form(
            key: formKey,
            child: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  CustomTextField(
                    controller: nameController,
                    hintText: 'Country Name',
                    validator: (value) {
                      if (value == null || value.trim().isEmpty) {
                        return 'Please enter country name';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 16),
                  CustomTextField(
                    controller: continentController,
                    hintText: 'Continent',
                    validator: (value) {
                      if (value == null || value.trim().isEmpty) {
                        return 'Please enter continent';
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
                  final continent = continentController.text.trim();
                  final population = populationController.text.trim().isNotEmpty
                      ? int.tryParse(populationController.text.trim())
                      : null;

                  final result = isEditing
                      ? await _countryRepository.updateCountry(
                    id: country!.id,
                    name: name,
                    continent: continent,
                    population: population,
                  )
                      : await _countryRepository.createCountry(
                    name: name,
                    continent: continent,
                    population: population,
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
                      _loadCountries();
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text(
                            isEditing
                                ? 'Country updated successfully'
                                : 'Country created successfully',
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

  void _showDeleteDialog(Country country) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Country'),
        content: Text(
          'Are you sure you want to delete "${country.name}"? '
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
              await _deleteCountry(country.id);
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

  Future<void> _deleteCountry(int id) async {
    final result = await _countryRepository.deleteCountry(id);
    result.fold(
          (failure) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(failure.message ?? 'Failed to delete country'),
            backgroundColor: AppColors.error,
          ),
        );
      },
          (_) {
        _loadCountries();
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Country deleted successfully'),
            backgroundColor: AppColors.success,
          ),
        );
      },
    );
  }

  Widget _buildCountryCard(Country country) {
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: ListTile(
        leading: const CircleAvatar(
          backgroundColor: AppColors.primary,
          child: Icon(Icons.public, color: Colors.white),
        ),
        title: Text(
          country.name,
          style: AppTextStyles.titleMedium,
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Continent: ${country.continent}',
              style: AppTextStyles.bodySmall,
            ),
            if (country.population != null)
              Text(
                'Population: ${country.population}',
                style: AppTextStyles.bodySmall,
              ),
          ],
        ),
        trailing: PopupMenuButton<String>(
          onSelected: (value) {
            switch (value) {
              case 'edit':
                _showEditCountryDialog(country);
                break;
              case 'delete':
                _showDeleteDialog(country);
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
        title: 'Manage Countries',
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
              onPressed: _loadCountries,
              child: const Text('Retry'),
            ),
          ],
        ),
      )
          : RefreshIndicator(
        onRefresh: _loadCountries,
        child: _countries.isEmpty
            ? const Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                Icons.public,
                size: 64,
                color: AppColors.textHint,
              ),
              SizedBox(height: 16),
              Text(
                'No countries found',
                style: TextStyle(
                  fontSize: 18,
                  color: AppColors.textSecondary,
                ),
              ),
              SizedBox(height: 8),
              Text(
                'Tap the + button to add the first country',
                style: TextStyle(
                  color: AppColors.textHint,
                ),
              ),
            ],
          ),
        )
            : ListView.builder(
          itemCount: _countries.length,
          itemBuilder: (context, index) {
            return _buildCountryCard(_countries[index]);
          },
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _showAddCountryDialog,
        backgroundColor: AppColors.primary,
        child: const Icon(Icons.add, color: Colors.white),
      ),
    );
  }
}