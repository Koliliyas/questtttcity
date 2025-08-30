class ServerException implements Exception {
  final String message;
  ServerException([this.message = 'Server error']);

  @override
  String toString() => 'ServerException: $message';
}

class CacheException implements Exception {}

class EmailAlreadyExistsException implements Exception {}

class EmailUncorrectedException implements Exception {}

class UserNotFoundException implements Exception {}

class PasswordUncorrectedException implements Exception {}

class UserNotVerifyException implements Exception {}

class UncorrectedVerifyCodeException implements Exception {}

class RegisterValidationException implements Exception {}

class UnauthorizedException implements Exception {
  final String message;
  UnauthorizedException([this.message = 'Unauthorized access']);

  @override
  String toString() => 'UnauthorizedException: $message';
}
