import 'package:dartz/dartz.dart';
import 'package:los_angeles_quest/core/error/exception.dart';
import 'package:los_angeles_quest/core/error/failure.dart';
import 'package:los_angeles_quest/core/platform/network_info.dart';
import 'package:los_angeles_quest/features/data/datasources/category_remote_data_source_impl.dart';
import 'package:los_angeles_quest/features/data/models/category_model.dart';
import 'package:los_angeles_quest/features/domain/entities/category_entity.dart';
import 'package:los_angeles_quest/features/domain/repositories/category_repository.dart';

class CategoryRepositoryImpl implements CategoryRepository {
  final CategoryRemoteDataSource categoryRemoteDataSource;
  final NetworkInfo networkInfo;

  const CategoryRepositoryImpl(
      {required this.categoryRemoteDataSource, required this.networkInfo});

  @override
  Future<Either<Failure, void>> create(CategoryModel category) async {
    if (await networkInfo.isConnected) {
      try {
        return Right(await categoryRemoteDataSource.create(category));
      } on ServerException {
        return Left(ServerFailure());
      }
    } else {
      return Left(InternetConnectionFailure());
    }
  }

  @override
  Future<Either<Failure, void>> update(CategoryModel category) async {
    if (await networkInfo.isConnected) {
      try {
        return Right(await categoryRemoteDataSource.update(category));
      } on ServerException {
        return Left(ServerFailure());
      }
    } else {
      return Left(InternetConnectionFailure());
    }
  }

  @override
  Future<Either<Failure, List<CategoryEntity>>> getAll() async {
    if (await networkInfo.isConnected) {
      try {
        return Right(await categoryRemoteDataSource.getAll());
      } on ServerException {
        print('🔍 DEBUG: ServerException in category repository');
        return Left(ServerFailure());
      } catch (e) {
        print('🔍 DEBUG: Unexpected error in category repository: $e');
        return Left(ServerFailure());
      }
    } else {
      print('🔍 DEBUG: No internet connection for categories');
      return Left(InternetConnectionFailure());
    }
  }
}
