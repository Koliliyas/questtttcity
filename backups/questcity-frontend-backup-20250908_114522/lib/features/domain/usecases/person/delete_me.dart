import 'package:dartz/dartz.dart';
import 'package:los_angeles_quest/core/error/failure.dart';
import 'package:los_angeles_quest/core/params/no_param.dart';
import 'package:los_angeles_quest/core/usecases/usecase.dart';
import 'package:los_angeles_quest/features/domain/repositories/person_repository.dart';

class DeleteMe extends UseCase<void, NoParams> {
  final PersonRepository personRepository;

  DeleteMe(this.personRepository);

  Future<Either<Failure, void>> call(NoParams params) async {
    return await personRepository.deleteMe();
  }
}
