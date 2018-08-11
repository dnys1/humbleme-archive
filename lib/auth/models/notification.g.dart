// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'notification.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

Notification _$NotificationFromJson(Map<String, dynamic> json) =>
    new Notification(
        id: json['id'] as String,
        messageId: json['messageId'] as String,
        toUser: json['toUser'] as String,
        type: json['type'] == null
            ? null
            : NotificationType.values.singleWhere(
                (x) => x.toString() == 'NotificationType.${json['type']}'),
        notification: json['notification'] == null
            ? null
            : notificationBodyFromJson(
                json['notification'] as Map<dynamic, dynamic>),
        data: json['data'] == null
            ? null
            : notificationDataFromJson(json['data'] as Map<dynamic, dynamic>),
        dateTime: json['dateTime'] == null
            ? null
            : dateTimeFromJson(json['dateTime']),
        read: json['read'] as bool);

abstract class _$NotificationSerializerMixin {
  String get id;
  String get messageId;
  String get toUser;
  NotificationType get type;
  NotificationBody get notification;
  NotificationData get data;
  DateTime get dateTime;
  bool get read;
  Map<String, dynamic> toJson() => <String, dynamic>{
        'id': id,
        'messageId': messageId,
        'toUser': toUser,
        'type': type == null ? null : type.toString().split('.')[1],
        'notification': notification,
        'data': data,
        'dateTime': dateTime == null ? null : dateTimeToJson(dateTime),
        'read': read
      };
}

NotificationBody _$NotificationBodyFromJson(Map<String, dynamic> json) =>
    new NotificationBody(
        title: json['title'] as String, body: json['body'] as String);

abstract class _$NotificationBodySerializerMixin {
  String get title;
  String get body;
  Map<String, dynamic> toJson() =>
      <String, dynamic>{'title': title, 'body': body};
}

NotificationData _$NotificationDataFromJson(Map<String, dynamic> json) =>
    new NotificationData(
        profile: json['profile'] as String,
        route: json['route'] as String,
        icon: json['icon'] as String);

abstract class _$NotificationDataSerializerMixin {
  String get profile;
  String get route;
  String get icon;
  Map<String, dynamic> toJson() =>
      <String, dynamic>{'profile': profile, 'route': route, 'icon': icon};
}
