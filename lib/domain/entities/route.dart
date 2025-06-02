// lib/domain/entities/route.dart

/// Represents a named route, consisting of a name and a list of place IDs.
class RoutePlan {
  final String name;
  final List<int> placeIds;

  RoutePlan({
    required this.name,
    required this.placeIds,
  });

  /// Convert to JSON‐serializable map
  Map<String, dynamic> toJson() => {
    'name': name,
    'placeIds': placeIds,
  };

  /// Create from JSON‐deserialized map
  factory RoutePlan.fromJson(Map<String, dynamic> json) {
    final rawList = json['placeIds'] as List<dynamic>? ?? [];
    return RoutePlan(
      name: json['name'] as String? ?? '',
      placeIds: rawList.map((e) => (e as num).toInt()).toList(),
    );
  }
}
