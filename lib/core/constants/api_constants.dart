class ApiConstants {
  static const String baseUrl = 'http://localhost:3000/api';
  static const String androidEmulatorUrl = 'http://10.0.2.2:3000/api';
  static const String iosSimulatorUrl = 'http://localhost:3000/api';

  // For production, replace with your actual server URL
  static String get apiUrl {
    // You can add platform detection here
    return androidEmulatorUrl; // Change based on your testing environment
  }

  // Auth endpoints
  static const String login = '/auth/login';
  static const String register = '/auth/register';
  static const String profile = '/auth/profile';

  // Countries endpoints
  static const String countries = '/countries';
  static String countryById(int id) => '/countries/$id';

  // Cities endpoints
  static const String cities = '/cities';
  static String cityById(int id) => '/cities/$id';

  // Places endpoints
  static const String places = '/places';
  static String placeById(int id) => '/places/$id';
  static String toggleFavorite(int id) => '/places/$id/favorite';
  static const String topVisitedPlaces = '/places/top-visited';

  // People endpoints
  static const String people = '/people';
  static String personById(int id) => '/people/$id';
  static const String peopleByCategory = '/people/by-category';

  // Dishes endpoints
  static const String dishes = '/dishes';
  static String dishById(int id) => '/dishes/$id';
  static String dishesByCountry(int countryId) => '/dishes/country/$countryId';

  // Visits endpoints
  static const String visits = '/visits';
  static String visitById(int id) => '/visits/$id';
  static const String visitStats = '/visits/stats';

  // Tags endpoints
  static const String tags = '/tags';
  static String tagById(int id) => '/tags/$id';
  static String tagsByPerson(int personId) => '/tags/person/$personId';

  // Timeouts
  static const int connectionTimeout = 30000; // 30 seconds
  static const int receiveTimeout = 30000; // 30 seconds
}