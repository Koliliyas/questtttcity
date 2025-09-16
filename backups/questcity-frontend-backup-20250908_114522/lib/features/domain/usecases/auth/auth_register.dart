import 'package:dartz/dartz.dart';
import 'package:los_angeles_quest/core/error/failure.dart';
import 'package:los_angeles_quest/core/params/register_param.dart';
import 'package:los_angeles_quest/core/usecases/usecase.dart';
import 'package:los_angeles_quest/features/domain/repositories/auth_repository.dart';

class AuthRegister extends UseCase<void, RegisterParam> {
  final AuthRepository authRepository;

  AuthRegister(this.authRepository);

  Future<Either<Failure, void>> call(RegisterParam params) async {
    return await authRepository.register(params);
  }
}
