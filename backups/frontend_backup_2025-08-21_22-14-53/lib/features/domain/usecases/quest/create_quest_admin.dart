import 'package:dartz/dartz.dart';
import 'package:los_angeles_quest/core/error/failure.dart';
import 'package:los_angeles_quest/core/usecases/usecase.dart';
import 'package:los_angeles_quest/features/domain/repositories/quest_repository.dart';

class CreateQuestAdmin
    extends UseCase<Map<String, dynamic>, Map<String, dynamic>> {
  final QuestRepository questRepository;

  CreateQuestAdmin(this.questRepository);

  @override
  Future<Either<Failure, Map<String, dynamic>>> call(
      Map<String, dynamic> questData) async {
    return await questRepository.createQuest(questData);
  }
}















