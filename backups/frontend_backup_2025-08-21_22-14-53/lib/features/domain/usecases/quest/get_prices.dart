import 'package:dartz/dartz.dart';
import 'package:los_angeles_quest/core/error/failure.dart';
import 'package:los_angeles_quest/core/params/no_param.dart';
import 'package:los_angeles_quest/core/usecases/usecase.dart';
import 'package:los_angeles_quest/features/domain/entities/quest_parameter_entity.dart';
import 'package:los_angeles_quest/features/domain/repositories/quest_repository.dart';

class GetPrices extends UseCase<List<QuestParameterEntity>, NoParams> {
  final QuestRepository questRepository;

  GetPrices(this.questRepository);

  @override
  Future<Either<Failure, List<QuestParameterEntity>>> call(
      NoParams params) async {
    print('🔍 DEBUG: GetPrices.call() - Начинаем загрузку цен');
    try {
      final result = await questRepository.getPrices();
      print(
          '✅ DEBUG: GetPrices.call() - Цены успешно загружены: ${result.length}');
      return result;
    } catch (e) {
      print('❌ ERROR: GetPrices.call() - Ошибка загрузки цен: $e');
      print('❌ ERROR: Тип исключения: ${e.runtimeType}');
      return Left(ServerFailure());
    }
  }
}
