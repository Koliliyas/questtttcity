import 'package:dartz/dartz.dart';
import 'package:equatable/equatable.dart';
import 'package:los_angeles_quest/core/error/failure.dart';
import 'package:los_angeles_quest/core/usecases/usecase.dart';
import 'package:los_angeles_quest/features/domain/entities/user_entity.dart';
import 'package:los_angeles_quest/features/domain/repositories/user_repository.dart';

class GetAllUsers extends UseCase<List<UserEntity>, GetAllUsersParams> {
  final UserRepository usersRepository;

  GetAllUsers(this.usersRepository);

  Future<Either<Failure, List<UserEntity>>> call(
      GetAllUsersParams params) async {
    return await usersRepository.getAll(
        search: params.search,
        banned: params.banned,
        page: params.page,
        size: params.size);
  }
}

class GetAllUsersParams extends Equatable {
  final String? search;
  final bool banned;
  final int page;
  final int size;

  const GetAllUsersParams(
      {required this.search,
      this.banned = false,
      this.page = 1,
      this.size = 50});

  @override
  List<Object?> get props => [search, banned, page, size];
}
