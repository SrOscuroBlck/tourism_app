// lib/injection_container.dart

import 'package:get_it/get_it.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:tourismapp/data/datasources/local/route_local_datasource.dart';
import 'package:tourismapp/presentation/blocs/route_planner/route_planner_bloc.dart';

import 'core/network/api_client.dart';
import 'core/network/network_info.dart';

import 'data/datasources/remote/auth_remote_datasource.dart';
import 'data/datasources/remote/city_remote_datasource.dart';
import 'data/datasources/remote/country_remote_datasource.dart';
import 'data/datasources/remote/dish_remote_datasource.dart';
import 'data/datasources/remote/person_remote_datasource.dart';
import 'data/datasources/remote/place_remote_datasource.dart';
import 'data/datasources/remote/tag_remote_datasource.dart';
import 'data/datasources/remote/visit_remote_datasource.dart';

import 'data/datasources/local/auth_local_datasource.dart';
import 'data/datasources/local/favorites_local_datasource.dart';

import 'data/repositories/auth_repository_impl.dart';
import 'data/repositories/city_repository_impl.dart';
import 'data/repositories/country_repository_impl.dart';
import 'data/repositories/dish_repository_impl.dart';
import 'data/repositories/person_repository_impl.dart';
import 'data/repositories/place_repository_impl.dart';
import 'data/repositories/route_repository_impl.dart';
import 'data/repositories/tag_repository_impl.dart';
import 'data/repositories/visit_repository_impl.dart';

import 'domain/repositories/auth_repository.dart';
import 'domain/repositories/city_repository.dart';
import 'domain/repositories/country_repository.dart';
import 'domain/repositories/dish_repository.dart';
import 'domain/repositories/person_repository.dart';
import 'domain/repositories/place_repository.dart';
import 'domain/repositories/route_repository.dart';
import 'domain/repositories/tag_repository.dart';
import 'domain/repositories/visit_repository.dart';

import 'domain/usecases/auth/login_usecase.dart';
import 'domain/usecases/auth/register_usecase.dart';
import 'domain/usecases/auth/logout_usecase.dart';

import 'domain/usecases/places/get_places_uscase.dart';
import 'domain/usecases/places/get_place_detail_uscase.dart';
import 'domain/usecases/places/toggle_favorite_uscase.dart';

import 'domain/usecases/routes/delete_route_usecase.dart';
import 'domain/usecases/routes/get_routes_usecase.dart';
import 'domain/usecases/routes/save_route_usecase.dart';
import 'domain/usecases/visits/create_visit_uscase.dart';
import 'domain/usecases/visits/get_user_visits_uscase.dart';

import 'presentation/blocs/auth/auth_bloc.dart';
import 'presentation/blocs/home/home_bloc.dart';
import 'presentation/blocs/places/places_bloc.dart';
import 'presentation/blocs/place_detail/place_detail_bloc.dart';
import 'presentation/blocs/favorites/favorites_bloc.dart';

final sl = GetIt.instance;

