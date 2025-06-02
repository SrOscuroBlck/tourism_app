// lib/presentation/screens/profile/admin/admin_people_screen.dart

import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../../domain/entities/person.dart';
import '../../../../domain/entities/city.dart';
import '../../../../domain/entities/country.dart';
import '../../../../domain/repositories/person_repository.dart';
import '../../../../domain/repositories/city_repository.dart';
import '../../../../domain/repositories/country_repository.dart';
import '../../../../injection_container.dart';
import '../../../widgets/common/custom_app_bar.dart';
import '../../../widgets/common/loading_widget.dart';
import '../../../widgets/common/error_widget.dart' as AppError;
import '../../../widgets/forms/custom_text_field.dart';
import '../../../widgets/forms/custom_button.dart';

class AdminPeopleScreen extends StatefulWidget {
  const AdminPeopleScreen({super.key});

  @override
  State<AdminPeopleScreen> createState() => _AdminPeopleScreenState();
}

class _AdminPeopleScreenState extends State<AdminPeopleScreen> {
  final PersonRepository _personRepository = sl<PersonRepository>();
  final CityRepository _cityRepository = sl<CityRepository>();
  final CountryRepository _countryRepository = sl<CountryRepository>();

  List<Person> _people = [];
  List<City> _cities = [];
  List<Country> _countries = [];
  bool _isLoading = true;
  String? _errorMessage;

