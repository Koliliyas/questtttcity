import 'package:dartz/dartz.dart';
import 'package:los_angeles_quest/core/error/failure.dart';
import 'package:los_angeles_quest/core/params/authentification_param.dart';
import 'package:los_angeles_quest/core/usecases/usecase.dart';
import 'package:los_angeles_quest/features/domain/repositories/auth_repository.dart';

class VerifyResetPassword extends UseCase<void, AuthenticationParams> {
  final AuthRepository authRepository;

  VerifyResetPassword(this.authRepository);

  Future<Either<Failure, void>> call(AuthenticationParams params) async {
    return await authRepository.verifyResetPassword(
        params.email, params.password!, params.code!);
  }
}
