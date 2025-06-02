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

class PeopleListScreen extends StatefulWidget {
  const PeopleListScreen({Key? key}) : super(key: key);

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

    final result = await _personRepository.getAllPeople();
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
                      onPressed: _loadPeople,
                      child: const Text('Retry'),
                    ),
                  ],
                ),
              );
            }

            if (_people.isEmpty) {
              return const Center(child: Text('No people found'));
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
          },
        ),
      ),
    );
  }
}
