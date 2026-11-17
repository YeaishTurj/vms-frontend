/// Central API configuration for the VMS Frontend.
/// Supports configurable base URL for local development and production.
class ApiConfig {
  ApiConfig._();

  /// Raw backend REST API Base URL.
  /// Overridable at compile time using: --dart-define=API_BASE_URL=http://your-host:port
  static const String _rawBaseUrl = String.fromEnvironment(
    'API_BASE_URL',
    defaultValue: 'http://localhost:8081',
  );

  /// Backend REST API Base URL with trailing slash stripped to prevent double-slash routing issues.
  static String get baseUrl => _rawBaseUrl.endsWith('/')
      ? _rawBaseUrl.substring(0, _rawBaseUrl.length - 1)
      : _rawBaseUrl;

  /// Default timeout for HTTP requests.
  static const Duration timeout = Duration(seconds: 15);

  /// Whether the current configured API base URL enforces HTTPS.
  static bool get isHttps => baseUrl.toLowerCase().startsWith('https://');

  /// Whether the target base URL points to a local development loopback host.
  static bool get isLocalhost {
    try {
      final uri = Uri.parse(baseUrl);
      return uri.host == 'localhost' ||
          uri.host == '127.0.0.1' ||
          uri.host == '0.0.0.0';
    } catch (_) {
      return false;
    }
  }

  /// Whether the configuration is secure for the current environment.
  /// Development on loopback may use HTTP; production non-loopback environments require HTTPS.
  static bool get isSecureForEnvironment => isLocalhost || isHttps;

  /// Vehicles resource base path.
  static const String vehiclesPath = '/vehicles';

  /// Authentication base endpoints matching Spring Boot AuthController contract.
  static const String loginPath = '/auth/login';
  static const String mePath = '/auth/me';

  /// Builds the URI for user login authentication.
  static Uri loginUri() => Uri.parse('$baseUrl$loginPath');

  /// Builds the URI for fetching current authenticated user profile.
  static Uri meUri() => Uri.parse('$baseUrl$mePath');

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
