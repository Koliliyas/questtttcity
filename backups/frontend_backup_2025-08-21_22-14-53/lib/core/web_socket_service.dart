import 'package:los_angeles_quest/utils/logger.dart';
import 'package:web_socket_channel/io.dart';
import 'package:web_socket_channel/web_socket_channel.dart';

class WebSocketService {
  late WebSocketChannel _channel;

  void connect() {
    _channel = IOWebSocketChannel.connect(
      Uri.parse(
          'wss://questicity.com/api/v1.0/chats/b89d37c1-4e56-407b-80d4-cab96cf6be75ff29dadd-b918-4703-9f0b-cecfa2eea7e0'),
      headers: {
        'Authorization':
            'Bearer eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJmYmlkIjoiZmJpZCIsImlkX3VzZXIiOjIwLCJleHBpcmVfdGltZSI6MjU5MjAwMCwiZXhwIjoxNzI2NTE3OTE0fQ.VmPTMKMS0Uh-RRRoG97_yvN-T5-cofG27e06Fjuplwk',
      },
    );

    _channel.stream.listen(
      (message) {
        appLogger.d('Socket: Получено сообщение: $message');
      },
      onDone: () {
        appLogger.d('Socket: Соединение закрыто');
      },
      onError: (error) {
        appLogger.d('Socket: Ошибка соединения: $error');
      },
    );

    appLogger.d('Socket: Соединение установлено успешно');
  }

  void disconnect() {
    _channel.sink.close();
    appLogger.d('Socket: Отключено');
  }

  void sendMessage(String message) {
    _channel.sink.add(message);
    appLogger.d('Socket: Отправлено сообщение: $message');
  }
}
