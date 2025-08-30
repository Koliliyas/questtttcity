import 'package:dartz/dartz.dart';
import 'package:los_angeles_quest/core/error/failure.dart';
import 'package:los_angeles_quest/core/params/register_param.dart';

abstract class AuthRepository {
  Future<Either<Failure, void>> register(RegisterParam param);
  Future<Either<Failure, void>> getVerificationCode(String email);
  Future<Either<Failure, void>> verifyCode(
      String email, String password, String code);
  Future<Either<Failure, void>> login(String email, String password);
  Future<Either<Failure, void>> resetPassword(String email);
  Future<Either<Failure, void>> verifyResetPassword(
      String email, String password, String code);
  Future<Either<Failure, void>> reloadToken();
  Future<void> unblock(String email);
}
