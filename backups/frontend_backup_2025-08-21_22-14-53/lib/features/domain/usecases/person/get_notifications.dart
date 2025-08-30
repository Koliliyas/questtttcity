import 'package:dartz/dartz.dart';
import 'package:equatable/equatable.dart';
import 'package:los_angeles_quest/core/error/failure.dart';
import 'package:los_angeles_quest/core/usecases/usecase.dart';
import 'package:los_angeles_quest/features/domain/entities/notification_entity.dart';
import 'package:los_angeles_quest/features/domain/repositories/person_repository.dart';

class GetNotifications
    extends UseCase<NotificationEntity, GetNotificationsParams> {
  final PersonRepository personRepository;

  GetNotifications(this.personRepository);

  Future<Either<Failure, NotificationEntity>> call(
      GetNotificationsParams params) async {
    return await personRepository.getNotifications(
        limit: params.limit, offset: params.offset);
  }
}

class GetNotificationsParams extends Equatable {
  final int? limit;
  final int? offset;

  const GetNotificationsParams({this.limit, this.offset});

  @override
  List<Object?> get props => [limit, offset];
}
