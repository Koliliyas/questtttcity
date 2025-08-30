import 'package:los_angeles_quest/features/domain/repositories/user_repository.dart';

class CreateUser {
  final UserRepository repository;

  CreateUser(this.repository);

  Future<void> call(CreateUserParams params) async {
    await repository.createUser(params);
  }
}

class CreateUserParams {
  final String password;
  final String email;
  final String firstName;
  final String lastName;
  final int role;
  final String username;
  final String? instagram;
  final String? image;

  CreateUserParams(
      {required this.password,
      required this.email,
      required this.firstName,
      required this.lastName,
      required this.role,
      required this.instagram,
      required this.image,
      required this.username});
}
