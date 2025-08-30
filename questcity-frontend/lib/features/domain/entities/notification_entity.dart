import 'package:equatable/equatable.dart';

class NotificationEntity extends Equatable {
  final bool status;
  final String message;
  final List<NotificationEntityNotification> notifications;
  final int total;

  const NotificationEntity(
      {required this.status,
      required this.message,
      required this.notifications,
      required this.total});

  @override
  List<Object?> get props => [status, message, notifications, total];
}

class NotificationEntityNotification extends Equatable {
  final String dateName;
  final List<NotificationNotification> notification;

  const NotificationEntityNotification(
      {required this.dateName, required this.notification});

  @override
  List<Object?> get props => [dateName, notification];
}

class NotificationNotification extends Equatable {
  final String title;
  final String action;
  final String date;

  const NotificationNotification(
      {required this.title, required this.action, required this.date});

  @override
  List<Object?> get props => [title, action, date];
}
