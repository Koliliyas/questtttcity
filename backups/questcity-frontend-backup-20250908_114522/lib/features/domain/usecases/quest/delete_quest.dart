import 'package:dartz/dartz.dart';
import 'package:los_angeles_quest/core/error/failure.dart';
import 'package:los_angeles_quest/core/usecases/usecase.dart';
import 'package:los_angeles_quest/features/domain/repositories/quest_repository.dart';

class DeleteQuestParams {
  final int questId;

  DeleteQuestParams({required this.questId});
}

class DeleteQuest extends UseCase<void, DeleteQuestParams> {
  final QuestRepository questRepository;

  DeleteQuest(this.questRepository);

  @override
  Future<Either<Failure, void>> call(DeleteQuestParams params) async {
    return await questRepository.deleteQuest(params.questId);
  }
}
