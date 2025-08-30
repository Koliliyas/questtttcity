import 'package:equatable/equatable.dart';
import 'package:los_angeles_quest/features/domain/entities/message_entity.dart';

abstract class InternalChatScreenState extends Equatable {
  const InternalChatScreenState();

  @override
  List<Object> get props => [];
}

class InternalChatScreenListEmpty extends InternalChatScreenState {
  @override
  List<Object> get props => [];
}

class InternalChatScreenLoading extends InternalChatScreenState {
  final List<MessageEntity> oldMessagesList;
  final bool isFirstFetch;

  const InternalChatScreenLoading(this.oldMessagesList,
      {this.isFirstFetch = false});

  @override
  List<Object> get props => [oldMessagesList, isFirstFetch];
}

class InternalChatScreenLoaded extends InternalChatScreenState {
  final List<MessageEntity> messageList;

  const InternalChatScreenLoaded(this.messageList);

  @override
  List<Object> get props => [messageList];
}

class InternalChatScreenError extends InternalChatScreenState {
  final String message;

  const InternalChatScreenError({required this.message});

  @override
  List<Object> get props => [message];
}
