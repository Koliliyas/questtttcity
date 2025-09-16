part of 'invite_friend_cubit.dart';

abstract class InviteFriendState extends Equatable {
  const InviteFriendState();

  @override
  List<Object> get props => [];
}

class InviteFriendInitial extends InviteFriendState {}

class InviteFriendInvitesSended extends InviteFriendState {}

class InviteFriendExcludeFriend extends InviteFriendState {}
