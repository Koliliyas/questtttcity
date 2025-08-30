part of 'account_screen_cubit.dart';

abstract class AccountScreenState extends Equatable {
  const AccountScreenState();

  @override
  List<Object?> get props => [];
}

class AccountScreenInitial extends AccountScreenState {}

class AccountScreenLoading extends AccountScreenState {}

class AccountScreenLoaded extends AccountScreenState {
  final UserModel? user;

  const AccountScreenLoaded(this.user);

  @override
  List<Object?> get props => [user];
}
