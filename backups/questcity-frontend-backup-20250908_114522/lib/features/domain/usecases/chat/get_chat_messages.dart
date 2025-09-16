import 'package:dartz/dartz.dart';
import 'package:equatable/equatable.dart';
import 'package:los_angeles_quest/core/error/failure.dart';
import 'package:los_angeles_quest/core/usecases/usecase.dart';
import 'package:los_angeles_quest/features/domain/entities/message_entity.dart';
import 'package:los_angeles_quest/features/domain/repositories/chat_repository.dart';

class GetChatMessages
    extends UseCase<List<MessageEntity>, GetChatMessagesParams> {
  final ChatRepository chatRepository;

  GetChatMessages(this.chatRepository);

  Future<Either<Failure, List<MessageEntity>>> call(
      GetChatMessagesParams params) async {
    return await chatRepository.getMessages(
        chatId: params.chatId, offset: params.offset, limit: params.limit);
  }
}

class GetChatMessagesParams extends Equatable {
  final int chatId;
  final int? offset;
  final int? limit;

  const GetChatMessagesParams({required this.chatId, this.limit, this.offset});

  @override
  List<Object?> get props => [chatId, limit, offset];
}
