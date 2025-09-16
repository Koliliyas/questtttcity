import 'package:los_angeles_quest/features/domain/repositories/quest_detail_repository.dart';
import 'package:los_angeles_quest/features/presentation/pages/common/quest_detail/cubit/quest_detail_screen_cubit.dart';

class GetQuestDetail {
  final QuestDetailRepository _repository;

  GetQuestDetail(this._repository);

  Future<QuestDetails> call(int questId) async {
    return await _repository.getQuestDetail(questId);
  }
}
