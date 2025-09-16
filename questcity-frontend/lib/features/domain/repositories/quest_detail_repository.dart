import 'package:los_angeles_quest/features/presentation/pages/common/quest_detail/cubit/quest_detail_screen_cubit.dart';

abstract class QuestDetailRepository {
  Future<QuestDetails> getQuestDetail(int questId);
}