Future<void> init() async {
  // --------------------------------------------
  // External dependencies
  // --------------------------------------------
  sl.registerLazySingleton<FlutterSecureStorage>(
        () => const FlutterSecureStorage(),
  );

  final sharedPreferences = await SharedPreferences.getInstance();
  sl.registerLazySingleton<SharedPreferences>(() => sharedPreferences);

  sl.registerLazySingleton<ApiClient>(() => ApiClient(sl()));
  sl.registerLazySingleton<NetworkInfo>(() => NetworkInfoImpl());

  // --------------------------------------------
  // Data sources - Remote
  // --------------------------------------------
  sl.registerLazySingleton<AuthRemoteDataSource>(
        () => AuthRemoteDataSourceImpl(apiClient: sl()),
  );
  sl.registerLazySingleton<CityRemoteDataSource>(
        () => CityRemoteDataSourceImpl(apiClient: sl()),
  );
  sl.registerLazySingleton<CountryRemoteDataSource>(
        () => CountryRemoteDataSourceImpl(apiClient: sl()),
  );
  sl.registerLazySingleton<DishRemoteDataSource>(
        () => DishRemoteDataSourceImpl(apiClient: sl()),
  );
  sl.registerLazySingleton<PersonRemoteDataSource>(
        () => PersonRemoteDataSourceImpl(apiClient: sl()),
  );
  sl.registerLazySingleton<PlaceRemoteDataSource>(
        () => PlaceRemoteDataSourceImpl(apiClient: sl()),
  );
  sl.registerLazySingleton<TagRemoteDataSource>(
        () => TagRemoteDataSourceImpl(apiClient: sl()),
  );
  sl.registerLazySingleton<VisitRemoteDataSource>(
        () => VisitRemoteDataSourceImpl(apiClient: sl()),
  );

  // --------------------------------------------
  // Data sources - Local
  // --------------------------------------------
  sl.registerLazySingleton<AuthLocalDataSource>(
        () => AuthLocalDataSourceImpl(secureStorage: sl()),
  );
  sl.registerLazySingleton<FavoritesLocalDataSource>(
        () => FavoritesLocalDataSourceImpl(sharedPreferences: sl()),
  );
  sl.registerLazySingleton<RouteLocalDataSource>(
        () => RouteLocalDataSourceImpl(prefs: sl()),
  );

  // --------------------------------------------
  // Repositories
  // --------------------------------------------
  sl.registerLazySingleton<AuthRepository>(
        () => AuthRepositoryImpl(
      remoteDataSource: sl(),
      localDataSource: sl(),
    ),
  );
  sl.registerLazySingleton<CityRepository>(
        () => CityRepositoryImpl(remoteDataSource: sl()),
  );
  sl.registerLazySingleton<CountryRepository>(
        () => CountryRepositoryImpl(remoteDataSource: sl()),
  );
  sl.registerLazySingleton<DishRepository>(
        () => DishRepositoryImpl(remoteDataSource: sl()),
  );
  sl.registerLazySingleton<PersonRepository>(
        () => PersonRepositoryImpl(remoteDataSource: sl()),
  );
  // *** Note: PlaceRepositoryImpl’s constructor only takes a remoteDataSource
  sl.registerLazySingleton<PlaceRepository>(
        () => PlaceRepositoryImpl(remoteDataSource: sl()),
  );
  sl.registerLazySingleton<TagRepository>(
        () => TagRepositoryImpl(remoteDataSource: sl()),
  );
  sl.registerLazySingleton<VisitRepository>(
        () => VisitRepositoryImpl(remoteDataSource: sl()),
  );
  sl.registerLazySingleton<RouteRepository>(
        () => RouteRepositoryImpl(localDataSource: sl()),
  );

  // --------------------------------------------
  // Use Cases
  // --------------------------------------------
  sl.registerLazySingleton<LoginUseCase>(
        () => LoginUseCase(sl()),
  );
  sl.registerLazySingleton<RegisterUseCase>(
        () => RegisterUseCase(sl()),
  );
  sl.registerLazySingleton<LogoutUseCase>(
        () => LogoutUseCase(sl()),
  );

  sl.registerLazySingleton<GetPlacesUseCase>(
        () => GetPlacesUseCase(sl()),
  );
  sl.registerLazySingleton<GetPlaceDetailUseCase>(
        () => GetPlaceDetailUseCase(sl()),
  );
  // *** ToggleFavoriteUseCase constructor only needs one repository
  sl.registerLazySingleton<ToggleFavoriteUseCase>(
        () => ToggleFavoriteUseCase(sl()),
  );

  sl.registerLazySingleton<CreateVisitUseCase>(
        () => CreateVisitUseCase(sl()),
  );
  sl.registerLazySingleton<GetUserVisitsUseCase>(
        () => GetUserVisitsUseCase(sl()),
  );
  sl.registerLazySingleton<GetRoutesUseCase>(
        () => GetRoutesUseCase(sl()),
  );
  sl.registerLazySingleton<SaveRouteUseCase>(
        () => SaveRouteUseCase(sl()),
  );
  sl.registerLazySingleton<DeleteRouteUseCase>(
        () => DeleteRouteUseCase(sl()),
  );

  // --------------------------------------------
  // Blocs
  // --------------------------------------------
  sl.registerFactory<AuthBloc>(
        () => AuthBloc(
      loginUseCase: sl(),
      registerUseCase: sl(),
      logoutUseCase: sl(),
      secureStorage: sl(),
    ),
  );

  // *** HomeBloc's constructor only has one named parameter: getPlacesUseCase
  sl.registerFactory<HomeBloc>(
        () => HomeBloc(
      getPlacesUseCase: sl(),
    ),
  );

  // *** PlacesBloc’s constructor only takes getPlacesUseCase
  sl.registerFactory<PlacesBloc>(
        () => PlacesBloc(
      getPlacesUseCase: sl(),
    ),
  );

  sl.registerFactory<PlaceDetailBloc>(
        () => PlaceDetailBloc(
      getDetailUseCase: sl(),
      toggleFavoriteUseCase: sl(),
    ),
  );

  // *** FavoritesBloc’s constructor wants: localDataSource & getDetailUseCase
  sl.registerFactory<FavoritesBloc>(
        () => FavoritesBloc(
      localDataSource: sl(),
      getDetailUseCase: sl(),
    ),
  );

  sl.registerFactory<RoutePlannerBloc>(
        () => RoutePlannerBloc(
      getRoutesUseCase: sl<GetRoutesUseCase>(),
      saveRouteUseCase: sl<SaveRouteUseCase>(),
      deleteRouteUseCase: sl<DeleteRouteUseCase>(),
    ),
  );
}
