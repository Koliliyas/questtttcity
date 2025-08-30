import 'package:dartz/dartz.dart';
import 'package:los_angeles_quest/core/error/failure.dart';
import 'package:los_angeles_quest/features/data/models/quest_parameter_model.dart';
import 'package:los_angeles_quest/features/data/models/quests/current_quest_model.dart';
import 'package:los_angeles_quest/features/domain/entities/quest_parameter_entity.dart';

import '../../data/models/quests/quest_list_model.dart';
import '../../data/models/quests/quest_model.dart';

abstract class QuestRepository {
  Future<Either<Failure, List<QuestParameterEntity>>> getLevels();
  Future<Either<Failure, List<QuestParameterEntity>>> getPlaces();
  Future<Either<Failure, List<QuestParameterEntity>>> getMiles();
  Future<Either<Failure, List<QuestParameterEntity>>> getVehicles();
  Future<Either<Failure, List<QuestParameterEntity>>> getPrices();
  Future<Either<Failure, QuestParameterModel>> create(dynamic quest);
  Future<Either<Failure, QuestParameterModel>> update(int id, dynamic quest);
  Future<Either<Failure, void>> delete(int id);
  Future<QuestListModel> getAll();
  Future<QuestModel> getOne(int id);
  Future<CurrentQuestModel> getCurrentQuest(int id);
  Future<Either<Failure, List<Map<String, dynamic>>>> getAllQuests();
  Future<Either<Failure, List<Map<String, dynamic>>>> getAllQuestsForUsers();
  Future<Either<Failure, Map<String, dynamic>>> createQuest(
      Map<String, dynamic> questData);
  Future<Either<Failure, Map<String, dynamic>>> updateQuest(
      int questId, Map<String, dynamic> questData);
  Future<Either<Failure, Map<String, dynamic>>> getQuest(int questId);

  // Новые методы для админской панели согласно ТЗ
  Future<Either<Failure, Map<String, dynamic>>> getQuestAnalytics();
  Future<Either<Failure, Map<String, dynamic>>> bulkActionQuests(
      String action, List<int> questIds);
  Future<Either<Failure, void>> deleteQuest(int questId);
}
