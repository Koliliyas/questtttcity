import 'dart:io';

import 'package:dartz/dartz.dart';
import 'package:los_angeles_quest/core/error/failure.dart';

abstract class FileRepository {
  Future<Either<Failure, String>> upload(File file);
  Future<Either<Failure, String>> get(String file);
}
