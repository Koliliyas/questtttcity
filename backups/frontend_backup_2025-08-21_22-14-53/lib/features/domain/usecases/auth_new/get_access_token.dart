import 'package:dartz/dartz.dart';
import 'package:los_angeles_quest/core/error/failure.dart';
import 'package:los_angeles_quest/core/usecases/usecase.dart';
import 'package:los_angeles_quest/core/params/no_param.dart';
import 'package:los_angeles_quest/features/domain/repositories/auth_repository_new.dart';

class GetAccessToken extends UseCase<String?, NoParams> {
  final AuthRepositoryNew authRepository;

  GetAccessToken(this.authRepository);

  @override
  Future<Either<Failure, String?>> call(NoParams params) async {
    return await authRepository.getAccessToken();
  }
}
