import 'package:dartz/dartz.dart';
import 'package:los_angeles_quest/core/error/failure.dart';
import 'package:los_angeles_quest/core/params/no_param.dart';
import 'package:los_angeles_quest/core/usecases/usecase.dart';
import 'package:los_angeles_quest/features/domain/entities/category_entity.dart';
import 'package:los_angeles_quest/features/domain/repositories/category_repository.dart';

class GetAllCategories extends UseCase<List<CategoryEntity>, NoParams> {
  final CategoryRepository categoryRepository;

  GetAllCategories(this.categoryRepository);

  Future<Either<Failure, List<CategoryEntity>>> call(NoParams params) async {
    return await categoryRepository.getAll();
  }
}
