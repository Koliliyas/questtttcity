import 'package:dartz/dartz.dart';
import 'package:los_angeles_quest/core/error/failure.dart';
import 'package:los_angeles_quest/features/data/models/person_model.dart';
import 'package:los_angeles_quest/features/domain/entities/notification_entity.dart';
import 'package:los_angeles_quest/features/domain/usecases/user/edit_user.dart';

abstract class PersonRepository {
  Future<Either<Failure, PersonModel>> getMe();
  Future<Either<Failure, void>> updateMe(EditUserParams person);
  Future<Either<Failure, NotificationEntity>> getNotifications({int? limit, int? offset});
  Future<Either<Failure, void>> deleteMe();
}
