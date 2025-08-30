import 'package:equatable/equatable.dart';
import 'package:los_angeles_quest/features/domain/entities/chat_entity.dart'
    as ce;
import 'package:los_angeles_quest/features/domain/entities/message_entity.dart';

abstract class ChatScreenState extends Equatable {
  const ChatScreenState();

  @override
  List<Object?> get props => [];
}

class ChatScreenLoaded extends ChatScreenState {
  final List<ce.ChatEntity>? chatsList;
  final String? searchText;
  final MessageEntity?
      lastMessage; // новое поле для хранения последнего сообщения

  const ChatScreenLoaded({this.chatsList, this.searchText, this.lastMessage});

  ChatScreenLoaded copyWith({
    List<ce.ChatEntity>? chatsList,
    String? searchText,
    MessageEntity? lastMessage,
  }) {
    return ChatScreenLoaded(
      chatsList: chatsList ?? this.chatsList ?? [],
      searchText: searchText ?? this.searchText ?? '',
      lastMessage: lastMessage ?? this.lastMessage,
    );
  }

  @override
  List<Object?> get props => [chatsList, searchText, lastMessage];
}

class ChatScreenLoading extends ChatScreenState {}

class ChatScreenError extends ChatScreenState {
  final String message;

  const ChatScreenError({required this.message});

  @override
  List<Object> get props => [message];
}
