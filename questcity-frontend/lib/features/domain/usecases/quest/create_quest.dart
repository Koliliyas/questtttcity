import 'package:dartz/dartz.dart';
import 'package:los_angeles_quest/core/error/failure.dart';
import 'package:los_angeles_quest/core/usecases/usecase.dart';
import 'package:los_angeles_quest/features/data/models/quests/quest_create_model.dart';
import 'package:los_angeles_quest/features/domain/repositories/quest_repository.dart';

class CreateQuest extends UseCase<void, QuestCreateModel> {
  final QuestRepository questRepository;

  CreateQuest(this.questRepository);

  Future<Either<Failure, void>> call(QuestCreateModel params) async {
    return await questRepository.create(params);
  }
}
