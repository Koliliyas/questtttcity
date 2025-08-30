import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:los_angeles_quest/core/shared_preferences_keys.dart';
import 'package:los_angeles_quest/features/data/models/message_model.dart';
import 'package:web_socket_channel/io.dart';

abstract class WebSocketRemoteDataSource {
  void connect(String token);
  void disconnect();
  void sendMessage(MessageModel message);
  Stream<WebSocketEvent> receiveMessages();
}

class WebSocketRemoteDataSourceImpl extends WebSocketRemoteDataSource {
  final FlutterSecureStorage secureStorage;

  WebSocketRemoteDataSourceImpl({required this.secureStorage});

  IOWebSocketChannel? channel;

  @override
  void connect(String token) async {
    //String BASE_URL = dotenv.env['BASE_URL'] ?? 'http://localhost:8000/api/v1/';
    //channel = IOWebSocketChannel.connect(
    //    Uri.parse('${BASE_URL.replaceFirst('https', 'wss')}chats/$token'));

    final String? serverToken =
        await secureStorage.read(key: SharedPreferencesKeys.accessToken);

    channel = IOWebSocketChannel.connect(
        Uri.parse(
            'wss://questicity.com/api/v1.0/chats/37e880cc-f1e9-4268-a5bc-86c5c5b62f99d9473c45-c6cb-4cb8-903a-0628766b65cc'),
        headers: {'Authorization': 'Bearer $serverToken'});
  }

  @override
  void disconnect() {
    channel!.sink.close();
  }

  @override
  void sendMessage(MessageModel message) {
    //channel!.sink.add(jsonEncode(Utils.getNotNullFields(message.toJson())));
    channel!.sink.add(
        '{"id_chat": "1","msg": "aaa","msgType": "1","timestamp_send": "17174886287987987","audio": ["123.mp3", "234.aac", "592.wav"],"video": ["612.mp4", "617.mkv", "891.avi"],"photo": ["1.png", "2.jpg"]}');
  }

  @override
  Stream<WebSocketEvent> receiveMessages() {
    return channel!.stream.map((message) {
      try {
        return WebSocketEvent.messageReceived;
      } catch (e) {
        return WebSocketEvent.connectionError;
      }
    }).handleError((error) {
      return WebSocketEvent.connectionError;
    }).asBroadcastStream(onCancel: (subscription) {});
  }
}

enum WebSocketEvent {
  messageReceived,
  connectionClosed,
  connectionError,
}
