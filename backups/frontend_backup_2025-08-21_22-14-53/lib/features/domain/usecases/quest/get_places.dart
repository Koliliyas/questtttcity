import 'package:dartz/dartz.dart';
import 'package:los_angeles_quest/core/error/failure.dart';
import 'package:los_angeles_quest/core/params/no_param.dart';
import 'package:los_angeles_quest/core/usecases/usecase.dart';
import 'package:los_angeles_quest/features/domain/entities/quest_parameter_entity.dart';
import 'package:los_angeles_quest/features/domain/repositories/quest_repository.dart';

class GetPlaces extends UseCase<List<QuestParameterEntity>, NoParams> {
  final QuestRepository questRepository;

  GetPlaces(this.questRepository);

  @override
  Future<Either<Failure, List<QuestParameterEntity>>> call(
      NoParams params) async {
    print('🔍 DEBUG: GetPlaces.call() - Начинаем загрузку мест');
    try {
      final result = await questRepository.getPlaces();
      print(
          '✅ DEBUG: GetPlaces.call() - Места успешно загружены: ${result.length}');
      return result;
    } catch (e) {
      print('❌ ERROR: GetPlaces.call() - Ошибка загрузки мест: $e');
      print('❌ ERROR: Тип исключения: ${e.runtimeType}');
      return Left(ServerFailure());
    }
  }
}
