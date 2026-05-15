class ApiException implements Exception {
  final int? statusCode;
  final String message;
  final Object? inner;

  ApiException(this.message, {this.statusCode, this.inner});

  @override
  String toString() =>
      'ApiException(statusCode: $statusCode, message: $message, inner: $inner)';
}
