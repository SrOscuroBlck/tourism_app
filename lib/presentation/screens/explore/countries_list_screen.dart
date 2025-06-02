// lib/presentation/screens/explore/countries_list_screen.dart

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_text_styles.dart';
import '../../../domain/entities/country.dart';
import '../../../domain/repositories/country_repository.dart';
import '../../../injection_container.dart';
import '../../widgets/cards/country_card.dart';
import '../../widgets/common/custom_app_bar.dart';
import '../../widgets/common/loading_widget.dart';
import '../../widgets/common/error_widget.dart' as AppError;
import 'detail/country_detail_screen.dart';

class CountriesListScreen extends StatefulWidget {
  const CountriesListScreen({Key? key}) : super(key: key);

  @override
  State<CountriesListScreen> createState() => _CountriesListScreenState();
}

class _CountriesListScreenState extends State<CountriesListScreen> {
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
          _isLoading = false;
          _errorMessage = failure.message ?? 'Failed to load countries';
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: const CustomAppBar(
        title: 'Countries',
        automaticallyImplyLeading: true,
      ),
      backgroundColor: AppColors.background,
      body: RefreshIndicator(
        onRefresh: _loadCountries,
        child: _buildBody(),
      ),
    );
  }

  Widget _buildBody() {
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
              onPressed: _loadCountries,
              child: const Text('Retry'),
            ),
          ],
        ),
      );
    }

    if (_countries.isEmpty) {
      return const Center(
        child: Text('No countries found'),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: _countries.length,
      itemBuilder: (context, index) {
        final country = _countries[index];
        return Padding(
          padding: const EdgeInsets.only(bottom: 12),
          child: CountryCard(
            countryId: country.id,
            name: country.name,
            continent: country.continent,
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => CountryDetailScreen(country: country),
                ),
              );
            },
          ),
        );
      },
    );
  }
}