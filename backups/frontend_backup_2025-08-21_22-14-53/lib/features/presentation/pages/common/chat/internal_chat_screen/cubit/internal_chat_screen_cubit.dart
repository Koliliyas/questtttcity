import 'package:bloc/bloc.dart';
import 'package:los_angeles_quest/features/domain/entities/message_entity.dart';
import 'package:los_angeles_quest/features/domain/usecases/chat/get_chat_messages.dart';
import 'package:los_angeles_quest/features/presentation/pages/common/chat/internal_chat_screen/cubit/internal_chat_screen_state.dart';

class InternalChatScreenCubit extends Cubit<InternalChatScreenState> {
  final GetChatMessages getChatMessages;
  final int? chatId;
  InternalChatScreenCubit({required this.getChatMessages, this.chatId})
      : super(InternalChatScreenListEmpty());

  int page = 0;
  bool isMessagesOver = false;

  Future loadMessages() async {
    if (state is InternalChatScreenLoading) return;

    final currentState = state;

    List<MessageEntity> oldMessagesList = [];
    if (currentState is InternalChatScreenLoaded) {
      oldMessagesList = currentState.messageList;
    }

    emit(InternalChatScreenLoading(oldMessagesList, isFirstFetch: page == 0));

    final failureOrLoads = await getChatMessages(
        GetChatMessagesParams(chatId: chatId!, limit: 10, offset: 10 * page));

    failureOrLoads.fold(
        (error) =>
            emit(const InternalChatScreenError(message: 'Server Failure')),
        (messages) {
      page += 1;

      final messages = (state as InternalChatScreenLoading).oldMessagesList;
      messages.addAll(messages.where((e) => e.timestampSend != null).toList());

      messages.sort((a, b) => (a.timestampSend)!.compareTo(b.timestampSend!));

      emit(InternalChatScreenLoaded(messages));

      if (messages.length < 10) {
        isMessagesOver = true;
      }
    });
  }
}
