import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';

import '../../../../../../data/models/friend_model.dart';
import '../../../../../../data/repositories/friends_repository.dart';

part 'friends_screen_state.dart';

class FriendsScreenCubit extends Cubit<FriendsScreenState> {
  final FriendsRepository repository;
  FriendsScreenCubit(this.repository) : super(const FriendsScreenInitial());

  late String username;

  Future<void> getFriends(String username) async {
    emit(const FriendsScreenLoading());
    this.username = username;
    final friends = await repository.getFriends(username);
    final sentRequests = await repository.getSentRequests();
    final receivedRequests = await repository.getReceivedRequests();

    emit(FriendsScreenLoaded(
        friends: friends, sentRequests: sentRequests, receivedRequests: receivedRequests));
  }

  Future<void> deleteRequest(int requestId) async {
    await repository.deleteRequest(requestId);

    await getFriends(username);
  }

  void updateRequest(int requestId, String status) async {
    await repository.updateRequest(requestId, status);

    await getFriends(username);
  }

  void createRequest(String friendId) async {
    await repository.createRequest(friendId);
    await getFriends(username);
  }
}
