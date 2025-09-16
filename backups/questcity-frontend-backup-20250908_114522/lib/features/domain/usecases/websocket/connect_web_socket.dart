import 'package:dartz/dartz.dart';
import 'package:los_angeles_quest/core/error/failure.dart';
import 'package:los_angeles_quest/features/data/datasources/web_socket_remote_data_source_impl.dart';
import 'package:los_angeles_quest/features/data/models/message_model.dart';
import 'package:los_angeles_quest/features/domain/repositories/web_socket_repository.dart';

class WebSocketConnect {
  final WebSocketRepository repository;

  WebSocketConnect(this.repository);

  Future<Either<Failure, void>> call(String token) async {
    return await repository.connect(token);
  }
}

class WebSocketDisconnect {
  final WebSocketRepository repository;

  WebSocketDisconnect(this.repository);

  Future<Either<Failure, void>> call() async {
    return await repository.disconnect();
  }
}

class WebSocketSendMessage {
  final WebSocketRepository repository;

  WebSocketSendMessage(this.repository);

  Future<Either<Failure, void>> call(MessageModel message) async {
    return await repository.sendMessage(message);
  }
}

class WebSocketReceiveMessages {
  final WebSocketRepository repository;

  WebSocketReceiveMessages(this.repository);

  Stream<WebSocketEvent> call() {
    return repository.receiveMessages();
  }
}
