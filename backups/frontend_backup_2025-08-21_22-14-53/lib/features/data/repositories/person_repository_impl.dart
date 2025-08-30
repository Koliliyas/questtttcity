import 'package:dartz/dartz.dart';
import 'package:los_angeles_quest/core/error/exception.dart';
import 'package:los_angeles_quest/core/error/failure.dart';
import 'package:los_angeles_quest/core/platform/network_info.dart';
import 'package:los_angeles_quest/features/data/datasources/person_remote_data_source_impl.dart';
import 'package:los_angeles_quest/features/data/models/person_model.dart';
import 'package:los_angeles_quest/features/domain/entities/notification_entity.dart';
import 'package:los_angeles_quest/features/domain/repositories/person_repository.dart';
import 'package:los_angeles_quest/features/domain/usecases/user/edit_user.dart';

class PersonRepositoryImpl implements PersonRepository {
  final PersonRemoteDataSource personRemoteDataSource;
  final NetworkInfo networkInfo;

  const PersonRepositoryImpl({required this.personRemoteDataSource, required this.networkInfo});

  @override
  Future<Either<Failure, void>> deleteMe() async {
    if (await networkInfo.isConnected) {
      try {
        return Right(await personRemoteDataSource.deleteMe());
      } on ServerException {
        return Left(ServerFailure());
      }
    } else {
      return Left(InternetConnectionFailure());
    }
  }

  @override
  Future<Either<Failure, PersonModel>> getMe() async {
    if (await networkInfo.isConnected) {
      try {
        final personRemote = await personRemoteDataSource.getMe();
        return Right(personRemote);
      } on ServerException {
        return Left(ServerFailure());
      }
    } else {
      return Left(InternetConnectionFailure());
    }
  }

  @override
  Future<Either<Failure, NotificationEntity>> getNotifications({int? limit, int? offset}) async {
    if (await networkInfo.isConnected) {
      try {
        return Right(await personRemoteDataSource.getNotifications());
      } on ServerException {
        return Left(ServerFailure());
      }
    } else {
      return Left(InternetConnectionFailure());
    }
  }

  @override
  Future<Either<Failure, void>> updateMe(EditUserParams person) async {
    if (await networkInfo.isConnected) {
      try {
        return Right(await personRemoteDataSource.updateMe(person));
      } on ServerException {
        return Left(ServerFailure());
      }
    } else {
      return Left(InternetConnectionFailure());
    }
  }
}
