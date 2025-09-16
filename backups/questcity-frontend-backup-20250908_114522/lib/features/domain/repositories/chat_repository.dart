import 'package:dartz/dartz.dart';
import 'package:los_angeles_quest/core/error/failure.dart';
import 'package:los_angeles_quest/features/domain/entities/message_entity.dart';
import 'package:los_angeles_quest/features/domain/entities/chat_entity.dart'
    as ce;

abstract class ChatRepository {
  Future<Either<Failure, List<ce.ChatEntity>>> getAll();
  Future<Either<Failure, List<MessageEntity>>> getMessages(
      {required int chatId, int? limit, int? offset});
}
