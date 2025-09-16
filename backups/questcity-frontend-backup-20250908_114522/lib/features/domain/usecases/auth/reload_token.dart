import 'package:dartz/dartz.dart';
import 'package:los_angeles_quest/core/error/failure.dart';
import 'package:los_angeles_quest/core/params/no_param.dart';
import 'package:los_angeles_quest/core/usecases/usecase.dart';
import 'package:los_angeles_quest/features/domain/repositories/auth_repository.dart';

class ReloadToken extends UseCase<void, NoParams> {
  final AuthRepository authRepository;

  ReloadToken(this.authRepository);

  Future<Either<Failure, void>> call(NoParams params) async {
    return await authRepository.reloadToken();
  }
}
