import 'package:dartz/dartz.dart';
import 'package:los_angeles_quest/core/error/exception.dart';
import 'package:los_angeles_quest/core/error/failure.dart';
import 'package:los_angeles_quest/core/params/register_param.dart';
import 'package:los_angeles_quest/core/platform/network_info.dart';
import 'package:los_angeles_quest/features/data/datasources/auth_remote_data_source_impl.dart';
import 'package:los_angeles_quest/features/domain/repositories/auth_repository.dart';

class AuthRepositoryImpl implements AuthRepository {
  final AuthRemoteDataSource authRemoteDataSource;
  final NetworkInfo networkInfo;

  const AuthRepositoryImpl(
      {required this.authRemoteDataSource, required this.networkInfo});

  @override
  Future<Either<Failure, void>> getVerificationCode(String email) async =>
      await _templateFun(
          () async => await authRemoteDataSource.getVerificationCode(email));

  @override
  Future<Either<Failure, void>> login(String email, String password) async =>
      await _templateFun(
          () async => await authRemoteDataSource.login(email, password));

  @override
  Future<Either<Failure, void>> register(RegisterParam param) async =>
      await _templateFun(
          () async => await authRemoteDataSource.register(param));

  @override
  Future<Either<Failure, void>> verifyCode(
          String email, String password, String code) async =>
      await _templateFun(() async =>
          await authRemoteDataSource.verifyCode(email, password, code));

  @override
  Future<Either<Failure, void>> resetPassword(String email) async =>
      await _templateFun(
          () async => await authRemoteDataSource.resetPassword(email));

  @override
  Future<Either<Failure, void>> verifyResetPassword(
          String email, String password, String code) async =>
      await _templateFun(() async => await authRemoteDataSource
          .verifyResetPassword(email, password, code));

  @override
  Future<void> unblock(String email) async {
    await authRemoteDataSource.unblock(email);
  }

  @override
  Future<Either<Failure, void>> reloadToken() async =>
      await _templateFun(() async => await authRemoteDataSource.refreshToken());

  Future<Either<Failure, void>> _templateFun(
      Future<void> Function() fun) async {
    if (await networkInfo.isConnected) {
      try {
        return Right(await fun());
      } on ServerException {
        return Left(ServerFailure());
      } on EmailAlreadyExistsException {
        return Left(EmailAlreadyExistsFailure());
      } on EmailUncorrectedException {
        return Left(EmailUncorrectedFailure());
      } on PasswordUncorrectedException {
        return Left(PasswordUncorrectedFailure());
      } on UserNotFoundException {
        return Left(UserNotFoundFailure());
      } on UserNotVerifyException {
        return Left(UserNotVerifyFailure());
      } on UncorrectedVerifyCodeException {
        return Left(UncorrectedVerifyCodeFailure());
      }
    } else {
      return Left(InternetConnectionFailure());
    }
  }
}
