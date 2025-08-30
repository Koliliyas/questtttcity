import 'package:dartz/dartz.dart';
import 'package:los_angeles_quest/core/error/failure.dart';
import 'package:los_angeles_quest/features/data/models/category_model.dart';
import 'package:los_angeles_quest/features/domain/entities/category_entity.dart';

abstract class CategoryRepository {
  Future<Either<Failure, List<CategoryEntity>>> getAll();
  Future<Either<Failure, void>> create(CategoryModel category);
  Future<Either<Failure, void>> update(CategoryModel category);
}
