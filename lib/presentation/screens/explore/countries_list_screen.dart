// lib/presentation/screens/explore/countries_list_screen.dart

import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';
import '../../widgets/cards/country_card.dart';
import '../../../domain/entities/country.dart';
import '../../../domain/repositories/country_repository.dart';
import '../../widgets/common/custom_app_bar.dart';

class CountriesListScreen extends StatelessWidget {
  const CountriesListScreen({Key? key}) : super(key: key);

  Future<List<Country>> _fetchAllCountries() async {
    final countryRepo = GetIt.I<CountryRepository>();
    final either = await countryRepo.getAllCountries();
    return either.fold(
          (failure) => throw Exception(failure.message),
          (countries) => countries,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: const CustomAppBar(title: 'Countries'),
      body: FutureBuilder<List<Country>>(
        future: _fetchAllCountries(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          } else if (snapshot.hasData) {
            final countries = snapshot.data!;
            if (countries.isEmpty) {
              return const Center(child: Text('No countries found.'));
            }
            return Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              child: ListView.separated(
                itemCount: countries.length,
                separatorBuilder: (_, __) => const SizedBox(height: 12),
                itemBuilder: (context, index) {
                  final country = countries[index];
                  return CountryCard(
                    countryId: country.id,
                    name: country.name,
                    continent: country.continent,
                    onTap: () {
                      Navigator.pushNamed(
                        context,
                        '/country_detail',
                        arguments: country.id,
                      );
                    },
                  );
                },
              ),
            );
          } else {
            return const Center(child: Text('No data.'));
          }
        },
      ),
    );
  }
}
