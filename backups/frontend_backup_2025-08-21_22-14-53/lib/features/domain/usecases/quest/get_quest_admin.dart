import 'package:dartz/dartz.dart';
import 'package:los_angeles_quest/core/error/failure.dart';
import 'package:los_angeles_quest/core/usecases/usecase.dart';
import 'package:los_angeles_quest/features/domain/repositories/quest_repository.dart';

class GetQuestAdmin extends UseCase<Map<String, dynamic>, int> {
  final QuestRepository questRepository;

  GetQuestAdmin(this.questRepository);

  @override
  Future<Either<Failure, Map<String, dynamic>>> call(int questId) async {
    return await questRepository.getQuest(questId);
  }
}















