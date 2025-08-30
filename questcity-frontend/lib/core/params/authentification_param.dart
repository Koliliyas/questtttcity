import 'package:equatable/equatable.dart';

class AuthenticationParams extends Equatable {
  final String email;
  final String? password;
  final String? fbid;
  final String? code;

  const AuthenticationParams(
      {required this.email, this.password, this.fbid, this.code});

  @override
  List<Object?> get props => [email, password, fbid, code];
}
