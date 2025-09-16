import 'package:equatable/equatable.dart';

class MessageEntity extends Equatable {
  final String? idChat;
  final String msg;
  final String msgType;
  final String? timestampSend;
  final int? idSender;
  final bool? isMe;
  final String? mediaPath;

  const MessageEntity({
    this.idChat,
    required this.msg,
    required this.msgType,
    this.timestampSend,
    this.idSender,
    this.isMe,
    this.mediaPath,
  });

  @override
  List<Object?> get props =>
      [msg, msgType, timestampSend, idChat, isMe, idSender, mediaPath];
}
