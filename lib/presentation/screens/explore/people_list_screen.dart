// lib/presentation/screens/explore/people_list_screen.dart

import 'package:flutter/material.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../../domain/entities/person.dart';
import '../../../../domain/repositories/person_repository.dart';
import '../../../../injection_container.dart';
import '../../widgets/cards/person_card.dart';
import '../../widgets/common/custom_app_bar.dart';
import '../../widgets/common/error_widget.dart' as AppError;
import '../../widgets/common/loading_widget.dart';
import 'detail/person_detail_screen.dart';

/// If your backend allows filtering, you can pass any of these:
///   PeopleListScreen(countryId: 5)
///   PeopleListScreen(cityId: 12, category: 'Actor')
class PeopleListScreen extends StatefulWidget {
  final int? countryId;
  final int? cityId;
  final String? category;
  final String? search;

  const PeopleListScreen({
    Key? key,
    this.countryId,
    this.cityId,
    this.category,
    this.search,
  }) : super(key: key);

  @override
  _PeopleListScreenState createState() => _PeopleListScreenState();
}

class _PeopleListScreenState extends State<PeopleListScreen> {
  final PersonRepository _personRepository = sl<PersonRepository>();

  bool _isLoading = true;
  String? _errorMessage;
  List<Person> _people = [];

  @override
  void initState() {
    super.initState();
    _loadPeople();
  }

  Future<void> _loadPeople() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    final result = await _personRepository.getAllPeople(
      countryId: widget.countryId,
      cityId: widget.cityId,
      category: widget.category,
      search: widget.search,
    );

    result.fold(
          (failure) {
        setState(() {
          _errorMessage = failure.message ?? 'Failed to load people';
          _isLoading = false;
        });
      },
          (people) {
        setState(() {
          _people = people;
          _isLoading = false;
        });
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: const CustomAppBar(
        title: 'All People',
        automaticallyImplyLeading: true,
      ),
      backgroundColor: AppColors.background,
      body: RefreshIndicator(
        onRefresh: _loadPeople,
        child: Builder(
          builder: (_) {
            // 1) Loading State
            if (_isLoading) {
              return const Center(child: LoadingWidget(size: 48));
            }

            // 2) Error State
            if (_errorMessage != null) {
              // Wrap in a scrollable so pull-to-refresh still works
              return SingleChildScrollView(
                physics: const AlwaysScrollableScrollPhysics(),
                child: ConstrainedBox(
                  constraints: BoxConstraints(
                    minHeight: MediaQuery.of(context).size.height - kToolbarHeight,
                  ),
                  child: Center(
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        AppError.ErrorWidget(message: _errorMessage!),
                        const SizedBox(height: 16),
                        ElevatedButton(
                          onPressed: _loadPeople,
                          child: const Text('Retry'),
                        ),
                      ],
                    ),
                  ),
                ),
              );
            }

            // 3) Empty State
            if (_people.isEmpty) {
              // Again wrap so pull-to-refresh is possible
              return SingleChildScrollView(
                physics: const AlwaysScrollableScrollPhysics(),
                child: ConstrainedBox(
                  constraints: BoxConstraints(
                    minHeight: MediaQuery.of(context).size.height - kToolbarHeight,
                  ),
                  child: const Center(
                    child: Text('No people found'),
                  ),
                ),
              );
            }

            // 4) Success State: Show the list of PersonCard
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
          },
        ),
      ),
    );
  }
}
