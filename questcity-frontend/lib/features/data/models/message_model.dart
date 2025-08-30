import 'package:los_angeles_quest/constants/utils.dart';
import 'package:los_angeles_quest/features/domain/entities/message_entity.dart';

class MessageModel extends MessageEntity {
  @override
  final String? idChat;
  @override
  final String msg;
  @override
  final String msgType;
  @override
  final String? timestampSend;
  @override
  final int? idSender;
  @override
  final bool? isMe;
  @override
  final String? mediaPath;

  const MessageModel({
    this.idChat,
    required this.msg,
    required this.msgType,
    this.timestampSend,
    this.idSender,
    this.isMe,
    this.mediaPath,
  }) : super(
          idChat: idChat,
          msg: msg,
          msgType: msgType,
          timestampSend: timestampSend,
          idSender: idSender,
          isMe: isMe,
          mediaPath: mediaPath,
        );

  factory MessageModel.fromJson(Map<String, dynamic> json) => MessageModel(
        idChat: json["id_chat"],
        msg: Utils.fixEncoding(json["msg"]) ?? '',
        msgType: json["msgType"],
        timestampSend: json["timestamp_send"]?.toString(),
        mediaPath: json["media_path"],
        idSender: json["id_sender"],
        isMe: json["isMe"],
      );

  Map<String, dynamic> toJson() => {
        "id_chat": idChat,
        "msg": msg,
        "msgType": msgType,
        "timestamp_send": timestampSend,
        "media_path": mediaPath,
        "id_sender": idSender,
        "isMe": isMe,
      };
}
