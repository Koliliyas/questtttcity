import 'package:dartz/dartz.dart';
import 'package:los_angeles_quest/core/error/failure.dart';
import 'package:los_angeles_quest/core/params/authentification_param.dart';
import 'package:los_angeles_quest/core/usecases/usecase.dart';
import 'package:los_angeles_quest/features/domain/repositories/auth_repository.dart';

class VerifyCode extends UseCase<void, AuthenticationParams> {
  final AuthRepository authRepository;

  VerifyCode(this.authRepository);

  Future<Either<Failure, void>> call(AuthenticationParams params) async {
    return await authRepository.verifyCode(
        params.email, params.password!, params.code!);
  }
}
