import 'dart:io';

import 'package:dartz/dartz.dart';
import 'package:los_angeles_quest/core/error/failure.dart';
import 'package:los_angeles_quest/core/usecases/usecase.dart';
import 'package:los_angeles_quest/features/domain/repositories/file_repository.dart';

class UploadFile extends UseCase<String, File> {
  final FileRepository fileRepository;

  UploadFile(this.fileRepository);

  Future<Either<Failure, String>> call(File params) async {
    return await fileRepository.upload(params);
  }
}
