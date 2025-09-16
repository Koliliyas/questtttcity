import 'package:los_angeles_quest/constants/utils.dart';
import 'package:los_angeles_quest/features/domain/entities/chat_entity.dart';

class ChatModel extends ChatEntity {
  @override
  final int idChat;
  @override
  final String username;
  @override
  final String photoPath;
  @override
  final MessageModel message;

  const ChatModel({
    required this.idChat,
    required this.username,
    required this.photoPath,
    required this.message,
  }) : super(
          idChat: idChat,
          username: username,
          photoPath: photoPath,
          message: message,
        );

  factory ChatModel.fromJson(Map<String, dynamic> json) => ChatModel(
        idChat: json["id_chat"],
        username: Utils.fixEncoding(json["username"]) ?? '',
        photoPath: Utils.fixEncoding(json["photo_path"]) ?? '',
        message: MessageModel.fromJson(json["message"]),
      );

  Map<String, dynamic> toJson() => {
        "id_chat": idChat,
        "username": username,
        "photo_path": photoPath,
        "message": message.toJson(),
      };
}

class MessageModel extends MessageEntity {
  @override
  final String msg;
  @override
  final int time;
  @override
  final int newMessage;

  const MessageModel({
    required this.msg,
    required this.time,
    required this.newMessage,
  }) : super(
          msg: msg,
          time: time,
          newMessage: newMessage,
        );

  factory MessageModel.fromJson(Map<String, dynamic> json) => MessageModel(
        msg: Utils.fixEncoding(json["msg"]) ?? '',
        time: json["time"],
        newMessage: json["new_message"],
      );

  Map<String, dynamic> toJson() => {
        "msg": msg,
        "time": time,
        "new_message": newMessage,
      };
}
