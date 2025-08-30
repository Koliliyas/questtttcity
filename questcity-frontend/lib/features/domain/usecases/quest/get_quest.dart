import 'package:los_angeles_quest/features/data/models/quests/quest_model.dart';
import 'package:los_angeles_quest/features/domain/repositories/quest_repository.dart';

class GetQuest {
  final QuestRepository questRepository;

  GetQuest(this.questRepository);

  Future<QuestModel> call(int params) async {
    return await questRepository.getOne(params);
  }
}
