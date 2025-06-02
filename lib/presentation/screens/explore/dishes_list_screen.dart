// lib/presentation/screens/explore/dishes_list_screen.dart

import 'package:flutter/material.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../../domain/entities/dish.dart';
import '../../../../domain/repositories/dish_repository.dart';
import '../../../../injection_container.dart';
import '../../widgets/cards/dish_card.dart';
import '../../widgets/common/custom_app_bar.dart';
import '../../widgets/common/error_widget.dart' as AppError;
import '../../widgets/common/loading_widget.dart';
import 'detail/dish_detail_screen.dart';

class DishesListScreen extends StatefulWidget {
  const DishesListScreen({Key? key}) : super(key: key);

  @override
  State<DishesListScreen> createState() => _DishesListScreenState();
}

class _DishesListScreenState extends State<DishesListScreen> {
  final DishRepository _dishRepository = sl<DishRepository>();

  bool _isLoading = true;
  String? _errorMessage;
  List<Dish> _dishes = [];

  @override
  void initState() {
    super.initState();
    _loadDishes();
  }

  Future<void> _loadDishes() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    final result = await _dishRepository.getAllDishes();
    result.fold(
          (failure) {
        setState(() {
          _isLoading = false;
          _errorMessage = failure.message ?? 'Failed to load dishes';
        });
      },
          (dishes) {
        setState(() {
          _dishes = dishes;
          _isLoading = false;
        });
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: const CustomAppBar(
        title: 'All Dishes',
        automaticallyImplyLeading: true,
      ),
      backgroundColor: AppColors.background,
      body: RefreshIndicator(
        onRefresh: _loadDishes,
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
                      onPressed: _loadDishes,
                      child: const Text('Retry'),
                    ),
                  ],
                ),
              );
            }
            if (_dishes.isEmpty) {
              return const Center(child: Text('No dishes found'));
            }
            return ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: _dishes.length,
              itemBuilder: (context, index) {
                final dish = _dishes[index];
                return Padding(
                  padding: const EdgeInsets.only(bottom: 12),
                  child: DishCard(
                    id: dish.id,
                    name: dish.name,
                    price: dish.price,
                    imageUrl: dish.imageUrl,
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => DishDetailScreen(dish: dish),
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
