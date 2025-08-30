import 'package:dartz/dartz.dart';
import 'package:los_angeles_quest/core/error/failure.dart';
import 'package:los_angeles_quest/core/usecases/usecase.dart';
import 'package:los_angeles_quest/features/domain/repositories/quest_repository.dart';

class UpdateQuestAdmin
    extends UseCase<Map<String, dynamic>, Map<String, dynamic>> {
  final QuestRepository questRepository;

  UpdateQuestAdmin(this.questRepository);

  @override
  Future<Either<Failure, Map<String, dynamic>>> call(
      Map<String, dynamic> params) async {
    final questId = params['questId'] as int;
    final questData = Map<String, dynamic>.from(params);
    questData.remove('questId');

    return await questRepository.updateQuest(questId, questData);
  }
}




















