
import '../../repositories/user_repository.dart';

class EditUser {
  final UserRepository repository;

  EditUser(this.repository);

  Future<void> call(EditUserParams params) async {
    return await repository.editUser(params);
  }
}

class EditUserParams {
  final String? username;
  final String? email;
  final String? firstName;
  final String? lastName;
  final String? password;
  final String id;
  final String? instagram;
  final String? image;
  final int profileId;

  EditUserParams(
      {required this.id,
      required this.profileId,
      this.username,
      this.email,
      this.instagram,
      this.image,
      this.firstName,
      this.lastName,
      this.password});
}
