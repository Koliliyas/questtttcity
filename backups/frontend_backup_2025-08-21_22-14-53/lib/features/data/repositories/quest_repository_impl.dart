import 'package:dartz/dartz.dart';
import 'package:los_angeles_quest/core/error/exception.dart';
import 'package:los_angeles_quest/core/error/failure.dart';
import 'package:los_angeles_quest/core/platform/network_info.dart';
import 'package:los_angeles_quest/features/data/datasources/quest_remote_data_source_impl.dart';
import 'package:los_angeles_quest/features/data/models/quest_parameter_model.dart';
import 'package:los_angeles_quest/features/data/models/quests/current_quest_model.dart';
import 'package:los_angeles_quest/features/data/models/quests/quest_create_model.dart';
import 'package:los_angeles_quest/features/data/models/quests/quest_update_model.dart';
import 'package:los_angeles_quest/features/domain/entities/quest_parameter_entity.dart';

import '../models/quests/quest_list_model.dart';
import '../models/quests/quest_model.dart';
import '../../domain/repositories/quest_repository.dart';

class QuestRepositoryImpl implements QuestRepository {
  final QuestRemoteDataSource questRemoteDataSource;
  final NetworkInfo networkInfo;

  const QuestRepositoryImpl(
      {required this.questRemoteDataSource, required this.networkInfo});

  @override
  Future<Either<Failure, QuestParameterModel>> create(dynamic quest) async {
    if (await networkInfo.isConnected) {
      try {
        return Right(
            await questRemoteDataSource.create(quest as QuestCreateModel));
      } on UnauthorizedException catch (e) {
        print(
            '🔍 DEBUG: QuestRepositoryImpl.create() - UnauthorizedException caught: $e');
        return Left(UnauthorizedFailure());
      } on ServerException catch (e) {
        print(
            '🔍 DEBUG: QuestRepositoryImpl.create() - ServerException caught: $e');
        return Left(ServerFailure());
      } catch (e) {
        print('🔍 DEBUG: QuestRepositoryImpl.create() - Unexpected error: $e');
        return Left(ServerFailure());
      }
    } else {
      return Left(InternetConnectionFailure());
    }
  }

  @override
  Future<Either<Failure, QuestParameterModel>> update(
      int id, dynamic quest) async {
    if (await networkInfo.isConnected) {
      try {
        // Конвертируем QuestUpdateModel в Map<String, dynamic> и вызываем правильный метод
        final questData = (quest as QuestUpdateModel).toJson();
        final result = await questRemoteDataSource.updateQuest(id, questData);
        // Возвращаем QuestParameterModel (пока пустой, так как updateQuest возвращает Map)
        return Right(QuestParameterModel(
            id: id, title: 'Updated Quest')); // TODO: конвертировать результат
      } on ServerException catch (e) {
        print(
            '🔍 DEBUG: QuestRepositoryImpl.update() - ServerException caught: $e');
        return Left(ServerFailure());
      } catch (e) {
        print('🔍 DEBUG: QuestRepositoryImpl.update() - Unexpected error: $e');
        return Left(ServerFailure());
      }
    } else {
      return Left(InternetConnectionFailure());
    }
  }

  @override
  Future<Either<Failure, void>> delete(int id) async {
    if (await networkInfo.isConnected) {
      try {
        await questRemoteDataSource.delete(id);
        return const Right(null);
      } on ServerException {
        return Left(ServerFailure());
      } catch (e) {
        print('🔍 DEBUG: QuestRepositoryImpl.delete() - Unexpected error: $e');
        return Left(ServerFailure());
      }
    } else {
      return Left(InternetConnectionFailure());
    }
  }

  @override
  Future<QuestListModel> getAll() async {
    return await questRemoteDataSource.getAll();
  }

  @override
  Future<QuestModel> getOne(int id) async {
    return await questRemoteDataSource.getOne(id);
  }

  @override
  Future<CurrentQuestModel> getCurrentQuest(int id) async {
    return await questRemoteDataSource.getCurrentQuest(id);
  }

  @override
  Future<Either<Failure, List<Map<String, dynamic>>>> getAllQuests() async {
    if (await networkInfo.isConnected) {
      try {
        final quests = await questRemoteDataSource.getAllQuests();
        return Right(quests);
      } on UnauthorizedException {
        return Left(UnauthorizedFailure());
      } on ServerException catch (e) {
        print(
            '🔍 DEBUG: QuestRepositoryImpl.getAllQuests() - ServerException caught: $e');
        return Left(ServerFailure());
      } catch (e) {
        print(
            '🔍 DEBUG: QuestRepositoryImpl.getAllQuests() - Unexpected error: $e');
        return Left(ServerFailure());
      }
    } else {
      return Left(InternetConnectionFailure());
    }
  }

  @override
  Future<Either<Failure, List<Map<String, dynamic>>>>
      getAllQuestsForUsers() async {
    if (await networkInfo.isConnected) {
      try {
        final quests = await questRemoteDataSource.getAllQuestsForUsers();
        return Right(quests);
      } on UnauthorizedException {
        return Left(UnauthorizedFailure());
      } on ServerException catch (e) {
        print(
            '🔍 DEBUG: QuestRepositoryImpl.getAllQuestsForUsers() - ServerException caught: $e');
        return Left(ServerFailure());
      } catch (e) {
        print(
            '🔍 DEBUG: QuestRepositoryImpl.getAllQuestsForUsers() - Unexpected error: $e');
        return Left(ServerFailure());
      }
    } else {
      return Left(InternetConnectionFailure());
    }
  }

