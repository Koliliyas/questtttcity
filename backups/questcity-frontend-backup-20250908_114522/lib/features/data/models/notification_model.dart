import 'package:los_angeles_quest/features/domain/entities/notification_entity.dart'
    as ne;

class NotificationModel extends ne.NotificationEntity {
  @override
  final bool status;
  @override
  final String message;
  @override
  final List<NotificationModelNotification> notifications;
  @override
  final int total;

  const NotificationModel(
      {required this.status,
      required this.message,
      required this.notifications,
      required this.total})
      : super(
            status: status,
            message: message,
            notifications: notifications,
            total: total);

  factory NotificationModel.fromJson(Map<String, dynamic> json) =>
      NotificationModel(
        status: json["status"],
        message: json["message"],
        notifications: List<NotificationModelNotification>.from(
            json["notifications"]
                .map((x) => NotificationModelNotification.fromJson(x))),
        total: json["total"],
      );

  Map<String, dynamic> toJson() => {
        "status": status,
        "message": message,
        "notifications":
            List<dynamic>.from(notifications.map((x) => x.toJson())),
        "total": total,
      };
}

class NotificationModelNotification extends ne.NotificationEntityNotification {
  @override
  final String dateName;
  @override
  final List<NotificationNotification> notification;

  const NotificationModelNotification({
    required this.dateName,
    required this.notification,
  }) : super(dateName: dateName, notification: notification);

  factory NotificationModelNotification.fromJson(Map<String, dynamic> json) =>
      NotificationModelNotification(
        dateName: json["date_name"],
        notification: List<NotificationNotification>.from(json["notification"]
            .map((x) => NotificationNotification.fromJson(x))),
      );

  Map<String, dynamic> toJson() => {
        "date_name": dateName,
        "notification": List<dynamic>.from(notification.map((x) => x.toJson())),
      };
}

class NotificationNotification extends ne.NotificationNotification {
  @override
  final String title;
  @override
  final String action;
  @override
  final String date;

  const NotificationNotification({
    required this.title,
    required this.action,
    required this.date,
  }) : super(title: title, action: action, date: date);

  factory NotificationNotification.fromJson(Map<String, dynamic> json) =>
      NotificationNotification(
        title: json["title"],
        action: json["action"],
        date: json["date"],
      );

  Map<String, dynamic> toJson() => {
        "title": title,
        "action": action,
        "date": date,
      };
}
