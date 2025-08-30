import 'package:dartz/dartz.dart';
import 'package:los_angeles_quest/core/error/failure.dart';
import 'package:los_angeles_quest/core/usecases/usecase.dart';
import 'package:los_angeles_quest/features/domain/repositories/user_repository.dart';

class BanUser extends UseCase<void, String> {
  final UserRepository usersRepository;

  BanUser(this.usersRepository);

  Future<Either<Failure, void>> call(String params) async {
    return await usersRepository.ban(params);
  }
}
