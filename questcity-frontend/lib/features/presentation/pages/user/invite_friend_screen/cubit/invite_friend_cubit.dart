import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';

part 'invite_friend_state.dart';

class InviteFriendCubit extends Cubit<InviteFriendState> {
  InviteFriendCubit() : super(InviteFriendInitial());

  List<bool> invites = [
    false,
    false,
    false,
    false,
    false,
    false,
    false,
    false,
    false
  ];

  int excludeFriendIndex = 0;

  onTapFriend(int index) {
    if (invites[index]) {
      emit(InviteFriendExcludeFriend());
    } else {
      invites[index] = true;
    }
  }

  onInvitesSend() {
    emit(InviteFriendInvitesSended());
  }

  onExcludeFriend() {
    invites[excludeFriendIndex] = false;
    emit(InviteFriendInitial());
  }

  onReturnInvite() {
    emit(InviteFriendInitial());
  }
}
