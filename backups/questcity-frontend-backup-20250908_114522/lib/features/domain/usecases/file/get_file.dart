import 'package:dartz/dartz.dart';
import 'package:los_angeles_quest/core/error/failure.dart';
import 'package:los_angeles_quest/core/usecases/usecase.dart';
import 'package:los_angeles_quest/features/domain/repositories/file_repository.dart';

class GetFile extends UseCase<String, String> {
  final FileRepository fileRepository;

  GetFile(this.fileRepository);

  Future<Either<Failure, String>> call(String params) async {
    return await fileRepository.get(params);
  }
}
