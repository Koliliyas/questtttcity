import 'package:los_angeles_quest/features/data/models/friend_model.dart';

import '../datasources/friends_datasource.dart';

abstract class FriendsRepository {
  Future<List<FriendModel>> getFriends(String username);
  Future<List<FriendRequestModel>> getSentRequests();
  Future<List<FriendRequestModel>> getReceivedRequests();
  Future<void> deleteRequest(int requestId);
  Future<void> updateRequest(int requestId, String status);
  Future<void> createRequest(String friendId);
}

class FriendsRepositoryImpl implements FriendsRepository {
  final FriendsDatasource remoteDataSource;

  FriendsRepositoryImpl({required this.remoteDataSource});

  @override
  Future<List<FriendModel>> getFriends(String username) async {
    return await remoteDataSource.getFriends(username);
  }

  @override
  Future<List<FriendRequestModel>> getSentRequests() async {
    return await remoteDataSource.getSentRequests();
  }

  @override
  Future<List<FriendRequestModel>> getReceivedRequests() async {
    return await remoteDataSource.getReceivedRequests();
  }

  @override
  Future<void> deleteRequest(int requestId) async {
    return await remoteDataSource.deleteRequest(requestId);
  }

  @override
  Future<void> updateRequest(int requestId, String status) async {
    return await remoteDataSource.updateRequest(requestId, status);
  }

  @override
  Future<void> createRequest(String friendId) async {
    return await remoteDataSource.createRequest(friendId);
  }
}
