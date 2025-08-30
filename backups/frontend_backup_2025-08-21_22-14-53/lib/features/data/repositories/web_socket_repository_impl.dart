import 'package:dartz/dartz.dart';
import 'package:los_angeles_quest/core/error/exception.dart';
import 'package:los_angeles_quest/core/error/failure.dart';
import 'package:los_angeles_quest/core/platform/network_info.dart';
import 'package:los_angeles_quest/features/data/datasources/web_socket_remote_data_source_impl.dart';
import 'package:los_angeles_quest/features/data/models/message_model.dart';
import 'package:los_angeles_quest/features/domain/repositories/web_socket_repository.dart';

class WebSocketRepositoryImpl implements WebSocketRepository {
  final WebSocketRemoteDataSource webSocketRemoteDataSource;
  final NetworkInfo networkInfo;

  WebSocketRepositoryImpl(
      {required this.webSocketRemoteDataSource, required this.networkInfo});

  @override
  Future<Either<Failure, void>> connect(String token) async {
    if (await networkInfo.isConnected) {
      try {
        return Right(webSocketRemoteDataSource.connect(token));
      } on ServerException {
        return Left(ServerFailure());
      }
    } else {
      return Left(InternetConnectionFailure());
    }
  }

  @override
  Future<Either<Failure, void>> disconnect() async {
    if (await networkInfo.isConnected) {
      try {
        return Right(webSocketRemoteDataSource.disconnect());
      } on ServerException {
        return Left(ServerFailure());
      }
    } else {
      return Left(InternetConnectionFailure());
    }
  }

  @override
  Future<Either<Failure, void>> sendMessage(MessageModel message) async {
    if (await networkInfo.isConnected) {
      try {
        return Right(webSocketRemoteDataSource.sendMessage(message));
      } on ServerException {
        return Left(ServerFailure());
      }
    } else {
      return Left(InternetConnectionFailure());
    }
  }

  @override
  Stream<WebSocketEvent> receiveMessages() {
    return webSocketRemoteDataSource.receiveMessages();
  }
}
