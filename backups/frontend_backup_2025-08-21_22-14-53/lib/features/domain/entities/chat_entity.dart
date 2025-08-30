import 'package:equatable/equatable.dart';

class ChatEntity extends Equatable {
  final int idChat;
  final String username;
  final String photoPath;
  final MessageEntity message;

  const ChatEntity({
    required this.idChat,
    required this.username,
    required this.photoPath,
    required this.message,
  });

  @override
  List<Object?> get props => [idChat, username, photoPath, message];
}

class MessageEntity extends Equatable {
  final String msg;
  final int time;
  final int newMessage;

  const MessageEntity({
    required this.msg,
    required this.time,
    required this.newMessage,
  });

  @override
  List<Object?> get props => [msg, time, newMessage];
}
