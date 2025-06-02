import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:tourismapp/presentation/blocs/auth/auth_event.dart';
import 'package:tourismapp/presentation/blocs/auth/auth_state.dart';
import 'package:tourismapp/presentation/screens/explore/cities_list_screen.dart';
import 'package:tourismapp/presentation/screens/explore/dishes_list_screen.dart';
import 'package:tourismapp/presentation/screens/explore/people_list_screen.dart';

import 'core/theme/app_theme.dart';
import 'injection_container.dart';
import 'presentation/blocs/auth/auth_bloc.dart';
import 'presentation/screens/auth/login_screen.dart';
import 'presentation/screens/main/main_screen.dart';
import 'presentation/screens/explore/countries_list_screen.dart';

class TourismApp extends StatelessWidget {
  const TourismApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider(
          create: (_) => sl<AuthBloc>()..add(CheckAuthStatus()),
        ),
      ],
      child: MaterialApp(
        title: 'Tourism App',
        theme: AppTheme.lightTheme,
        debugShowCheckedModeBanner: false,
        // Define your routes here
        routes: {
          '/': (context) => _buildAuthWrapper(),
          '/countries_list': (context) => const CountriesListScreen(),
          '/cities_list': (context) => const CitiesListScreen(),
          '/people_list': (context) => const PeopleListScreen(),
          '/dishes_list': (context) => const DishesListScreen(),
        },
        initialRoute: '/',
      ),
    );
  }

  Widget _buildAuthWrapper() {
    return BlocBuilder<AuthBloc, AuthState>(
      builder: (context, state) {
        if (state is AuthLoading) {
          return const Scaffold(
            body: Center(
              child: CircularProgressIndicator(),
            ),
          );
        } else if (state is Authenticated) {
          return const MainScreen();
        } else {
          return const LoginScreen();
        }
      },
    );
  }
}