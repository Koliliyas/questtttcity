import 'package:dartz/dartz.dart';
import 'package:los_angeles_quest/core/error/failure.dart';
import 'package:los_angeles_quest/core/usecases/usecase.dart';
import 'package:los_angeles_quest/features/data/models/quests/quest_update_model.dart';
import 'package:los_angeles_quest/features/domain/repositories/quest_repository.dart';

class UpdateQuest extends UseCase<void, QuestUpdateModel> {
  final QuestRepository questRepository;

  UpdateQuest(this.questRepository);

  Future<Either<Failure, void>> call(QuestUpdateModel params) async {
    if (params.id == null) {
      return Left(ValidationFailure());
    }
    return await questRepository.update(params.id!, params);
  }
}
