import 'package:dartz/dartz.dart';
import 'package:los_angeles_quest/core/error/failure.dart';
import 'package:los_angeles_quest/core/usecases/usecase.dart';
import 'package:los_angeles_quest/features/domain/repositories/auth_repository_new.dart';
import 'package:los_angeles_quest/features/data/models/auth/token_response_model.dart';

class AuthLoginParams {
  final String email;
  final String password;

  const AuthLoginParams({required this.email, required this.password});
}

class AuthLoginNew extends UseCase<TokenResponseModel, AuthLoginParams> {
  final AuthRepositoryNew authRepository;

  AuthLoginNew(this.authRepository);

  @override
  Future<Either<Failure, TokenResponseModel>> call(
      AuthLoginParams params) async {
    return await authRepository.login(params.email, params.password);
  }
}
