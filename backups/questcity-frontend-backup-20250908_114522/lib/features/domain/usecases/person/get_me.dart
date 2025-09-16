import 'package:dartz/dartz.dart';
import 'package:los_angeles_quest/core/error/failure.dart';
import 'package:los_angeles_quest/core/params/no_param.dart';
import 'package:los_angeles_quest/core/usecases/usecase.dart';
import 'package:los_angeles_quest/features/data/models/person_model.dart';
import 'package:los_angeles_quest/features/domain/repositories/person_repository.dart';

class GetMe extends UseCase<PersonModel, NoParams> {
  final PersonRepository personRepository;

  GetMe(this.personRepository);

  Future<Either<Failure, PersonModel>> call(NoParams params) async {
    return await personRepository.getMe();
  }
}