  // Person categories
  final List<String> _categories = [
    'Actor',
    'Athlete',
    'Musician',
    'Politician',
    'Writer',
    'Scientist',
    'Artist',
    'Director',
    'Historical Figure',
    'Other',
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
        _personRepository.getAllPeople(),
        _cityRepository.getAllCities(),
        _countryRepository.getAllCountries(),
      ]);

      results[0].fold(
            (failure) => throw Exception(failure.message ?? 'Failed to load people'),
            (people) => _people = people as List<Person>,
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

  void _showAddPersonDialog() {
    _showPersonDialog();
  }

  void _showEditPersonDialog(Person person) {
    _showPersonDialog(person: person);
  }

  void _showPersonDialog({Person? person}) {
    if (_cities.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please add cities first before creating people'),
          backgroundColor: AppColors.warning,
        ),
      );
      return;
    }

    final isEditing = person != null;
    final nameController = TextEditingController(text: person?.name ?? '');
    final biographyController = TextEditingController(text: person?.biography ?? '');
    final imageUrlController = TextEditingController(text: person?.imageUrl ?? '');

    City? selectedCity;
    Country? selectedCountry;
    String selectedCategory = isEditing ? person!.category : _categories.first;
    DateTime? selectedBirthDate = person?.birthDate;

    if (isEditing) {
      selectedCity = _cities.firstWhere((c) => c.id == person!.cityId);
      selectedCountry = _countries.firstWhere((c) => c.id == person.countryId);
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
          title: Text(isEditing ? 'Edit Person' : 'Add Person'),
          content: Form(
            key: formKey,
            child: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  CustomTextField(
                    controller: nameController,
                    hintText: 'Full Name',
                    validator: (value) {
                      if (value == null || value.trim().isEmpty) {
                        return 'Please enter person name';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 16),
                  DropdownButtonFormField<String>(
                    value: selectedCategory,
                    decoration: const InputDecoration(
                      labelText: 'Category',
                      border: OutlineInputBorder(),
                    ),
                    items: _categories.map((category) {
                      return DropdownMenuItem(
                        value: category,
                        child: Text(category),
                      );
                    }).toList(),
                    onChanged: (category) {
                      setDialogState(() {
                        selectedCategory = category!;
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
                  InkWell(
                    onTap: () async {
                      final date = await showDatePicker(
                        context: context,
                        initialDate: selectedBirthDate ?? DateTime(1990),
                        firstDate: DateTime(1800),
                        lastDate: DateTime.now(),
                      );
                      if (date != null) {
                        setDialogState(() {
                          selectedBirthDate = date;
                        });
                      }
                    },
                    child: InputDecorator(
                      decoration: const InputDecoration(
                        labelText: 'Birth Date (optional)',
                        border: OutlineInputBorder(),
                        suffixIcon: Icon(Icons.calendar_today),
                      ),
                      child: Text(
                        selectedBirthDate != null
                            ? DateFormat.yMMMd().format(selectedBirthDate!)
                            : 'Select birth date',
                        style: selectedBirthDate != null
                            ? null
                            : const TextStyle(color: AppColors.textHint),
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),
                  CustomTextField(
                    controller: biographyController,
                    hintText: 'Biography (optional)',
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
                  final category = selectedCategory;
                  final cityId = selectedCity!.id;
                  final countryId = selectedCountry!.id;
                  final biography = biographyController.text.trim().isNotEmpty
                      ? biographyController.text.trim()
                      : null;
                  final imageUrl = imageUrlController.text.trim().isNotEmpty
                      ? imageUrlController.text.trim()
                      : null;
                  final birthDate = selectedBirthDate?.toIso8601String().split('T')[0];

                  final result = isEditing
                      ? await _personRepository.updatePerson(
                    id: person!.id,
                    name: name,
                    category: category,
                    cityId: cityId,
                    countryId: countryId,
                    biography: biography,
                    imageUrl: imageUrl,
                    birthDate: birthDate,
                  )
                      : await _personRepository.createPerson(
                    name: name,
                    category: category,
                    cityId: cityId,
                    countryId: countryId,
                    biography: biography,
                    imageUrl: imageUrl,
                    birthDate: birthDate,
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
                                ? 'Person updated successfully'
                                : 'Person created successfully',
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

  void _showDeleteDialog(Person person) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Person'),
        content: Text(
          'Are you sure you want to delete "${person.name}"? '
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
              await _deletePerson(person.id);
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

  Future<void> _deletePerson(int id) async {
    final result = await _personRepository.deletePerson(id);
    result.fold(
          (failure) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(failure.message ?? 'Failed to delete person'),
            backgroundColor: AppColors.error,
          ),
        );
      },
          (_) {
        _loadData();
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Person deleted successfully'),
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

  Widget _buildPersonCard(Person person) {
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: ListTile(
        leading: CircleAvatar(
          backgroundColor: AppColors.warning,
          backgroundImage: person.imageUrl != null && person.imageUrl!.isNotEmpty
              ? NetworkImage(person.imageUrl!)
              : null,
          child: person.imageUrl == null || person.imageUrl!.isEmpty
              ? const Icon(Icons.person, color: Colors.white)
              : null,
        ),
        title: Text(
          person.name,
          style: AppTextStyles.titleMedium,
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Category: ${person.category}',
              style: AppTextStyles.bodySmall,
            ),
            Text(
              'City: ${_getCityName(person.cityId)}',
              style: AppTextStyles.bodySmall,
            ),
            Text(
              'Country: ${_getCountryName(person.countryId)}',
              style: AppTextStyles.bodySmall,
            ),
            if (person.birthDate != null)
              Text(
                'Born: ${DateFormat.yMMMd().format(person.birthDate!)}',
                style: AppTextStyles.bodySmall,
              ),
          ],
        ),
        trailing: PopupMenuButton<String>(
          onSelected: (value) {
            switch (value) {
              case 'edit':
                _showEditPersonDialog(person);
                break;
              case 'delete':
                _showDeleteDialog(person);
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
        title: 'Manage People',
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
        child: _people.isEmpty
            ? const Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                Icons.person,
                size: 64,
                color: AppColors.textHint,
              ),
              SizedBox(height: 16),
              Text(
                'No people found',
                style: TextStyle(
                  fontSize: 18,
                  color: AppColors.textSecondary,
                ),
              ),
              SizedBox(height: 8),
              Text(
                'Tap the + button to add the first person',
                style: TextStyle(
                  color: AppColors.textHint,
                ),
              ),
            ],
          ),
        )
            : ListView.builder(
          itemCount: _people.length,
          itemBuilder: (context, index) {
            return _buildPersonCard(_people[index]);
          },
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _showAddPersonDialog,
        backgroundColor: AppColors.primary,
        child: const Icon(Icons.add, color: Colors.white),
      ),
    );
  }
}