  @override
  Future<Either<Failure, Map<String, dynamic>>> createQuest(
      Map<String, dynamic> questData) async {
    if (await networkInfo.isConnected) {
      try {
        final result = await questRemoteDataSource.createQuest(questData);
        return Right(result);
      } on UnauthorizedException {
        return Left(UnauthorizedFailure());
      } on ServerException catch (e) {
        print(
            '🔍 DEBUG: QuestRepositoryImpl.createQuest() - ServerException caught: $e');
        return Left(ServerFailure());
      } catch (e) {
        print(
            '🔍 DEBUG: QuestRepositoryImpl.createQuest() - Unexpected error: $e');
        return Left(ServerFailure());
      }
    } else {
      return Left(InternetConnectionFailure());
    }
  }

  @override
  Future<Either<Failure, Map<String, dynamic>>> updateQuest(
      int questId, Map<String, dynamic> questData) async {
    if (await networkInfo.isConnected) {
      try {
        final result =
            await questRemoteDataSource.updateQuest(questId, questData);
        return Right(result);
      } on UnauthorizedException {
        return Left(UnauthorizedFailure());
      } on ServerException catch (e) {
        print(
            '🔍 DEBUG: QuestRepositoryImpl.updateQuest() - ServerException caught: $e');
        return Left(ServerFailure());
      } catch (e) {
        print(
            '🔍 DEBUG: QuestRepositoryImpl.updateQuest() - Unexpected error: $e');
        return Left(ServerFailure());
      }
    } else {
      return Left(InternetConnectionFailure());
    }
  }

  @override
  Future<Either<Failure, Map<String, dynamic>>> getQuest(int questId) async {
    if (await networkInfo.isConnected) {
      try {
        final result = await questRemoteDataSource.getQuest(questId);
        return Right(result);
      } on UnauthorizedException {
        return Left(UnauthorizedFailure());
      } on ServerException catch (e) {
        print(
            '🔍 DEBUG: QuestRepositoryImpl.getQuest() - ServerException caught: $e');
        return Left(ServerFailure());
      } catch (e) {
        print(
            '🔍 DEBUG: QuestRepositoryImpl.getQuest() - Unexpected error: $e');
        return Left(ServerFailure());
      }
    } else {
      return Left(InternetConnectionFailure());
    }
  }

  // Новые методы для админской панели согласно ТЗ
  @override
  Future<Either<Failure, Map<String, dynamic>>> getQuestAnalytics() async {
    if (await networkInfo.isConnected) {
      try {
        final result = await questRemoteDataSource.getQuestAnalytics();
        return Right(result);
      } on UnauthorizedException {
        return Left(UnauthorizedFailure());
      } on ServerException catch (e) {
        print(
            '🔍 DEBUG: QuestRepositoryImpl.getQuestAnalytics() - ServerException caught: $e');
        return Left(ServerFailure());
      } catch (e) {
        print(
            '🔍 DEBUG: QuestRepositoryImpl.getQuestAnalytics() - Unexpected error: $e');
        return Left(ServerFailure());
      }
    } else {
      return Left(InternetConnectionFailure());
    }
  }

  @override
  Future<Either<Failure, Map<String, dynamic>>> bulkActionQuests(
      String action, List<int> questIds) async {
    if (await networkInfo.isConnected) {
      try {
        final result =
            await questRemoteDataSource.bulkActionQuests(action, questIds);
        return Right(result);
      } on UnauthorizedException {
        return Left(UnauthorizedFailure());
      } on ServerException catch (e) {
        print(
            '🔍 DEBUG: QuestRepositoryImpl.bulkActionQuests() - ServerException caught: $e');
        return Left(ServerFailure());
      } catch (e) {
        print(
            '🔍 DEBUG: QuestRepositoryImpl.bulkActionQuests() - Unexpected error: $e');
        return Left(ServerFailure());
      }
    } else {
      return Left(InternetConnectionFailure());
    }
  }

  @override
  Future<Either<Failure, void>> deleteQuest(int questId) async {
    if (await networkInfo.isConnected) {
      try {
        await questRemoteDataSource.deleteQuest(questId);
        return const Right(null);
      } on UnauthorizedException {
        return Left(UnauthorizedFailure());
      } on ServerException catch (e) {
        print(
            '🔍 DEBUG: QuestRepositoryImpl.deleteQuest() - ServerException caught: $e');
        return Left(ServerFailure());
      } catch (e) {
        print(
            '🔍 DEBUG: QuestRepositoryImpl.deleteQuest() - Unexpected error: $e');
        return Left(ServerFailure());
      }
    } else {
      return Left(InternetConnectionFailure());
    }
  }

  @override
  Future<Either<Failure, List<QuestParameterEntity>>> getLevels() async =>
      await _getQuestParameter(questRemoteDataSource.getLevels());

  @override
  Future<Either<Failure, List<QuestParameterEntity>>> getMiles() async =>
      await _getQuestParameter(questRemoteDataSource.getMiles());

  @override
  Future<Either<Failure, List<QuestParameterEntity>>> getPlaces() async =>
      await _getQuestParameter(questRemoteDataSource.getPlaces());

  @override
  Future<Either<Failure, List<QuestParameterEntity>>> getPrices() async =>
      await _getQuestParameter(questRemoteDataSource.getPrices());

  @override
  Future<Either<Failure, List<QuestParameterEntity>>> getVehicles() async =>
      await _getQuestParameter(questRemoteDataSource.getVehicles());

  Future<Either<Failure, List<QuestParameterEntity>>> _getQuestParameter(
      Future<List<QuestParameterEntity>> fun) async {
    if (await networkInfo.isConnected) {
      try {
        final result = await fun;
        return Right(result);
      } catch (e) {
        print('❌ ERROR: QuestRepositoryImpl._getQuestParameter() - Ошибка: $e');
        return Left(ServerFailure());
      }
    } else {
      return Left(InternetConnectionFailure());
    }
  }
}
