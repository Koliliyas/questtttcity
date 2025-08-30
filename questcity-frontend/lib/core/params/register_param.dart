import 'package:equatable/equatable.dart';

class RegisterParam extends Equatable {
  final String nickname;
  final String firstName;
  final String lastName;
  final String email;
  final String password;

  const RegisterParam(
      {required this.nickname,
      required this.firstName,
      required this.lastName,
      required this.email,
      required this.password});

  @override
  List<Object?> get props => [
        nickname,
        firstName,
        lastName,
        email,
        password,
      ];
}
