import 'package:dartz/dartz.dart';
import 'package:los_angeles_quest/core/error/failure.dart';
import 'package:los_angeles_quest/features/domain/entities/user_entity.dart';
import 'package:los_angeles_quest/features/domain/usecases/user/create_user.dart';
import 'package:los_angeles_quest/features/domain/usecases/user/edit_user.dart';

abstract class UserRepository {
  Future<Either<Failure, List<UserEntity>>> getAll({
    String? search,
    bool banned = false,
    int page = 1,
    int size = 50,
  });
  Future<Either<Failure, void>> ban(String id);
  Future<void> createUser(CreateUserParams user);
  Future<void> editUser(EditUserParams user);
  Future<void> changePassword(String oldPassword, String newPassword, String confirmPassword);
}
