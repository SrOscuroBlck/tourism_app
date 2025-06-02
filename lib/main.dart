// lib/main.dart

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

// 1) dotenv to load .env
import 'package:flutter_dotenv/flutter_dotenv.dart';

// 2) Supabase Flutter
import 'package:supabase_flutter/supabase_flutter.dart';

import 'app.dart';
import 'core/utils/bloc_observer.dart';
import 'injection_container.dart' as di;

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Lock portrait orientations
  await SystemChrome.setPreferredOrientations(
    [DeviceOrientation.portraitUp, DeviceOrientation.portraitDown],
  );

  // 3) Load your .env file
  //    Make sure assets/.env is listed under `flutter -> assets:` in pubspec.yaml
  await dotenv.load(fileName: "assets/.env");

  // 4) Read the Supabase keys from the loaded environment
  final supabaseUrl = dotenv.env['EXPO_PUBLIC_SUPABASE_URL'];
  final supabaseAnonKey = dotenv.env['EXPO_PUBLIC_SUPABASE_ANON_KEY'];

  if (supabaseUrl == null || supabaseAnonKey == null) {
    throw Exception(
        "Supabase URL or Anon Key not found in .env. "
            "Please check that EXPO_PUBLIC_SUPABASE_URL and EXPO_PUBLIC_SUPABASE_ANON_KEY are defined."
    );
  }

  // 5) Initialize Supabase
  await Supabase.initialize(
    url: supabaseUrl,
    anonKey: supabaseAnonKey,
    // optional: pass auth persistence preferences, etc.
    // If you need to enable debugging:
    // debug: true,
  );

  // 6) Initialize dependency injection (your existing code)
  await di.init();

  // 7) Set up your BLoC observer
  Bloc.observer = AppBlocObserver();

  // 8) Finally, run the app
  runApp(const TourismApp());
}
