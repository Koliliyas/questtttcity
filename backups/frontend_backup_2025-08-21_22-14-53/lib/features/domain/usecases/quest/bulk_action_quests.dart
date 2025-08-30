import 'package:dartz/dartz.dart';
import 'package:los_angeles_quest/core/error/failure.dart';
import 'package:los_angeles_quest/core/usecases/usecase.dart';
import 'package:los_angeles_quest/features/domain/repositories/quest_repository.dart';

class BulkActionQuestsParams {
  final String action;
  final List<int> questIds;

  BulkActionQuestsParams({required this.action, required this.questIds});
}

class BulkActionQuests
    extends UseCase<Map<String, dynamic>, BulkActionQuestsParams> {
  final QuestRepository questRepository;

  BulkActionQuests(this.questRepository);

  @override
  Future<Either<Failure, Map<String, dynamic>>> call(
      BulkActionQuestsParams params) async {
    return await questRepository.bulkActionQuests(
        params.action, params.questIds);
  }
}
