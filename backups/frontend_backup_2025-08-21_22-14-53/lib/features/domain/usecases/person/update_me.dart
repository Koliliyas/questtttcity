import 'package:dartz/dartz.dart';
import 'package:los_angeles_quest/core/error/failure.dart';
import 'package:los_angeles_quest/core/usecases/usecase.dart';
import 'package:los_angeles_quest/features/domain/repositories/person_repository.dart';
import 'package:los_angeles_quest/features/domain/usecases/user/edit_user.dart';

class UpdateMe extends UseCase<void, EditUserParams> {
  final PersonRepository personRepository;

  UpdateMe(this.personRepository);

  Future<Either<Failure, void>> call(EditUserParams params) async {
    return await personRepository.updateMe(params);
  }
}
