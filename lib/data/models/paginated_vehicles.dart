import 'vehicle.dart';

/// Represents a paginated slice of vehicles returned by Spring Data Pageable endpoints.
class PaginatedVehicles {
  final List<Vehicle> content;
  final int number;
  final int size;
  final int totalElements;
  final int totalPages;
  final bool last;
  final bool first;
  final bool empty;

  const PaginatedVehicles({
    required this.content,
    required this.number,
    required this.size,
    required this.totalElements,
    required this.totalPages,
    required this.last,
    required this.first,
    required this.empty,
  });

  /// Empty page fallback instance
  factory PaginatedVehicles.empty() {
    return const PaginatedVehicles(
      content: [],
      number: 0,
      size: 10,
      totalElements: 0,
      totalPages: 0,
      last: true,
      first: true,
      empty: true,
    );
  }

  /// Deserializes a Spring Page JSON payload.
  factory PaginatedVehicles.fromJson(Map<String, dynamic> json) {
    final rawContent = json['content'] as List<dynamic>? ?? [];
    final items = rawContent
        .whereType<Map<String, dynamic>>()
        .map(Vehicle.fromJson)
        .toList();

    return PaginatedVehicles(
      content: items,
      number: (json['number'] as num?)?.toInt() ?? 0,
      size: (json['size'] as num?)?.toInt() ?? 10,
      totalElements: (json['totalElements'] as num?)?.toInt() ?? items.length,
      totalPages: (json['totalPages'] as num?)?.toInt() ?? (items.isEmpty ? 0 : 1),
      last: json['last'] as bool? ?? true,
      first: json['first'] as bool? ?? true,
      empty: json['empty'] as bool? ?? items.isEmpty,
    );
  }
}
