import 'package:dartz/dartz.dart';
import 'package:los_angeles_quest/core/error/failure.dart';
import 'package:los_angeles_quest/features/data/datasources/web_socket_remote_data_source_impl.dart';
import 'package:los_angeles_quest/features/data/models/message_model.dart';

abstract class WebSocketRepository {
  Future<Either<Failure, void>> connect(String token);
  Future<Either<Failure, void>> disconnect();
  Future<Either<Failure, void>> sendMessage(MessageModel message);
  Stream<WebSocketEvent> receiveMessages();
}
