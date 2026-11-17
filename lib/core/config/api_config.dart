/// Central API configuration for the VMS Frontend.
/// Supports configurable base URL for local development and production.
class ApiConfig {
  ApiConfig._();

  /// Backend REST API Base URL.
  /// Overridable at compile time using: --dart-define=API_BASE_URL=http://your-host:port
  static const String baseUrl = String.fromEnvironment(
    'API_BASE_URL',
    defaultValue: 'http://localhost:8081',
  );

  /// Default timeout for HTTP requests.
  static const Duration timeout = Duration(seconds: 15);

  /// Vehicles resource base path.
  static const String vehiclesPath = '/vehicles';

  /// Builds a URI for paginated vehicle queries.
  static Uri vehiclesUri({int page = 0, int size = 10, String? sort}) {
    final queryParams = <String, String>{
      'page': page.toString(),
      'size': size.toString(),
    };
    if (sort != null && sort.isNotEmpty) {
      queryParams['sort'] = sort;
    }
    return Uri.parse('$baseUrl$vehiclesPath').replace(
      queryParameters: queryParams,
    );
  }

  /// Builds a URI for single vehicle operations by ID.
  static Uri vehicleByIdUri(dynamic id) {
    return Uri.parse('$baseUrl$vehiclesPath/$id');
  }
}
