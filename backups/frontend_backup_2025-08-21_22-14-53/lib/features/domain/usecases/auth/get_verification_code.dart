import 'package:dartz/dartz.dart';
import 'package:los_angeles_quest/core/error/failure.dart';
import 'package:los_angeles_quest/core/params/authentification_param.dart';
import 'package:los_angeles_quest/core/usecases/usecase.dart';
import 'package:los_angeles_quest/features/domain/repositories/auth_repository.dart';

class GetVerificationCode extends UseCase<void, AuthenticationParams> {
  final AuthRepository authRepository;

  GetVerificationCode(this.authRepository);

  Future<Either<Failure, void>> call(AuthenticationParams params) async {
    return await authRepository.getVerificationCode(params.email);
  }
}
