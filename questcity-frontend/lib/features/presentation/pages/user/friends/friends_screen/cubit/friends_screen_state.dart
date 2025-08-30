part of 'friends_screen_cubit.dart';

abstract class FriendsScreenState extends Equatable {
  const FriendsScreenState();

  @override
  List<Object?> get props => [];
}

class FriendsScreenInitial extends FriendsScreenState {
  const FriendsScreenInitial();
}

class FriendsScreenLoading extends FriendsScreenState {
  const FriendsScreenLoading();
}

class FriendsScreenLoaded extends FriendsScreenState {
  final List<FriendModel> friends;
  final List<FriendRequestModel> sentRequests;
  final List<FriendRequestModel> receivedRequests;
  const FriendsScreenLoaded({
    required this.friends,
    required this.sentRequests,
    required this.receivedRequests,
  });

  @override
  List<Object?> get props => [friends, sentRequests, receivedRequests];

  FriendsScreenLoaded copyWith({
    List<FriendModel>? friends,
    List<FriendRequestModel>? sentRequests,
    List<FriendRequestModel>? receivedRequests,
  }) {
    return FriendsScreenLoaded(
      friends: friends ?? this.friends,
      sentRequests: sentRequests ?? this.sentRequests,
      receivedRequests: receivedRequests ?? this.receivedRequests,
    );
  }
}
