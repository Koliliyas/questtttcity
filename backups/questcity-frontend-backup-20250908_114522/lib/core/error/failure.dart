import 'package:equatable/equatable.dart';

abstract class Failure extends Equatable {
  @override
  List<Object> get props => [];
}

class ServerFailure extends Failure {}

class CacheFailure extends Failure {}

class InternetConnectionFailure extends Failure {}

class EmailAlreadyExistsFailure extends Failure {}

class EmailUncorrectedFailure extends Failure {}

class UserNotFoundFailure extends Failure {}

class PasswordUncorrectedFailure extends Failure {}

class UserNotVerifyFailure extends Failure {}

class UncorrectedVerifyCodeFailure extends Failure {}

class ConnectionFailure extends Failure {}

class TimeoutFailure extends Failure {}

class ValidationFailure extends Failure {}

class UnauthorizedFailure extends Failure {}

class NotFoundFailure extends Failure {}

class NotImplementedFailure extends Failure {}

class StorageFailure extends Failure {}
