import 'package:dartz/dartz.dart';
import 'package:los_angeles_quest/core/error/exception.dart';
import 'package:los_angeles_quest/core/error/failure.dart';
import 'package:los_angeles_quest/core/platform/network_info.dart';
import 'package:los_angeles_quest/features/data/datasources/chat_remote_data_source_impl.dart';
import 'package:los_angeles_quest/features/domain/entities/chat_entity.dart'
    as ce;
import 'package:los_angeles_quest/features/domain/entities/message_entity.dart';
import 'package:los_angeles_quest/features/domain/repositories/chat_repository.dart';

class ChatRepositoryImpl implements ChatRepository {
  final ChatRemoteDataSource chatRemoteDataSource;
  final NetworkInfo networkInfo;

  const ChatRepositoryImpl(
      {required this.chatRemoteDataSource, required this.networkInfo});

  @override
  Future<Either<Failure, List<ce.ChatEntity>>> getAll() async {
    if (await networkInfo.isConnected) {
      try {
        return Right(await chatRemoteDataSource.getAll());
      } on ServerException {
        return Left(ServerFailure());
      }
    } else {
      return Left(InternetConnectionFailure());
    }
  }

  @override
  Future<Either<Failure, List<MessageEntity>>> getMessages(
      {required int chatId, int? offset, int? limit}) async {
    if (await networkInfo.isConnected) {
      try {
        return Right(await chatRemoteDataSource.getMessages(
            chatId: chatId, offset: offset, limit: limit));
      } on ServerException {
        return Left(ServerFailure());
      }
    } else {
      return Left(InternetConnectionFailure());
    }
  }
}
