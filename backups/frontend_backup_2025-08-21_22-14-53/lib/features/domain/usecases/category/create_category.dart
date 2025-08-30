import 'package:dartz/dartz.dart';
import 'package:los_angeles_quest/core/error/failure.dart';
import 'package:los_angeles_quest/core/usecases/usecase.dart';
import 'package:los_angeles_quest/features/data/models/category_model.dart';
import 'package:los_angeles_quest/features/domain/repositories/category_repository.dart';

class CreateCategory extends UseCase<void, CategoryModel> {
  final CategoryRepository categoryRepository;

  CreateCategory(this.categoryRepository);

  Future<Either<Failure, void>> call(CategoryModel params) async {
    return await categoryRepository.create(params);
  }
}
