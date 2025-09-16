import 'package:dartz/dartz.dart';
import 'package:los_angeles_quest/core/error/failure.dart';
import 'package:los_angeles_quest/core/params/no_param.dart';
import 'package:los_angeles_quest/core/usecases/usecase.dart';
import 'package:los_angeles_quest/features/domain/entities/chat_entity.dart';
import 'package:los_angeles_quest/features/domain/repositories/chat_repository.dart';

class GetAllChats extends UseCase<List<ChatEntity>, NoParams> {
  final ChatRepository chatRepository;

  GetAllChats(this.chatRepository);

  Future<Either<Failure, List<ChatEntity>>> call(NoParams params) async {
    return await chatRepository.getAll();
  }
}
