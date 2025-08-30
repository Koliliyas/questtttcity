import 'dart:io';

import 'package:dartz/dartz.dart';
import 'package:los_angeles_quest/core/error/exception.dart';
import 'package:los_angeles_quest/core/error/failure.dart';
import 'package:los_angeles_quest/core/platform/network_info.dart';
import 'package:los_angeles_quest/features/data/datasources/file_remote_data_source_impl.dart';
import 'package:los_angeles_quest/features/domain/repositories/file_repository.dart';

class FileRepositoryImpl implements FileRepository {
  final FileRemoteDataSource fileRemoteDataSource;
  final NetworkInfo networkInfo;

  const FileRepositoryImpl(
      {required this.fileRemoteDataSource, required this.networkInfo});
  @override
  Future<Either<Failure, String>> get(String file) async {
    if (await networkInfo.isConnected) {
      try {
        return Right(await fileRemoteDataSource.get(file));
      } on ServerException {
        return Left(ServerFailure());
      }
    } else {
      return Left(InternetConnectionFailure());
    }
  }

  @override
  Future<Either<Failure, String>> upload(File file) async {
    if (await networkInfo.isConnected) {
      try {
        return Right(await fileRemoteDataSource.upload(file));
      } on ServerException {
        return Left(ServerFailure());
      }
    } else {
      return Left(InternetConnectionFailure());
    }
  }
}
