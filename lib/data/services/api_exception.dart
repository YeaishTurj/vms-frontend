/// Exception thrown when an HTTP communication or backend REST error occurs.
class ApiException implements Exception {
  final int statusCode;
  final String message;
  final String? error;
  final Map<String, String>? fieldErrors;

  const ApiException({
    required this.statusCode,
    required this.message,
    this.error,
    this.fieldErrors,
  });

  bool get isDuplicate => statusCode == 409;
  bool get isNotFound => statusCode == 404;
  bool get isValidationError => statusCode == 400 && (fieldErrors != null && fieldErrors!.isNotEmpty);

  @override
  String toString() {
    if (fieldErrors != null && fieldErrors!.isNotEmpty) {
      final details = fieldErrors!.entries.map((e) => '${e.key}: ${e.value}').join(', ');
      return '$message ($details)';
    }
    return message;
  }
}
