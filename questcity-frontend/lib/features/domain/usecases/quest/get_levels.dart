import 'package:dartz/dartz.dart';
import 'package:los_angeles_quest/core/error/failure.dart';
import 'package:los_angeles_quest/core/params/no_param.dart';
import 'package:los_angeles_quest/core/usecases/usecase.dart';
import 'package:los_angeles_quest/features/domain/entities/quest_parameter_entity.dart';
import 'package:los_angeles_quest/features/domain/repositories/quest_repository.dart';

class GetLevels extends UseCase<List<QuestParameterEntity>, NoParams> {
  final QuestRepository questRepository;

  GetLevels(this.questRepository);

  @override
  Future<Either<Failure, List<QuestParameterEntity>>> call(
      NoParams params) async {
    print('🔍 DEBUG: GetLevels.call() - Начинаем загрузку уровней');
    try {
      final result = await questRepository.getLevels();
      print(
          '✅ DEBUG: GetLevels.call() - Уровни успешно загружены: ${result.length}');
      return result;
    } catch (e) {
      print('❌ ERROR: GetLevels.call() - Ошибка загрузки уровней: $e');
      print('❌ ERROR: Тип исключения: ${e.runtimeType}');
      return Left(ServerFailure());
    }
  }
}
