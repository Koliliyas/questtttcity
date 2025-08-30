import 'package:dartz/dartz.dart';
import 'package:los_angeles_quest/core/error/failure.dart';
import 'package:los_angeles_quest/core/usecases/usecase.dart';
import 'package:los_angeles_quest/features/domain/repositories/auth_repository_new.dart';
import 'package:los_angeles_quest/features/data/models/auth/register_request_model.dart';

class AuthRegisterNew extends UseCase<void, RegisterRequestModel> {
  final AuthRepositoryNew authRepository;

  AuthRegisterNew(this.authRepository);

  @override
  Future<Either<Failure, void>> call(RegisterRequestModel params) async {
    return await authRepository.register(params);
  }
}
