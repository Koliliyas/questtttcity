import 'package:dartz/dartz.dart';
import 'package:los_angeles_quest/core/error/failure.dart';
import 'package:los_angeles_quest/core/usecases/usecase.dart';
import 'package:los_angeles_quest/core/params/no_param.dart';
import 'package:los_angeles_quest/features/domain/repositories/auth_repository_new.dart';
import 'package:los_angeles_quest/features/data/models/auth/token_response_model.dart';

class RefreshTokens extends UseCase<TokenResponseModel, NoParams> {
  final AuthRepositoryNew authRepository;

  RefreshTokens(this.authRepository);

  @override
  Future<Either<Failure, TokenResponseModel>> call(NoParams params) async {
    return await authRepository.refreshTokens();
  }
}
