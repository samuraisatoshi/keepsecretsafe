// lib/src/exceptions.dart

/// Base exception class for Secret Manager related errors.
class SecretManagerException implements Exception {
  final String message;
  SecretManagerException(this.message);

  @override
  String toString() => 'SecretManagerException: $message';
}

/// Exception class for authentication errors.
class SecretServiceException extends SecretManagerException {
  SecretServiceException(String message) : super(message);
}

/// Exception class for cases where a secret is not found.
class SecretNotFoundException extends SecretManagerException {
  SecretNotFoundException(String message) : super(message);
}
