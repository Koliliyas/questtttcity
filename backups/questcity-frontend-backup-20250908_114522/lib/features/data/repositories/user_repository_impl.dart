import 'package:dartz/dartz.dart';
import 'package:los_angeles_quest/core/error/exception.dart';
import 'package:los_angeles_quest/core/error/failure.dart';
import 'package:los_angeles_quest/core/platform/network_info.dart';
import 'package:los_angeles_quest/features/data/datasources/user_remote_data_source_impl.dart';
import 'package:los_angeles_quest/features/domain/entities/user_entity.dart';
import 'package:los_angeles_quest/features/domain/repositories/user_repository.dart';
import 'package:los_angeles_quest/features/domain/usecases/user/edit_user.dart';

import '../../domain/usecases/user/create_user.dart';

class UserRepositoryImpl implements UserRepository {
  final UserRemoteDataSource userRemoteDataSource;
  final NetworkInfo networkInfo;

  const UserRepositoryImpl({required this.userRemoteDataSource, required this.networkInfo});

  @override
  Future<Either<Failure, void>> ban(String id) async {
    if (await networkInfo.isConnected) {
      try {
        return Right(await userRemoteDataSource.ban(id));
      } on ServerException {
        return Left(ServerFailure());
      }
    } else {
      return Left(InternetConnectionFailure());
    }
  }

  @override
  Future<Either<Failure, List<UserEntity>>> getAll({
    String? search,
    bool banned = false,
    int page = 1,
    int size = 50,
  }) async {
    if (await networkInfo.isConnected) {
      try {
        return Right(await userRemoteDataSource.getAll(
            search: search, banned: banned, page: page, size: size));
      } on ServerException {
        return Left(ServerFailure());
      }
    } else {
      return Left(InternetConnectionFailure());
    }
  }

  @override
  Future<void> createUser(CreateUserParams user) async {
    await userRemoteDataSource.createUser(user);
  }

  @override
  Future<void> editUser(EditUserParams params) async {
    return await userRemoteDataSource.edit(params);
  }

  @override
  Future<void> changePassword(
      String oldPassword, String newPassword, String confirmPassword) async {
    return await userRemoteDataSource.changePassword(oldPassword, newPassword, confirmPassword);
  }
}
