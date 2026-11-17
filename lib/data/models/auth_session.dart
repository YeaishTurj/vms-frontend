/// Model representing an active user authentication session issued by Spring Boot.
/// Encapsulates JWT bearer token and user metadata without ever holding passwords.
class AuthSession {
  final String token;
  final String type;
  final DateTime expiresAt;
  final String username;
  final List<String> roles;

  const AuthSession({
    required this.token,
    this.type = 'Bearer',
    required this.expiresAt,
    required this.username,
    required this.roles,
  });

  /// Factory constructor to deserialize session from backend login response.
  /// Backend response contract:
  /// {
  ///   "token": "eyJ...",
  ///   "type": "Bearer",
  ///   "expiresIn": 86400,
  ///   "username": "admin",
  ///   "roles": ["ROLE_ADMIN"]
  /// }
  factory AuthSession.fromBackendResponse(Map<String, dynamic> json) {
    final token = json['token'] as String? ?? '';
    final type = json['type'] as String? ?? 'Bearer';
    final expiresInSeconds = (json['expiresIn'] as num?)?.toInt() ?? 86400;
    final expiresAt = DateTime.now().add(Duration(seconds: expiresInSeconds));
    final username = json['username'] as String? ?? '';

    List<String> roles = [];
    if (json['roles'] is List) {
      roles = (json['roles'] as List).map((r) => r.toString()).toList();
    }

    return AuthSession(
      token: token,
      type: type,
      expiresAt: expiresAt,
      username: username,
      roles: roles,
    );
  }

  /// Deserializes a stored session (e.g. from sessionStorage).
  factory AuthSession.fromJson(Map<String, dynamic> json) {
    final token = json['token'] as String? ?? '';
    final type = json['type'] as String? ?? 'Bearer';
    final expiresAtStr = json['expiresAt'] as String?;
    final expiresAt = expiresAtStr != null
        ? DateTime.tryParse(expiresAtStr) ?? DateTime.now()
        : DateTime.now();
    final username = json['username'] as String? ?? '';

    List<String> roles = [];
    if (json['roles'] is List) {
      roles = (json['roles'] as List).map((r) => r.toString()).toList();
    }

    return AuthSession(
      token: token,
      type: type,
      expiresAt: expiresAt,
      username: username,
      roles: roles,
    );
  }

  /// Serializes session metadata for secure tab-isolated storage.
  Map<String, dynamic> toJson() {
    return {
      'token': token,
      'type': type,
      'expiresAt': expiresAt.toIso8601String(),
      'username': username,
      'roles': roles,
    };
  }

  /// Checks whether the token has passed its expiration timestamp.
  bool get isExpired => DateTime.now().isAfter(expiresAt);

  /// Checks whether the session is currently valid for API authorization.
  bool get isValid => token.trim().isNotEmpty && !isExpired;

  /// Checks if the session has administrator privileges.
  bool get isAdmin => roles.contains('ROLE_ADMIN');

  /// Returns user-friendly role name for header/profile display.
  String get displayRole {
    if (isAdmin) return 'Administrator';
    if (roles.contains('ROLE_USER')) return 'Operator';
    if (roles.isNotEmpty) {
      return roles.first.replaceFirst('ROLE_', '');
    }
    return 'Staff';
  }

  /// Safe toString implementation that masks the token and excludes sensitive data.
  @override
  String toString() {
    final maskedToken = token.length > 12
        ? '${token.substring(0, 10)}...'
        : '[PROTECTED]';
    return 'AuthSession(username: $username, type: $type, token: $maskedToken, expiresAt: $expiresAt, roles: $roles)';
  }
}
