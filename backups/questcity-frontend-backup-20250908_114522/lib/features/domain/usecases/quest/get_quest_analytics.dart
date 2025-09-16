import 'package:dartz/dartz.dart';
import 'package:los_angeles_quest/core/error/failure.dart';
import 'package:los_angeles_quest/core/params/no_param.dart';
import 'package:los_angeles_quest/core/usecases/usecase.dart';
import 'package:los_angeles_quest/features/domain/repositories/quest_repository.dart';

class GetQuestAnalytics extends UseCase<Map<String, dynamic>, NoParams> {
  final QuestRepository questRepository;

  GetQuestAnalytics(this.questRepository);

  @override
  Future<Either<Failure, Map<String, dynamic>>> call(NoParams params) async {
    return await questRepository.getQuestAnalytics();
  }
}
