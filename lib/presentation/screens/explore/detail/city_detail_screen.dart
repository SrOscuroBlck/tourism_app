// lib/presentation/screens/explore/city_detail_screen.dart

import 'package:flutter/material.dart';
import 'package:tourismapp/presentation/screens/explore/detail/person_detail_screen.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../../domain/entities/city.dart';
import '../../../../domain/entities/place.dart';
import '../../../../domain/entities/person.dart';
import '../../../../domain/repositories/place_repository.dart';
import '../../../../domain/repositories/person_repository.dart';
import '../../../../injection_container.dart';
import '../../../widgets/cards/place_card.dart';
import '../../../widgets/cards/person_card.dart';
import '../../../widgets/common/custom_app_bar.dart';
import '../../../widgets/common/loading_widget.dart';
import '../../../widgets/common/error_widget.dart' as AppError;

class CityDetailScreen extends StatefulWidget {
  final City city;

  const CityDetailScreen({
    Key? key,
    required this.city,
  }) : super(key: key);

  @override
  State<CityDetailScreen> createState() => _CityDetailScreenState();
}

class _CityDetailScreenState extends State<CityDetailScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  final PlaceRepository _placeRepository = sl<PlaceRepository>();
  final PersonRepository _personRepository = sl<PersonRepository>();

  List<Place> _places = [];
  List<Person> _people = [];

  bool _isLoadingPlaces = true;
  bool _isLoadingPeople = true;

  String? _placesError;
  String? _peopleError;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    _loadAllData();
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  Future<void> _loadAllData() async {
    await Future.wait([
      _loadPlaces(),
      _loadPeople(),
    ]);
  }

  Future<void> _loadPlaces() async {
    final result = await _placeRepository.getAllPlaces(cityId: widget.city.id);
    result.fold(
          (failure) {
        setState(() {
          _placesError = failure.message ?? 'Failed to load places';
          _isLoadingPlaces = false;
        });
      },
          (places) {
        setState(() {
          _places = places;
          _isLoadingPlaces = false;
        });
      },
    );
  }

  Future<void> _loadPeople() async {
    final result = await _personRepository.getAllPeople(cityId: widget.city.id);
    result.fold(
          (failure) {
        setState(() {
          _peopleError = failure.message ?? 'Failed to load people';
          _isLoadingPeople = false;
        });
      },
          (people) {
        setState(() {
          _people = people;
          _isLoadingPeople = false;
        });
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: CustomAppBar(
        title: widget.city.name,
        automaticallyImplyLeading: true,
        bottom: TabBar(
          controller: _tabController,
          tabs: const [
            Tab(text: 'Places'),
            Tab(text: 'Famous People'),
          ],
          labelColor: AppColors.primary,
          unselectedLabelColor: AppColors.textSecondary,
          indicatorColor: AppColors.primary,
        ),
      ),
      backgroundColor: AppColors.background,
      body: Column(
        children: [
          // City info header
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(16),
            color: AppColors.surface,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  widget.city.name,
                  style: AppTextStyles.headlineMedium,
                ),
                const SizedBox(height: 8),
                if (widget.city.country != null) ...[
                  Row(
                    children: [
                      const Icon(Icons.public, size: 16, color: AppColors.textSecondary),
                      const SizedBox(width: 4),
                      Text(
                        'Country: ${widget.city.country!.name}',
                        style: AppTextStyles.bodyMedium,
                      ),
                    ],
                  ),
                  const SizedBox(height: 4),
                ],
                if (widget.city.population != null) ...[
                  Row(
                    children: [
                      const Icon(Icons.people, size: 16, color: AppColors.textSecondary),
                      const SizedBox(width: 4),
                      Text(
                        'Population: ${widget.city.population}',
                        style: AppTextStyles.bodyMedium,
                      ),
                    ],
                  ),
                  const SizedBox(height: 4),
                ],
                if (widget.city.latitude != null && widget.city.longitude != null) ...[
                  Row(
                    children: [
                      const Icon(Icons.location_on, size: 16, color: AppColors.textSecondary),
                      const SizedBox(width: 4),
                      Text(
                        'Location: ${widget.city.latitude!.toStringAsFixed(3)}, ${widget.city.longitude!.toStringAsFixed(3)}',
                        style: AppTextStyles.bodyMedium,
                      ),
                    ],
                  ),
                ],
              ],
            ),
          ),

          // Tab content
          Expanded(
            child: TabBarView(
              controller: _tabController,
              children: [
                _buildPlacesTab(),
                _buildPeopleTab(),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPlacesTab() {
    if (_isLoadingPlaces) {
      return const Center(child: LoadingWidget(size: 48));
    }

    if (_placesError != null) {
      return Center(child: AppError.ErrorWidget(message: _placesError!));
    }

    if (_places.isEmpty) {
      return const Center(child: Text('No places found in this city'));
    }

    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: _places.length,
      itemBuilder: (context, index) {
        final place = _places[index];
        return Padding(
          padding: const EdgeInsets.only(bottom: 12),
          child: PlaceCard(
            place: place,
            onTap: () {
              // Navigate to place detail
              Navigator.pushNamed(
                context,
                '/place_detail',
                arguments: place.id,
              );
            },
          ),
        );
      },
    );
  }

  Widget _buildPeopleTab() {
    if (_isLoadingPeople) {
      return const Center(child: LoadingWidget(size: 48));
    }

    if (_peopleError != null) {
      return Center(child: AppError.ErrorWidget(message: _peopleError!));
    }

    if (_people.isEmpty) {
      return const Center(child: Text('No famous people found from this city'));
    }

    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: _people.length,
      itemBuilder: (context, index) {
        final person = _people[index];
        return Padding(
          padding: const EdgeInsets.only(bottom: 12),
          child: PersonCard(
            id: person.id,
            name: person.name,
            category: person.category,
            imageUrl: person.imageUrl,
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (ctx) => PersonDetailScreen(person: person),
                ),
              );
            },
          ),
        );
      },
    );
  }
}