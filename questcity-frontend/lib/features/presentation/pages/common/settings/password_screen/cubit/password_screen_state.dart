part of 'password_screen_cubit.dart';

abstract class PasswordScreenState extends Equatable {
  const PasswordScreenState();

  @override
  List<Object> get props => [];
}

class PasswordScreenInitial extends PasswordScreenState {}

class PasswordScreenUpdating extends PasswordScreenState {}

class PasswordScreenError extends PasswordScreenState {
  final String message;

  const PasswordScreenError({required this.message});
}
