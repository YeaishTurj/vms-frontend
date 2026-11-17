import 'package:flutter/foundation.dart';

import '../models/paginated_vehicles.dart';
import '../models/vehicle.dart';
import '../services/api_exception.dart';
import '../services/vehicle_api_service.dart';

/// Central reactive repository for Vehicle fleet management.
/// Integrates with the Spring Boot REST API, manages caching and pagination,
/// and notifies listeners on state changes.
class VehicleRepository extends ChangeNotifier {
  static final VehicleRepository _instance = VehicleRepository._internal();
  factory VehicleRepository({VehicleApiService? apiService}) {
    if (apiService != null) {
      _instance._apiService = apiService;
    }
    return _instance;
  }

  VehicleRepository._internal() : _apiService = VehicleApiService();

  VehicleApiService _apiService;

  List<Vehicle> _vehicles = [];
  bool _isLoading = false;
  String? _errorMessage;

  // Pagination state
  int _currentPage = 0; // 0-based page index matching Spring Data
  int _pageSize = 8;
  int _totalPages = 1;
  int _totalElements = 0;
  bool _isLastPage = true;
  bool _isFirstPage = true;

  // Dashboard count metrics
  int _activeCount = 0;
  int _inactiveCount = 0;
  int _maintenanceCount = 0;

  // Getters
  List<Vehicle> get vehicles => List.unmodifiable(_vehicles);
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;

  int get currentPage => _currentPage;
  int get displayPageNumber => _currentPage + 1; // 1-based for human UI
  int get pageSize => _pageSize;
  int get totalPages => _totalPages;
  int get totalElements => _totalElements;
  bool get isLastPage => _isLastPage;
  bool get isFirstPage => _isFirstPage;

  int get totalCount => _totalElements > 0 ? _totalElements : _vehicles.length;
  int get activeCount => _activeCount;
  int get inactiveCount => _inactiveCount;
  int get maintenanceCount => _maintenanceCount;

  /// Fetches a paginated page of vehicles from Spring Boot.
  Future<void> fetchVehicles({
    int? page,
    int? size,
    String? sort,
  }) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    final targetPage = page ?? _currentPage;
    final targetSize = size ?? _pageSize;

    try {
      final PaginatedVehicles paginated = await _apiService.getVehicles(
        page: targetPage,
        size: targetSize,
        sort: sort,
      );

      _vehicles = paginated.content;
      _currentPage = paginated.number;
      _pageSize = paginated.size;
      _totalPages = paginated.totalPages > 0 ? paginated.totalPages : 1;
      _totalElements = paginated.totalElements;
      _isLastPage = paginated.last;
      _isFirstPage = paginated.first;

      _updateMetricCounts(_vehicles);
      _errorMessage = null;
    } on ApiException catch (e) {
      _errorMessage = e.message;
    } catch (e) {
      _errorMessage = 'Failed to load vehicles from backend: ${e.toString()}';
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  /// Refreshes dashboard aggregate metric counters across the fleet.
  Future<void> loadDashboardMetrics() async {
    try {
      // Fetch up to 100 vehicles for initial metric aggregation
      final paginated = await _apiService.getVehicles(page: 0, size: 100);
      _updateMetricCounts(paginated.content);
      _totalElements = paginated.totalElements;
      notifyListeners();
    } catch (_) {
      // If metrics fetch fails, preserve current counts
    }
  }

  void _updateMetricCounts(List<Vehicle> list) {
    _activeCount = list.where((v) => v.status == VehicleStatus.active).length;
    _inactiveCount = list.where((v) => v.status == VehicleStatus.inactive).length;
    _maintenanceCount =
        list.where((v) => v.status == VehicleStatus.underMaintenance).length;
  }

  /// Fetches a single vehicle by ID directly from the backend.
  Future<Vehicle?> fetchVehicleById(String id) async {
    try {
      return await _apiService.getVehicleById(id);
    } catch (e) {
      return null;
    }
  }

  /// Registers a new vehicle via `POST /vehicles`.
  /// Throws [ApiException] with 409 status if duplicate, or 400 for validation errors.
  Future<Vehicle> registerVehicle(Vehicle vehicle) async {
    final created = await _apiService.createVehicle(vehicle);
    _vehicles.insert(0, created);
    _totalElements++;
    _updateMetricCounts(_vehicles);
    notifyListeners();
    return created;
  }

  /// Updates an existing vehicle via `PUT /vehicles/{id}`.
  /// Throws [ApiException] if not found (404), duplicate (409), or validation failed (400).
  Future<Vehicle> updateVehicle(Vehicle vehicle) async {
    final updated = await _apiService.updateVehicle(vehicle.id, vehicle);
    final index = _vehicles.indexWhere((v) => v.id == updated.id);
    if (index != -1) {
      _vehicles[index] = updated;
    }
    _updateMetricCounts(_vehicles);
    notifyListeners();
    return updated;
  }

  /// Deletes a vehicle via `DELETE /vehicles/{id}`.
  /// Throws [ApiException] if not found (404).
  Future<void> deleteVehicle(String id) async {
    await _apiService.deleteVehicle(id);
    _vehicles.removeWhere((v) => v.id == id);
    if (_totalElements > 0) {
      _totalElements--;
    }
    _updateMetricCounts(_vehicles);
    notifyListeners();
  }

  /// Helper for quick client-side duplicate check against loaded in-memory records.
  bool isVehicleNumberDuplicateLocally(String vehicleNumber, {String? excludeId}) {
    final normalized = vehicleNumber.trim().toLowerCase();
    return _vehicles.any((v) {
      if (excludeId != null && v.id == excludeId) {
        return false;
      }
      return v.vehicleNumber.trim().toLowerCase() == normalized;
    });
  }
}
