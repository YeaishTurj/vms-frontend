import '../../core/config/api_config.dart';
import '../models/paginated_vehicles.dart';
import '../models/vehicle.dart';
import 'api_client.dart';

/// REST API Service dedicated to Vehicle CRUD operations against Spring Boot.
class VehicleApiService {
  final ApiClient _client;

  VehicleApiService({ApiClient? client}) : _client = client ?? ApiClient();

  /// Fetches a paginated slice of vehicles from `GET /vehicles?page=...&size=...`
  Future<PaginatedVehicles> getVehicles({
    int page = 0,
    int size = 10,
    String? sort,
  }) async {
    final uri = ApiConfig.vehiclesUri(page: page, size: size, sort: sort);
    final json = await _client.get(uri);
    if (json is Map<String, dynamic>) {
      return PaginatedVehicles.fromJson(json);
    }
    return PaginatedVehicles.empty();
  }

  /// Fetches a single vehicle record by ID from `GET /vehicles/{id}`
  Future<Vehicle> getVehicleById(String id) async {
    final uri = ApiConfig.vehicleByIdUri(id);
    final json = await _client.get(uri);
    return Vehicle.fromJson(json as Map<String, dynamic>);
  }

  /// Creates a new vehicle record via `POST /vehicles`
  Future<Vehicle> createVehicle(Vehicle vehicle) async {
    final uri = ApiConfig.vehiclesUri();
    final json = await _client.post(uri, body: vehicle.toJson());
    return Vehicle.fromJson(json as Map<String, dynamic>);
  }

  /// Updates an existing vehicle record via `PUT /vehicles/{id}`
  Future<Vehicle> updateVehicle(String id, Vehicle vehicle) async {
    final uri = ApiConfig.vehicleByIdUri(id);
    final json = await _client.put(uri, body: vehicle.toJson());
    return Vehicle.fromJson(json as Map<String, dynamic>);
  }

  /// Deletes a vehicle record by ID via `DELETE /vehicles/{id}`
  Future<void> deleteVehicle(String id) async {
    final uri = ApiConfig.vehicleByIdUri(id);
    await _client.delete(uri);
  }
}
