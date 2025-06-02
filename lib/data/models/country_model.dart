import '../../domain/entities/country.dart';

class CountryModel extends Country {
  const CountryModel({
    required super.id,
    required super.name,
    super.population,
    required super.continent,
    super.cities,
    super.people,
    super.places,
    super.dishes,
  });

  factory CountryModel.fromJson(Map<String, dynamic> json) {
    // Helper to parse an int (in case JSON is string‐encoded)
    int parseInt(dynamic value) {
      if (value == null) return 0;
      if (value is int) return value;
      if (value is String) return int.tryParse(value) ?? 0;
      return 0;
    }

    return CountryModel(
      id: parseInt(json['id']),
      name: json['name']?.toString() ?? '',
      // If your /api/country endpoint includes a numeric 'population', parse it; otherwise default to null
      population: json['population'] != null
          ? (int.tryParse(json['population'].toString()) ?? null)
          : null,
      // The nested JSON under /api/places only has { id, name }—no 'continent' key—so default to empty:
      continent: json['continent']?.toString() ?? '',
      // Omit all nested lists (cities, people, places, dishes) here; re‐enable if your endpoint sends them
      cities: null,
      people: null,
      places: null,
      dishes: null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      if (population != null) 'population': population,
      'continent': continent,
      // Omit nested lists for simplicity
    };
  }
}
