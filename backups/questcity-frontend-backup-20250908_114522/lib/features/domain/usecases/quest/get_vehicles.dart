import 'package:dartz/dartz.dart';
import 'package:los_angeles_quest/core/error/failure.dart';
import 'package:los_angeles_quest/core/params/no_param.dart';
import 'package:los_angeles_quest/core/usecases/usecase.dart';
import 'package:los_angeles_quest/features/domain/entities/quest_parameter_entity.dart';
import 'package:los_angeles_quest/features/domain/repositories/quest_repository.dart';

class GetVehicles extends UseCase<List<QuestParameterEntity>, NoParams> {
  final QuestRepository questRepository;

  GetVehicles(this.questRepository);

  @override
  Future<Either<Failure, List<QuestParameterEntity>>> call(
      NoParams params) async {
    print(
        '🔍 DEBUG: GetVehicles.call() - Начинаем загрузку транспортных средств');
    try {
      final result = await questRepository.getVehicles();
      return result;
    } catch (e) {
      print(
          '❌ ERROR: GetVehicles.call() - Ошибка загрузки транспортных средств: $e');
      print('❌ ERROR: Тип исключения: ${e.runtimeType}');
      return Left(ServerFailure());
    }
  }
}
