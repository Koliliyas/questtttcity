part of 'login_screen_cubit.dart';

abstract class LoginScreenState extends Equatable {
  const LoginScreenState();

  @override
  List<Object?> get props => [];
}

class LoginScreenInitial extends LoginScreenState {
  final bool rememberUser;
  final bool isEmailValid;
  final bool isPasswordValid;
  final bool allFieldsValidate;

  const LoginScreenInitial({
    this.rememberUser = false,
    this.isEmailValid = false,
    this.isPasswordValid = false,
    this.allFieldsValidate = false,
  });

  LoginScreenInitial copyWith({
    bool? rememberUser,
    bool? isEmailValid,
    bool? isPasswordValid,
    bool? allFieldsValidate,
  }) {
    return LoginScreenInitial(
      rememberUser: rememberUser ?? this.rememberUser,
      isEmailValid: isEmailValid ?? this.isEmailValid,
      isPasswordValid: isPasswordValid ?? this.isPasswordValid,
      allFieldsValidate: allFieldsValidate ?? this.allFieldsValidate,
    );
  }

  @override
  List<Object?> get props =>
      [rememberUser, isEmailValid, isPasswordValid, allFieldsValidate];
}

class LoginScreenLoading extends LoginScreenState {
  final String? message;

  const LoginScreenLoading({this.message});

  @override
  List<Object?> get props => [message];
}

class LoginScreenLoaded extends LoginScreenState {
  final PersonEntity person;
  final bool rememberUser;
  final bool isEmailValid;
  final bool isPasswordValid;
  final bool allFieldsValidate;

  const LoginScreenLoaded({
    required this.person,
    this.rememberUser = false,
    this.isEmailValid = false,
    this.isPasswordValid = false,
    this.allFieldsValidate = false,
  });

  LoginScreenLoaded copyWith({
    PersonEntity? person,
    bool? rememberUser,
    bool? isEmailValid,
    bool? isPasswordValid,
    bool? allFieldsValidate,
  }) {
    return LoginScreenLoaded(
      person: person ?? this.person,
      rememberUser: rememberUser ?? this.rememberUser,
      isEmailValid: isEmailValid ?? this.isEmailValid,
      isPasswordValid: isPasswordValid ?? this.isPasswordValid,
      allFieldsValidate: allFieldsValidate ?? this.allFieldsValidate,
    );
  }

  @override
  List<Object?> get props =>
      [person, rememberUser, isEmailValid, isPasswordValid, allFieldsValidate];
}
