part of 'sign_in_screen_cubit.dart';

abstract class SignInScreenState extends Equatable {
  const SignInScreenState();

  @override
  List<Object> get props => [];
}

class SignInScreenInitial extends SignInScreenState {
  final bool allFieldsValidate;

  const SignInScreenInitial({this.allFieldsValidate = false});

  SignInScreenInitial copyWith({bool? allFieldsValidate}) {
    return SignInScreenInitial(
        allFieldsValidate: allFieldsValidate ?? this.allFieldsValidate);
  }

  @override
  List<Object> get props => [allFieldsValidate];
}

class SignInScreenVerify extends SignInScreenState {}
