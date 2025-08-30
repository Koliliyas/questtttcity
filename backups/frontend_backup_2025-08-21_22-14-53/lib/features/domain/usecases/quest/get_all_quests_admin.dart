import 'package:dartz/dartz.dart';
import 'package:los_angeles_quest/core/error/failure.dart';
import 'package:los_angeles_quest/core/params/no_param.dart';
import 'package:los_angeles_quest/core/usecases/usecase.dart';
import 'package:los_angeles_quest/features/domain/repositories/quest_repository.dart';

class GetAllQuestsAdmin extends UseCase<List<Map<String, dynamic>>, NoParams> {
  final QuestRepository questRepository;

  GetAllQuestsAdmin(this.questRepository);

  @override
  Future<Either<Failure, List<Map<String, dynamic>>>> call(
      NoParams params) async {
    return await questRepository.getAllQuests();
  }
}
