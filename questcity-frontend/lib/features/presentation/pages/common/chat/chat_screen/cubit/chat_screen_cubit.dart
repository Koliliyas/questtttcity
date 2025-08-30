
import 'package:bloc/bloc.dart';
import 'package:flutter/material.dart';
import 'package:los_angeles_quest/core/params/no_param.dart';


import 'package:los_angeles_quest/features/data/models/message_model.dart';
import 'package:los_angeles_quest/features/domain/entities/chat_entity.dart';
import 'package:los_angeles_quest/features/domain/usecases/chat/get_all_chats.dart';
import 'package:los_angeles_quest/features/domain/usecases/websocket/connect_web_socket.dart';
import 'package:los_angeles_quest/features/presentation/pages/common/chat/chat_screen/cubit/chat_screen_state.dart';
import 'package:shared_preferences/shared_preferences.dart';

class ChatScreenCubit extends Cubit<ChatScreenState> {
  final GetAllChats getAllChats;
  final SharedPreferences sharedPreferences;
  final WebSocketConnect webSocketConnect;
  final WebSocketDisconnect webSocketDisconnect;
  final WebSocketSendMessage webSocketSendMessage;
  final WebSocketReceiveMessages webSocketReceiveMessages;

  ChatScreenCubit({
    required this.getAllChats,
    required this.sharedPreferences,
    required this.webSocketConnect,
    required this.webSocketDisconnect,
    required this.webSocketSendMessage,
    required this.webSocketReceiveMessages,
  }) : super(ChatScreenLoading()) {
    searchController.addListener(_onSearchTextChanged);
    connectToWebSocket(); // Подключение к WebSocket сразу при инициализации
  }

  TextEditingController searchController = TextEditingController();
  List<ChatEntity> chats = [];

  Future<void> getChats() async {
    final failureOrLoads = await getAllChats(NoParams());
    failureOrLoads.fold(
      (error) => emit(const ChatScreenError(message: 'Server Failure')),
      (chatsList) {
        chats = chatsList;
        chats.sort((a, b) => (b.message.time).compareTo(a.message.time));
        emit(ChatScreenLoaded(chatsList: chats, searchText: ''));
      },
    );
  }

  void _onSearchTextChanged() {
    if (state is ChatScreenLoaded) {
      ChatScreenLoaded currentState = state as ChatScreenLoaded;
      final filteredChats = currentState.chatsList!
          .where((e) => e.username.toLowerCase().startsWith(searchController.text.toLowerCase()))
          .toList();
      emit(currentState.copyWith(
        searchText: searchController.text,
        chatsList: filteredChats,
      ));
    }
  }

  Future<void> connectToWebSocket() async {
    emit(ChatScreenLoading());
    // final String? socketToken = sharedPreferences.getString(SharedPreferencesKeys.socketToken);
    // final result = await webSocketConnect(socketToken!);
    // result.fold(
    //   (failure) => emit(const ChatScreenError(message: 'Failed to connect')),
    //   (success) {
    //     _listenForMessages();
    //     emit(ChatScreenLoaded(chatsList: chats, searchText: ''));
    //   },
    // );
  }

  Future<void> disconnectFromWebSocket() async {
    emit(ChatScreenLoading());
    final result = await webSocketDisconnect();
    result.fold(
      (failure) => emit(const ChatScreenError(message: 'Failed to disconnect')),
      (success) => emit(ChatScreenLoaded(chatsList: chats, searchText: '')),
    );
  }

  Future<void> sendMessage(String message) async {
    final result = await webSocketSendMessage(
      MessageModel(idChat: "1", msg: message, msgType: "1"),
    );
    result.fold(
      (failure) => emit(const ChatScreenError(message: 'Failed to send message')),
      (success) => emit(ChatScreenLoaded(chatsList: chats, searchText: '')),
    );
  }

  // void _listenForMessages() {
  //   webSocketReceiveMessages().listen((event) {
  //     if (state is ChatScreenLoaded) {
  //       //final currentState = state as ChatScreenLoaded;

  //       // Обрабатываем в зависимости от типа события
  //       if (event == WebSocketEvent.messageReceived) {
  //         appLogger.d('123');
  //       } else if (event == WebSocketEvent.connectionError) {
  //         appLogger.d('345');
  //         emit(const ChatScreenError(message: 'Error receiving message'));
  //       } else if (event == WebSocketEvent.connectionClosed) {
  //         appLogger.d('678');
  //         // Обрабатываем закрытие соединения (если нужно)
  //         // emit(SomeOtherState());
  //       }
  //     }
  //   });
  // }

  @override
  Future<void> close() {
    searchController.dispose();
    disconnectFromWebSocket(); // Отключение от WebSocket при закрытии кубита
    return super.close();
  }
}
